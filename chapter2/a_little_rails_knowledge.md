## A Little Rails Knowledge (goes a long way)
CloudForms / ManageIQ is a Ruby on Rails application, and so the Automation Engine that we work in is created using Rails, but it cleverly hides most of the "Rails-ness" of the larger application from us. It is still however useful to have a slight understanding of some of the features and concepts of Rails.

### Model-View-Controller
Rails is a Model-View-Controller (MVC) application (see also [Ruby on Rails/Getting Started/Model-View-Controller](http://en.wikibooks.org/wiki/Ruby_on_Rails/Getting_Started/Model-View-Controller))

![Screenshot 1](images/mvc.png?)

The _Model_ represents the information and the data from the database (which in the case of CloudForms/ManageIQ is PostgreSQL), and it's these Models that most interest us as Automation scripters.

Rails Models are called _Active Records_. They always have a singular _CamelCase_ name (e.g. GuestApplication), and their corresponding database tables have a plural _snake\_case_ name (e.g. guest_applications).

### Active Record Associations

Active Record Associations link the Models together in a way that simplifies navigating from one object to another when we access them in the Automation Engine.

We can illustrate this by looking at some of the code that defines the _Host_ Active Record:

```ruby
class Host < ActiveRecord::Base
  ...
  belongs_to                :ext_management_system, :foreign_key => "ems_id"
  belongs_to                :ems_cluster
  has_one                   :operating_system, :dependent => :destroy
  has_one                   :hardware, :dependent => :destroy
  has_many                  :vms_and_templates, :dependent => :nullify
  has_many                  :vms
  ...
```
We see that there are several associations from a host object, including to the cluster that it's a member of, and to the VMs that run on that host.

Using this knowledge makes is easy for us to traverse these relationships - something we often need to do when writing our own Automation scripts.

### Rails Helper Methods (.find\_by\_*)
Rails does a lot of things to make our lives easier, including dynamically creating _helper methods_. The most useful ones are the find\_by\_\* methods.

```ruby
owner = $evm.vmdb('user').find_by_id( ownerid.to_i )
vm = $evm.vmdb('vm').find_by_name(vm_name)
vm = $evm.vmdb('vm').find_by_guid(guid)
```
We can ```.find_by_``` any table heading on a database table, so if we look at the _services_ column...

```
vmdb_production=# \d services
                                          Table "public.services"
        Column        |            Type             |                       Modifiers
----------------------+-----------------------------+-------------------------------------------------------
 id                   | bigint                      | not null default nextval('services_id_seq'::regclass)
 name                 | character varying(255)      |
 description          | character varying(255)      |
 guid                 | character varying(255)      |
 type                 | character varying(255)      |
 service_template_id  | bigint                      |
 options              | text                        |
 display              | boolean
 ...
```

...we see that we could call...

```ruby
$evm.vmdb('service').find_by_service_template_id(template_id)
```

...if we wanted.

Tip - don't try searching the CloudForms sources for ```def find_by_id``` though, these are not statically defined methods and so don't exist in the CloudForms code.


