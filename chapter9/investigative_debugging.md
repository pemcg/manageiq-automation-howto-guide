## Investigative Debugging

As seen in [Working with Automation Objects](../chapter4/working_with_automation_objects.md), there is a lot of useful information in the various Service Models such as attributes, virtual columns, and associations, that we can use in our own Automation scripts. The challenge is sometimes knowing how and where to find it. Fortunately there are several ways of dumping or searching for the objects that we work with in the Automation Engine.

### InspectMe

**InspectMe** is an Instance/Method combination supplied out-of-the-box that we can call to dump some attributes of $evm.root and its associated objects. As an example we can call InspectMe from a button on a _VM and Instance_ object as we did when running our AddCustomAttribute instance in [A More Advanced Example](../chapter5/a_more_advanced_example.md). As both the Instance and Method are in the _ManageIQ/System/Request_ namespace, we can call InspectMe directly rather than calling _Call\_Instance_ as an intermediary.

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

The script is available [here](https://github.com/pemcg/object_walker), along with instructions for use.

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
Object Walker 1.6 Starting
     --- $evm.current_* details ---
     $evm.current_namespace = bit63/bit63   (type: String)
     $evm.current_class = methods   (type: String)
     $evm.current_instance = objectwalker   (type: String)
     $evm.current_message = create   (type: String)
     $evm.current_object = /bit63/bit63/methods/objectwalker   (type: DRb::DRbObject, URI: druby://127.0.0.1:56498)
     $evm.current_object.current_field_name = Execute   (type: String)
     $evm.current_object.current_field_type = method   (type: String)
     $evm.current_method = object_walker   (type: String)
     --- object hierarchy ---
     $evm.root = /ManageIQ/SYSTEM/PROCESS/Request
       $evm.parent = /ManageIQ/System/Request/call_instance
         $evm.object = /bit63/bit63/methods/objectwalker
     --- walking $evm.root ---
     $evm.root = /ManageIQ/SYSTEM/PROCESS/Request   (type: DRb::DRbObject, URI: druby://127.0.0.1:56498)
     |    --- attributes follow ---
     |    $evm.root['ae_provider_category'] = infrastructure   (type: String)
     |    $evm.root.class = DRb::DRbObject   (type: Class)
     |    $evm.root['dialog_walk_association_whitelist'] =    (type: String)
     |    $evm.root['instance'] = objectwalker   (type: String)
     |    $evm.root['miq_server'] => #<MiqAeMethodService::MiqAeServiceMiqServer:0x0000000d2b9370>   (type: DRb::DRbObject, URI: druby://127.0.0.1:56498)
     |    |    --- attributes follow ---
     |    |    $evm.root['miq_server'].build = 20150820153254_83e434d   (type: String)
     |    |    $evm.root['miq_server'].capabilities = {:vixDisk=>true, :concurrent_miqproxies=>2}   (type: Hash)
     |    |    $evm.root['miq_server'].cpu_time = 9884.0   (type: Float)
...skipping...
     |    |    $evm.root['miq_server'].version = 5.4.2.0   (type: String)
     |    |    $evm.root['miq_server'].vm_id = nil
     |    |    $evm.root['miq_server'].zone_id = 1000000000001   (type: Fixnum)
     |    |    --- end of attributes ---
     |    |    --- virtual columns follow ---
     |    |    $evm.root['miq_server'].region_description = Region 1   (type: String)
     |    |    $evm.root['miq_server'].region_number = 1   (type: Fixnum)
     |    |    $evm.root['miq_server'].zone_description = Default Zone   (type: String)
     |    |    --- end of virtual columns ---
     |    |    --- no associations ---
     |    |    --- methods follow ---
     |    |    $evm.root['miq_server'].region_name
     |    |    $evm.root['miq_server'].zone
     |    |    --- end of methods ---
...skipping...
     |    |    |    hardware.ipaddresses = ["192.168.2.171"]   (type: Array)
     |    |    |    hardware.mac_addresses = ["00:50:56:b8:00:02"]   (type: Array)
     |    |    |    hardware.region_description = Region 1   (type: String)
     |    |    |    hardware.region_number = 1   (type: Fixnum)
     |    |    |    --- end of virtual columns ---
     |    |    |    --- associations follow ---
     |    |    |    hardware.guest_devices (type: Association)
     |    |    |    hardware.guest_devices.each do |guest_device|
     |    |    |    |    (object type: MiqAeServiceGuestDevice, object ID: 1000000000016)
     |    |    |    |    --- attributes follow ---
     |    |    |    |    guest_device.address = 00:50:56:b8:00:02   (type: String)
     |    |    |    |    guest_device.auto_detect = nil
     |    |    |    |    guest_device.chap_auth_enabled = nil
     |    |    |    |    guest_device.controller_type = ethernet   (type: String)
     |    |    |    |    guest_device.device_name = Network adapter 1   (type: String)
     |    |    |    |    guest_device.device_type = ethernet   (type: String)
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
<br>
Once in the Rails console there are a number of things that we can do, such as use Rails object syntax to look at all _Host_ Active Records...

```
irb(main):002:0> Host.all
   (3.6ms)  SELECT version()
  Host Load (0.7ms)  SELECT "hosts".* FROM "hosts"
  Host Inst (85.2ms - 2rows)
=> [#<HostRedhat id: 1000000000002, name: "rhelh02.bit63.net", hostname: "192.168.2.223", ipaddress: "192.168.2.223", ...

irb(main):003:0>
```
<br>
We can even generate our own $evm variable that matches the Automation Engine default...

```ruby
$evm = MiqAeMethodService::MiqAeService.new(MiqAeEngine::MiqAeWorkspaceRuntime.new)
```
i.e.

```
irb(main):001:0> $evm = MiqAeMethodService::MiqAeService.new(MiqAeEngine::MiqAeWorkspaceRuntime.new)
   (41.6ms)  SELECT version()
  SQL (1.1ms)  SELECT "miq_ae_namespaces"."name" FROM "miq_ae_namespaces" WHERE "miq_ae_namespaces"."parent_id" IS NULL AND "miq_ae_namespaces"."enabled" = 't' AND ("miq_ae_namespaces"."name" != '$') ORDER BY priority DESC
=> #<MiqAeMethodService::MiqAeService:0x00000004a1f5c8 @drb_server_references=[], @inputs={}, @workspace=#<MiqAeEngine::MiqAeWorkspaceRuntime:0x000000048b66c8 @readonly=false, @graph=#<MiqAeEngine::MiqAeDigraph:0x000000048b6650 @v={}, @from={}, @lastid=-1>, @current=[], @num_drb_methods=0, @datastore_cache={}, @class_methods={}, @dom_search=#<MiqAeEngine::MiqAeDomainSearch:0x000000048b6538 @sorted_domains=["Tutorial", "Bit63", "RedHat", "ManageIQ"], @fqns_id_cache={}, @fqns_id_class_cache={}, @partial_ns=[]>, @persist_state_hash={}>, @preamble_lines=0, @body=[], @persist_state_hash={}>
```
<br>
George Goh has created a really useful .irbrc file that defines a $evm for us as soon as we go into the Rails Console:

```ruby
# limit output size in IRB console.
class IRB::Context
   attr_accessor :max_output_size

   alias initialize_before_max_output_size initialize
   def initialize(*args)
     initialize_before_max_output_size(*args)
     @max_output_size = IRB.conf[:MAX_OUTPUT_SIZE] || 300
   end
end

class IRB::Irb
   def output_value
     text =
       if @context.inspect?
         sprintf @context.return_format, @context.last_value.inspect
       else
         sprintf @context.return_format, @context.last_value
       end
     max = @context.max_output_size
     if text.size < max
       puts text
     else
       puts text[0..max-1] + "..." + text[-2..-1]
     end
   end
end

# Retrieve a new EVM object and set it to the $evm attribute.
def get_evm
    MiqAeMethodService::MiqAeService.new(MiqAeEngine::MiqAeWorkspaceRuntime.new)
end

$evm = get_evm
```

More details are available from https://github.com/georgegoh/cloudforms-util

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


