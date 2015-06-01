## A Little Rails Knowledge (goes a long way)
CloudForms / ManageIQ is a Ruby on Rails application, and so the Automation Engine that we work in is created using Rails, but it cleverly hides most of the "Rails-ness" of the larger application from us. It is still however useful to have a slight understanding of some of the features and concepts of Rails.

### Model-View-Controller
Rails is a Model-View-Controller (MVC) application (see also [Ruby on Rails/Getting Started/Model-View-Controller](http://en.wikibooks.org/wiki/Ruby_on_Rails/Getting_Started/Model-View-Controller))

![Screenshot 1](images/general_mvc.png)

The _Model_ represents the information and the data from the database (which in the case of CloudForms/ManageIQ is PostgreSQL), and it's the models that most interest us as Automation scripters. 

Rails Models are called _Active Records_. They always have a singular _CamelCase_ name (e.g. GuestApplication), and their corresponding database tables have a plural _snake\_case_ name (e.g. guest_applications).

### Rails console
We can connect to the Rails console to have a look around. On the CloudForms appliance itself:

```
[root@cloudforms ~]# vmdb   # alias vmdb='cd /var/www/miq/vmdb/' is defined on the appliance
[root@cloudforms vmdb]# source /etc/default/evm
[root@cloudforms vmdb]# bin/rails c
Loading production environment (Rails 3.2.17)
irb(main):001:0>
```
We can use Rails object syntax to look at all hosts defined for our providers

```
irb(main):002:0> Host.all
   (3.6ms)  SELECT version()
  Host Load (0.7ms)  SELECT "hosts".* FROM "hosts"
  Host Inst (85.2ms - 2rows)
=> [#<HostRedhat id: 1000000000002, name: "rhelh02.bit63.net", hostname: "192.168.2.223", ipaddress: "192.168.2.223", vmm_vendor: "redhat", vmm_version: nil, vmm_product: "rhel", vmm_buildnumber: nil, created_on: "2015-02-05 07:59:55", updated_on: "2015-06-01 11:22:25", guid: "f8affdb4-ad0c-11e4-a994-001a4aa01599", ems_id: 1000000000001, user_assigned_os: nil, power_state: "maintenance", smart: 1, settings: nil, last_perf_capture_on: "2015-06-01 11:22:40", uid_ems: "aaad24c1-cbf6-4b00-aa82-0619da9afead", connection_state: "connected", ssh_permit_root_login: nil, ems_ref_obj: "--- /api/hosts/aaad24c1-cbf6-4b00-aa82-0619da9afead...", admin_disabled: nil, service_tag: nil, asset_tag: nil, ipmi_address: nil, mac_address: nil, type: "HostRedhat", failover: nil, ems_ref: "/api/hosts/aaad24c1-cbf6-4b00-aa82-0619da9afead", hyperthreading: nil, ems_cluster_id: 1000000000001, next_available_vnc_port: nil>, #<HostRedhat id: 1000000000001, name: "rhelh03.bit63.net", hostname: "192.168.2.224", ipaddress: "192.168.2.224", vmm_vendor: "redhat", vmm_version: nil, vmm_product: "rhel", vmm_buildnumber: nil, created_on: "2014-11-13 17:53:34", updated_on: "2015-06-01 11:22:29", guid: "fcea82c8-6b5d-11e4-98ac-001a4aa01599", ems_id: 1000000000001, user_assigned_os: nil, power_state: "on", smart: 1, settings: nil, last_perf_capture_on: "2015-06-01 11:22:40", uid_ems: "b959325b-c667-4e3a-a52e-fd936c225a1a", connection_state: "connected", ssh_permit_root_login: nil, ems_ref_obj: "--- /api/hosts/b959325b-c667-4e3a-a52e-fd936c225a1a...", admin_disabled: nil, service_tag: nil, asset_tag: nil, ipmi_address: nil, mac_address: nil, type: "HostRedhat", failover: nil, ems_ref: "/api/hosts/b959325b-c667-4e3a-a52e-fd936c225a1a", hyperthreading: nil, ems_cluster_id: 1000000000001, next_available_vnc_port: nil>]
irb(main):003:0>
```

### Rails db
Similarly we can connect to the Rails db, which puts us into a psql session.

```
[root@cloudforms ~]# vmdb 
[root@cloudforms vmdb]# source /etc/default/evm
[root@cloudforms vmdb]# bin/rails db
psql (9.2.8)
Type "help" for help.

vmdb_production=#
vmdb_production=# \d guest_devices
                                      Table "public.guest_devices"
      Column       |          Type          |                         Modifiers
-------------------+------------------------+------------------------------------------------------------
 id                | bigint                 | not null default nextval('guest_devices_id_seq'::regclass)
 device_name       | character varying(255) |
 device_type       | character varying(255) |
 location          | character varying(255) |
 filename          | character varying(255) |
 hardware_id       | bigint                 |
 mode              | character varying(255) |
 controller_type   | character varying(255) |
 size              | bigint                 |
 free_space        | bigint                 |
 size_on_disk      | bigint                 |
 address           | character varying(255) |
 switch_id         | bigint                 |
 lan_id            | bigint                 |
...
```


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
We see that there are several associations from a host object, including to the cluster that it's a member of, and to the VMs that run on that host. This makes is easy for us to traverse these relationships - something we often need to do.

### Rails Helper Methods (.find\_by\_*)
Rails does a lot of things to make our lives easier, including dynamically creating _helper methods_. The most useful ones are the find\_by\_\* methods.

```ruby
owner = $evm.vmdb('user').find_by_id( ownerid.to_i )  
vm = $evm.vmdb('vm').find_by_name(vm_name)  
vm = $evm.vmdb('vm').find_by_guid(guid)
```
We can ```.find_by_``` any table heading on a database table, so if we look at the _services_ column:

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
 
We could say ```$evm.vmdb(‘service’).find_by_service_template_id(template_id)``` if we wanted. Don't search the CloudForms sources for ```def find_by_id``` though, these are not statically defined methods.
 
 