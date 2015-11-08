## Using Tags from Automate
Tags are a very powerful feature of CloudForms/ManageIQ, and fortunately Automate has extensive support for tag-related operations.
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
Note that tag and category names must be lower-case (optionally) with underscores, with a maximum length of 30 characters. The tag and category descriptions can be free text.

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
We can retrieve the list of all tags assigned to an object:

```ruby
group_tags = group.tags
```

...or the tags in a particular category (in this case using the tag name as a symbol):

```ruby
all_department_tags = group.tags(:department)
first_department_tag = group.tags(:department).first
```

Getting the list of tags in a particular category is more challenging. Both tags and categories are listed in the same _classifications_ table, but tags also have a valid _parent\_id_ column that ties them to their category.

```ruby
tag_category = 'cost_centre'
tag_classification = $evm.vmdb('classification').find_by_name(tag_category)

cost_centre_tags = {}
$evm.vmdb('classification').find_all_by_parent_id(tag_classification.id).each do |tag|
  cost_centre_tags[tag.name] = tag.description
end
```

If we want to find a particular tag's name, given its description, we can use more Rails-syntax in our _find_ call to lookup two fields at once:


```ruby
department_classification = $evm.vmdb(:classification).find_by_name('department')
classification_id = department_classification.id
tag = $evm.vmdb('classification').find(:first,
									   :conditions => ["parent_id = ? AND description = ?",
									   classification_id, 'Human Resources'])
tag_name = tag.name
```

The tag names aren't in the _classifications_ table (just the tag description). When we call _tag.name_, Rails runs an implicit search of the _tags_ table for us, based on the tag.id:

```
irb(main):051:0> tag.name
  Tag Load (0.6ms)  SELECT "tags".* FROM "tags" WHERE "tags"."id" = 1000000000044 LIMIT 1
  Tag Inst Including Associations (0.1ms - 1rows)
=> "hr"
```

Finally, we can just search for a tag in a given category:

```ruby
tag = $evm.vmdb(:classification).find_by_name('department/hr')
```




