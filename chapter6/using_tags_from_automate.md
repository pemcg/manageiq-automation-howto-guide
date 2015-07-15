## Using Tags from Automate
Tags are a very powerful feature of CloudForms, and fortunately Automate has extensive support for tag-related operations.
Tags are defined and used within the context of tag _categories_. We can check whether a category exists, and if not create it...

```ruby
unless $evm.execute('category_exists?', "data_centre")
  $evm.execute('category_create', :name => "data_centre", \
               :single_value => false, :description => "Data Centre")
end
```
We can also check whether a tag exists within a category, and if not create it...

```ruby
unless $evm.execute('tag_exists?', 'data_centre', 'london')
  $evm.execute('tag_create', "data_centre", :name => 'london', \
                :description => 'London East End')
end
```
Note that tag and category names must be lower-case (optionally) with underscores, with a maximum length of 30 characters. The tag and category descriptions can be free text.

We can assign a category/tag to an object (in this case a VM)...

```ruby
vm = $evm.root['vm']
vm.tag_assign("data_center/london")
```

We can test whether an object (in this case a user group) is tagged with a particular tag...

```ruby
ci_owner = 'engineering'
groups = $evm.vmdb(:miq_group).find(:all)
groups.each do |group|
  if group.tagged_with?("department", ci_owner)
    $evm.log("info", "Group #{group.description} is tagged with department/#{ci_owner}")
  end
end
```
We can retrieve the list of all tags assigned to an object...

```ruby
group_tags = group.tags
```

...or the first tag in a particular category (in this case using the tag name as a symbol)...

```ruby
department_tag = group.tags(:department).first
```
We can search for all objects tagged with a particular tag...

```ruby
tag = "/managed/department/legal"
hosts = $evm.vmdb(:host).find_tagged_with(:all => tag, :ns => "*")
```
This example uses a method defined in Rails rather than the automation engine, and shows that categories themselves are organised into namespaces behind the scenes. In practice the only namespace that seems to be in use is _/managed_ and we rarely need to specify this. This method also doesn't return MiqAeService* objects, but Rails Active Records so there's a limited number of operations that we can perform on the returned list. We can pull out _.name_  from each item though, which is often all that we want, i.e.

```ruby
tag = "/department/legal"
hosts = $evm.vmdb(:host).find_tagged_with(:all => tag, :ns => "/managed")
hosts.each do |host|
  $evm.log("info", "Host: #{host.name} is tagged with #{tag}")
end
```

Getting the list of tags in a particular category is more challenging. Both tags and categories are listed in the same _classification_ table, but tags also have a valid _parent\_id_ column that ties them to their category.

```ruby
tag_category = 'cost_centre'
tag_classification = $evm.vmdb('classification').find_by_name(tag_category)

cost_centre_tags = {}
$evm.vmdb('classification').find_all_by_parent_id(tag_classification.id).each do |tag|
  cost_centre_tags[tag.name] = tag.description
end
```
