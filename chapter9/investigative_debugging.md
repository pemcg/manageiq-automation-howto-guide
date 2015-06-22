## Investigative Debugging

As seen in [Associations in Practice](## Associations in Practice), there is a lot of useful information in the various Service Models, attributes and associations, that we can use in our own Automation scripts. The challenge is sometimes knowing how and where to find it. Fortunately there are several ways of dumping or searching for the objects that we work with in the Automate Engine.

### InspectMe

**InspectMe** is an Instance/Method combination supplied out-of-the-box that we can call to dump some attributes of $evm.root and its associated objects. As an example we can call InspectMe from a button on a _VM and Instance_ object as we did when running our AddCustomAttribute instance in [A More Advanced Example](## A More Advanced Example). As both the Instance and Method are in the _ManageIQ/System/Request_ namespace, we can call InspectMe directly rather than calling _Call\_Instance_ as an intermediary.

We can view the results of the InspectMe dump in automation.log...

```
[root@cloudforms ~]# vmdb
[root@cloudforms vmdb]# grep inspectme log/automation.log | awk 'FS="INFO -- :" {print $2}'
 <AEMethod inspectme> Root:<$evm.root> Attributes - Begin
 <AEMethod inspectme>   Attribute - ae_provider_category: infrastructure
 <AEMethod inspectme>   Attribute - miq_server: #<MiqAeMethodService::MiqAeServiceMiqServer:0x0000000b85ac90>
 <AEMethod inspectme>   Attribute - miq_server_id: 1000000000001
 <AEMethod inspectme>   Attribute - object_name: Request
 <AEMethod inspectme>   Attribute - request: InspectMe
 <AEMethod inspectme>   Attribute - user: #<MiqAeMethodService::MiqAeServiceUser:0x0000000b86b540>
 <AEMethod inspectme>   Attribute - user_id: 1000000000001
 <AEMethod inspectme>   Attribute - vm: rhel7srv001
 <AEMethod inspectme>   Attribute - vm_id: 1000000000025
 <AEMethod inspectme>   Attribute - vmdb_object_type: vm
 <AEMethod inspectme> Root:<$evm.root> Attributes - End
 <AEMethod inspectme>
 <AEMethod inspectme> key:<miq_server>  object:<#<MiqAeMethodService::MiqAeServiceMiqServer:0x0000000b85ac90>>
 <AEMethod inspectme>   Begin Attributes [object.attributes]
 <AEMethod inspectme>     build = "20150108100920_387a856"
 ...
```

Kevin Morey has written a greatly enhanced version of InspectMe, available from [here](https://github.com/ramrexx/CloudFormsPOC/blob/master/Automate/CloudFormsPOC/System/Request.class/__methods__/inspectme.rb).

### object_walker

**object\_walker** is a slightly more dynamic tool that walks and dumps the objects, attributes and virtual columns of $evm.root and its immediate objects, but also recursively traverses associations to walk and dump any objects that it finds. It prints the output in a Ruby-like syntax that can be copied and pasted directly into an Automation script to access or walk the same path.

The script is available from [here](https://github.com/pemcg/object_walker), along with instructions for use.

#### Black or Whitelisting Associations

One of the features of object\_walker is the ability to be able to selectively choose which associations to "walk" to limit the output. This is selected by setting a _@walk\_association\_policy_ to _:whitelist_ or _:blacklist_, and then defining a _@walk\_association\_whitelist_ or _@walk\_association\_blacklist_ to list the associations to be walked (whitelist), or not walked (blacklist).

In practice a _@walk\_association\_policy_ of _:blacklist_ produces so much output that it's rarely used, and so a _:whitelist_ is more often defined, e.g.

```ruby
@walk_association_whitelist = { "MiqAeServiceVmRedhat" => ["hardware", "host", "storage"],
                                "MiqAeServiceVmVmware" => ["hardware", "host", "storage"],
                                "MiqAeServiceHardware" => ["nics", "guest_devices", "ports", "storage_adapters" ],
                                "MiqAeServiceGuestDevice" => ["hardware", "lan", "network"] }
```

#### object\_walker\_reader
There is a companion _object\_walker\_reader_ script that can be copied to the CloudForms appliance to extract the object\_walker dumps from automation.log, list the dumps, and even _diff_ two dumps - useful when running object\_walker before and after a built-in method (for example in a State Machine) to see what the method has changed.

```
[root@cloudforms ~]# ~/object_walker_reader.rb
object_walker 1.5-2 - EVM Automate Method Started
     object_walker:   $evm.current_namespace = Bit63/General   (type: String)
     object_walker:   $evm.current_class = Methods   (type: String)
     object_walker:   $evm.current_instance = ObjectWalker   (type: String)
     object_walker:   $evm.current_message = create   (type: String)
     object_walker:   $evm.current_object = /Bit63/General/Methods/ObjectWalker   (type: DRb::DRbObject, URI: druby://127.0.0.1:56027)
     object_walker:   $evm.current_object.current_field_name = execute   (type: String)
     object_walker:   $evm.current_object.current_field_type = method   (type: String)
     object_walker:   $evm.current_method = object_walker   (type: String)
     object_walker:   $evm.root = /ManageIQ/SYSTEM/PROCESS/Request   (type: DRb::DRbObject, URI: druby://127.0.0.1:56027)
     object_walker:   $evm.root['ae_provider_category'] = infrastructure   (type: String)
     object_walker:   $evm.root.class = DRb::DRbObject   (type: Class)
     object_walker:   $evm.root['instance'] = ObjectWalker   (type: String)
     object_walker:   $evm.root['miq_server'] => #<MiqAeMethodService::MiqAeServiceMiqServer:0x0000000a948180>   (type: DRb::DRbObject, URI: druby://127.0.0.1:56027)
     |    object_walker:   $evm.root['miq_server'].build = 20150108100920_387a856   (type: String)
     |    object_walker:   $evm.root['miq_server'].capabilities = {:vixDisk=>true, :concurrent_miqproxies=>2}   (type: Hash)
     |    object_walker:   $evm.root['miq_server'].cpu_time = 15221.0   (type: Float)
     |    object_walker:   $evm.root['miq_server'].drb_uri = druby://127.0.0.1:43128   (type: String)
...
     |    object_walker:   $evm.root['user'].region_number = 1   (type: Fixnum)
     |    object_walker:   --- end of virtual columns ---
     |    object_walker:   --- associations follow ---
     |    object_walker:   $evm.root['user'].current_group (type: Association)
     |    object_walker:   current_group = $evm.root['user'].current_group
     |    |    object_walker:   (object type: MiqAeServiceMiqGroup, object ID: 1000000000001)
     |    |    object_walker:   current_group.created_on = 2014-11-13 17:41:16 UTC   (type: ActiveSupport::TimeWithZone)
     |    |    object_walker:   current_group.description = EvmGroup-super_administrator   (type: String)
     |    |    object_walker:   current_group.filters = nil
     |    |    object_walker:   current_group.group_type = system   (type: String)
     |    |    object_walker:   current_group.guid = 44d8d21c-6b5c-11e4-b699-001a4aa01599   (type: String)
...
```



### Rails console

We can connect to the Rails console to have a look around. On the CloudForms appliance itself:

```
[root@cloudforms ~]# vmdb   # alias vmdb='cd /var/www/miq/vmdb/' is defined on the appliance
[root@cloudforms vmdb]# source /etc/default/evm
[root@cloudforms vmdb]# bin/rails c
Loading production environment (Rails 3.2.17)
irb(main):001:0>
```
Once in the Rails console there are a number of things that we can do, such as use Rails object syntax to look at all _Host_ Active Records...

```
irb(main):002:0> Host.all
   (3.6ms)  SELECT version()
  Host Load (0.7ms)  SELECT "hosts".* FROM "hosts"
  Host Inst (85.2ms - 2rows)
=> [#<HostRedhat id: 1000000000002, name: "rhelh02.bit63.net", hostname: "192.168.2.223", ipaddress: "192.168.2.223", vmm_vendor: "redhat", vmm_version: nil, vmm_product: "rhel", vmm_buildnumber: nil, created_on: "2015-02-05 07:59:55", updated_on: "2015-06-01 11:22:25", guid: "f8affdb4-ad0c-11e4-a994-001a4aa01599", ems_id: 1000000000001, user_assigned_os: nil, power_state: "maintenance", smart: 1, settings: nil, last_perf_capture_on: "2015-06-01 11:22:40", uid_ems: "aaad24c1-cbf6-4b00-aa82-0619da9afead", connection_state: "connected", ssh_permit_root_login: nil, ems_ref_obj: "--- /api/hosts/aaad24c1-cbf6-4b00-aa82-0619da9afead...", admin_disabled: nil, service_tag: nil, asset_tag: nil, ipmi_address: nil, mac_address: nil, type: "HostRedhat", failover: nil, ems_ref: "/api/hosts/aaad24c1-cbf6-4b00-aa82-0619da9afead", hyperthreading: nil, ems_cluster_id: 1000000000001, next_available_vnc_port: nil>, #<HostRedhat id: 1000000000001, name: "rhelh03.bit63.net", hostname: "192.168.2.224", ipaddress: "192.168.2.224", vmm_vendor: "redhat", vmm_version: nil, vmm_product: "rhel", vmm_buildnumber: nil, created_on: "2014-11-13 17:53:34", updated_on: "2015-06-01 11:22:29", guid: "fcea82c8-6b5d-11e4-98ac-001a4aa01599", ems_id: 1000000000001, user_assigned_os: nil, power_state: "on", smart: 1, settings: nil, last_perf_capture_on: "2015-06-01 11:22:40", uid_ems: "b959325b-c667-4e3a-a52e-fd936c225a1a", connection_state: "connected", ssh_permit_root_login: nil, ems_ref_obj: "--- /api/hosts/b959325b-c667-4e3a-a52e-fd936c225a1a...", admin_disabled: nil, service_tag: nil, asset_tag: nil, ipmi_address: nil, mac_address: nil, type: "HostRedhat", failover: nil, ems_ref: "/api/hosts/b959325b-c667-4e3a-a52e-fd936c225a1a", hyperthreading: nil, ems_cluster_id: 1000000000001, next_available_vnc_port: nil>]
irb(main):003:0>
```

We can even generate our own $evm variable that matches the Automation Engine default...

```
irb(main):001:0> $evm = MiqAeMethodService::MiqAeService.new(MiqAeEngine::MiqAeWorkspaceRuntime.new)
   (41.6ms)  SELECT version()
  SQL (1.1ms)  SELECT "miq_ae_namespaces"."name" FROM "miq_ae_namespaces" WHERE "miq_ae_namespaces"."parent_id" IS NULL AND "miq_ae_namespaces"."enabled" = 't' AND ("miq_ae_namespaces"."name" != '$') ORDER BY priority DESC
=> #<MiqAeMethodService::MiqAeService:0x00000004a1f5c8 @drb_server_references=[], @inputs={}, @workspace=#<MiqAeEngine::MiqAeWorkspaceRuntime:0x000000048b66c8 @readonly=false, @graph=#<MiqAeEngine::MiqAeDigraph:0x000000048b6650 @v={}, @from={}, @lastid=-1>, @current=[], @num_drb_methods=0, @datastore_cache={}, @class_methods={}, @dom_search=#<MiqAeEngine::MiqAeDomainSearch:0x000000048b6538 @sorted_domains=["Tutorial", "Bit63", "RedHat", "ManageIQ"], @fqns_id_cache={}, @fqns_id_class_cache={}, @partial_ns=[]>, @persist_state_hash={}>, @preamble_lines=0, @body=[], @persist_state_hash={}>
```

### Rails db

It is occasionaly useful to be able to examine some of the database tables (such as to look for column headers that we can find\_by\_* on). We can connect to Rails db, which puts us directly into a psql session...

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
