## Using Tags from Automate
Tags are a very powerful feature of CloudForms/ManageIQ, and fortunately Automate has extensive support for tag-related operations.

### Creating Tags and Categories

Tags are defined and used within the context of tag _categories_. We can check whether a category exists, and if not create it:

```ruby
unless $evm.execute('category_exists?', 'data_centre')
  $evm.execute('category_create',
  					:name => 'data_centre',
  					:single_value => false,
  					:perf_by_tag => false,
  					:description => "Data Centre")
end
```
We can also check whether a tag exists within a category, and if not create it:

```ruby
unless $evm.execute('tag_exists?', 'data_centre', 'london')
  $evm.execute('tag_create', 
  					'data_centre',
  					:name => 'london',
  					:description => 'London East End')
end
```
Note that tag and category names must be lower-case, and optionally contain underscores. They have a maximum length of 30 characters. The tag and category descriptions can be free text.

### Assigning and Removing Tags

We can assign a category/tag to an object (in this case a VM):

```ruby
vm = $evm.root['vm']
vm.tag_assign("data_center/london")
```

or we can remove a category/tag from an object:

```ruby
vm = $evm.root['vm']
vm.tag_unassign("data_center/paris")
```
### Testing Whether an Object is Tagged

We can test whether an object (in this case a user group) is tagged with a particular tag:

```ruby
ci_owner = 'engineering'
groups = $evm.vmdb(:miq_group).find(:all)
groups.each do |group|
  if group.tagged_with?("department", ci_owner)
    $evm.log("info", "Group #{group.description} is tagged with department/#{ci_owner}")
  end
end
```

### Retrieving an Object's Tags

We can retrieve the list of all tags assigned to an object:

```ruby
group_tags = group.tags
```

...or the tags in a particular category (in this case using the tag name as a symbol):

```ruby
all_department_tags = group.tags(:department)
first_department_tag = group.tags(:department).first
```
Note: The ```.tags``` method returns the tags as "category/tag" strings.

### Searching for Specifically-Tagged Objects

We can search for objects tagged with a particular tag using ```.find_tagged_with```:

```ruby
tag = "/managed/department/legal"
hosts = $evm.vmdb(:host).find_tagged_with(:all => tag, :ns => "*")
```
This example shows that categories themselves are organised into namespaces behind the scenes. In practice the only namespace that seems to be in use is _/managed_ and we rarely need to specify this. The ```.find_tagged_with``` method has a slightly ambiguous past. It was present with ManageIQ _Anand_ (CFME 5.3), but returned Active Records rather than MiqAeService objects. It was unavailable from Automate with ManageIQ _Botvinnik_ (CFME 5.4), but is thankfully back with ManageIQ _Capablanca_ (CFME 5.5), and now returns service objects as expected.

<hr>
#### Practical example

We could use this to discover all infrastructure components tagged with '/department/engineering' as follows:


```ruby
tag = '/department/engineering'
[:vm_or_template, :host, :ems_cluster, :storage].each do |service_object|
  these_objects = $evm.vmdb(service_object).find_tagged_with(:all => tag, :ns => "/managed")
  these_objects.each do |this_object|
    service_object_class = "#{this_object.method_missing(:class)}".demodulize
    $evm.log("info", "#{service_object_class}: #{this_object.name} is tagged")
  end
end
```
On a small CFME 5.5 system this prints:

```
MiqAeServiceManageIQ_Providers_Redhat_InfraManager_Template: rhel7-generic is tagged
MiqAeServiceManageIQ_Providers_Redhat_InfraManager_Vm: rhel7srv010 is tagged
MiqAeServiceManageIQ_Providers_Openstack_CloudManager_Vm: rhel7srv031 is tagged
MiqAeServiceManageIQ_Providers_Redhat_InfraManager_Host: rhelh03.bit63.net is tagged
MiqAeServiceStorage: Data is tagged
```


This code snippet shows an example of where we need to work with or around dRuby. The loop:

```ruby
these_objects.each do |this_object|
  ...
end
```
enumerates through _these\_objects_, returning a dRuby client object as _this\_object_ for each pass through. Normally this is transparent to us and we can refer to the dRuby server object methods such as ```.name```, and all works as expected. 

In this case however we also wish to find the class name of the object. If we call ```this_object.class``` we get the string _DRb::DRbObject_, which is the correct class name for a dRuby client object. We have to tell dRuby to forward the ```.class``` method call on to the dRuby server (the Automate Engine running in a Generic Worker), and we do this by calling ```this_object.method_missing(:class)```. Now we get returned the full module::class name of the remote dRuby object (such as _MiqAeMethodService::MiqAeServiceStorage_), but we can call the ```.demodulize``` method on the string to strip the _MiqAeMethodService::_ module path from the name, leaving us with _MiqAeServiceStorage_.
<hr>

### Getting the List of Tag Categories

On versions prior to ManageIQ _Capablanca_ (CFME 5.5) this is slightly challenging. Both tags and categories are listed in the same _classifications_ table, but tags also have a non-zero _parent\_id_ value that ties them to their category. To find the categories from the _classifications_ table we must search for records with a parent_id of zero:

```ruby
categories = $evm.vmdb('classification').find(:all, :conditions => ["parent_id = 0"])
categories.each do |category|
  $evm.log(:info, "Found tag category: #{category.name} (#{category.description})")
end
```

With ManageIQ _Capablanca_ (CFME 5.5) we now have a ```.categories``` association directly from an MiqAeServiceClassification object, so we can say:

```ruby
$evm.vmdb(:classification).categories.each do |category|
  $evm.log(:info, "Found tag category: #{category.name} (#{category.description})")
end
```

### Getting the List of Tags in a Category

We occasionally need to retrieve the list of tags in a particular category, and for this we have to perform a double-lookup; once to get the classification ID, and again to find MiqAeServiceClassification objects with that parent_id:

```ruby
tag_classification = $evm.vmdb('classification').find_by_name('cost_centre')
cost_centre_tags = {}
$evm.vmdb('classification').find_all_by_parent_id(tag_classification.id).each do |tag|
  cost_centre_tags[tag.name] = tag.description
end
```
### Finding a Tag's Name, Given its Description

Sometimes we need to add a tag to an object, but we only have the tag's free-text description (perhaps this matches a value read from an external source). We need to find the tag's snake\_case name to use with the ```.tag_apply``` method, but we can use more Rails-syntax in our ```.find``` call to lookup two fields at once:


```ruby
department_classification = $evm.vmdb(:classification).find_by_name('department')
tag = $evm.vmdb('classification').find(:first,
									   :conditions => ["parent_id = ? AND description = ?",
									   department_classification.id, 'Systems Engineering'])
tag_name = tag.name
```

The tag names aren't in the _classifications_ table (just the tag description). When we call _tag.name_, Rails runs an implicit search of the _tags_ table for us, based on the tag.id:

```
irb(main):051:0> tag.name
  Tag Load (0.6ms)  SELECT "tags".* FROM "tags" WHERE "tags"."id" = 1000000000044 LIMIT 1
  Tag Inst Including Associations (0.1ms - 1rows)
	=> "syseng"
```

### Finding a Specific Tag (MiqAeServiceClassification) Object

We can just search for the tag object that matches a given category/tag:

```ruby
tag = $evm.vmdb(:classification).find_by_name('department/hr')
```
Note: Anything returned from $evm.vmdb(:classification) is an MiqAeServiceClassification object, not a text string.

### Deleting a Tag Category

With ManageIQ _Capablanca_ (CFME 5.5) we can now delete a tag category using the RESTful API:

```ruby
require 'rest-client'
require 'json'
require 'openssl'
require 'base64'

begin

  def rest_action(uri, verb, payload=nil)
    headers = {
      :content_type  => 'application/json',
      :accept        => 'application/json;version=2',
      :authorization => "Basic #{Base64.strict_encode64("#{@username}:#{@password}")}"
    }
    response = RestClient::Request.new(
      :method      => verb,
      :url         => uri,
      :headers     => headers,
      :payload     => payload,
      verify_ssl: false
    ).execute
    return JSON.parse(response.to_str) unless response.code.to_i == 204
  end
  
  servername   = $evm.object['servername']
  @username    = $evm.object['username']
  @password    = $evm.object.decrypt('password')

  uri_base = "https://#{servername}/api/"
  
  category = $evm.vmdb(:classification).find_by_name('network_location')
  rest_return = rest_action("#{uri_base}/categories/#{category.id}", :delete)
  exit MIQ_OK
rescue RestClient::Exception => err
  $evm.log(:error, "REST request failed, code: #{err.response.code}") unless err.response.nil?
  $evm.log(:error, "Response body:\n#{err.response.body.inspect}") unless err.response.nil?
  exit MIQ_STOP
rescue => err
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_STOP
end
```
