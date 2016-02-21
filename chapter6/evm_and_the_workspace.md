## $evm and the Workspace

When we program with the CloudForms/ManageIQ Automation Engine, we access all of the Automation objects through a single `$evm` variable. This is sometimes referred to as the _Workspace_.

This variable is actually an instance of an `MiqAeService` object (defined in `/var/www/miq/vmdb/lib/miq_automation_engine/engine/miq_ae_service.rb` on the appliance), which contains over forty methods. In practice we generally only use a few of these methods, most commonly:

```
$evm.root
$evm.object
$evm.current (this is equivalent to calling $evm.object(nil))
$evm.log
$evm.vmdb
$evm.execute
$evm.instantiate
```

We can look at these methods in more detail.

### $evm.log

`$evm.log` is a simple method that we've used already. It writes a message to `automation.log`, and accepts two arguments, a log level, and the text string to write. The log level can be written as a Ruby symbol (e.g. `:info`, `:warn`), or as a text string (e.g. "info", "warn").

### $evm.root

`$evm.root` is the method that returns to us the root object in the workspace (environment, variables, linked objects etc.). This is the Instance whose invocation took us into the Automation Engine. From `$evm.root` we can access other Service Model objects such as `$evm.root['vm']`, `$evm.root['user']`, or `$evm.root['miq_request']`, (the actual objects available depend on the context of the Automation tasks that we are performing).


![Object Model](images/object_model.png)


`$evm.root` contains a lot of useful information that we use programatically to establish our running context (for example to see if we've been called by an API call or from a button, e.g.

```
$evm.root['vmdb_object_type'] = vm   (type: String)
...
$evm.root['ae_provider_category'] = infrastructure   (type: String)
...
$evm.root.namespace = ManageIQ/SYSTEM   (type: String)
$evm.root['object_name'] = Request   (type: String)
$evm.root['request'] = Call_Instance   (type: String)
$evm.root['instance'] = ObjectWalker   (type: String)
```

(see also [Investigative Debugging](../chapter9/investigative_debugging.md))

`$evm.root` also contains any variables that were defined on our entry into the Automation engine, such as the `$evm.root['dialog*']` variables that were defined from our service dialog.

### $evm.object, $evm.current and $evm.parent

As we saw, `$evm.root` returns to us the object representing the Instance that was launched when we entered Automate. Many Instances have schemas that contain Relationships to other Instances, and as each Relationship is followed, a new child object is created under the calling object to represent the called Instance. Fortunately we can access any of the objects in this parent-child hierarchy using `$evm.object`.

Calling `$evm.object` with no arguments returns the currently instantiated/running Instance. As Automation scripters we can think of this as "our currently running code", and this can also be accessed using the alias `$evm.current`. When we wanted to access our schema variable _username_, we accessed it using `$evm.object['username']`.

We can access our parent object (the one that called us) using `$evm.object("..")`, or the alias `$evm.parent`. 

Fact: `$evm.root` is actually an alias for `$evm.object("/")` 

When we ran our first example script, _HelloWorld_ (from Simulation), we specified an entry point of `/System/Process/Request`, and our Request was to an Instance called `Call_Instance`. We passed to this the Namespace, Class and Instance that we wanted it to run (via a Relationship).

This would have resulted in an object hierarchy (when viewed from the _hello\_world_ Method) as follows:

```
     --- object hierarchy ---
     $evm.root = /ManageIQ/SYSTEM/PROCESS/Request
       $evm.parent = /ManageIQ/System/Request/Call_Instance
         $evm.object = /ACME/General/Methods/HelloWorld
```

### $evm.vmdb

`$evm.vmdb` is a useful method that can be used to retrieve any _Service Model_ object (see [The MiqAeService* Model](../chapter4/the_miqaeservice_model.md)). The method can be called with one or two arguments, as follows.

When called with a single argument, the method returns the generic Service Model object type, and we can use any of the Rails helper methods (see [A Little Rails Knowledge](../chapter4/a_little_rails_knowledge.md)) to search by database column name, i.e.

```
vm = $evm.vmdb('vm').find_by_id(vm_id)
clusters = $evm.vmdb(:EmsCluster).find(:all)
$evm.vmdb(:VmOrTemplate).find_each do | vm |
```
The service model object name can be specified in CamelCase (e.g. 'AvailabilityZone') or snake_case (e.g. 'availability\_zone'), and can be a string or symbol.

When called with two arguments, the second argument should be the Service Model ID to search for, i.e.

```
owner = $evm.vmdb('user', evm_owner_id)
```
We can also use more advanced query syntax to return results based on multiple conditions, i.e.

```ruby
$evm.vmdb('CloudTenant').find(:first, 
							  :conditions => ["ems_id = ? AND name = ?",  src_ems_id, tenant_name])
```
Question: What's the difference between 'vm' (`:Vm`) and 'vm\_or\_template' (`:VmOrTemplate`)?

Answer: Searching for a 'vm\_or\_template' (`MiqAeServiceVmOrTemplate`) object will return VMs _or_ Templates that satisfy the search criteria, whereas search for a 'vm' object (`MiqAeServiceVm`) will only return VMs. Less obviously though, `MiqAeServiceVm` is a subclass of `MiqAeServiceVmOrTemplate` that adds 2 additional methods that are not relevant for templates: `.add_to_service` and `.remove_from_service`. 

Both `MiqAeServiceVmOrTemplate` and `MiqAeServiceVm` have a boolean attribute _template_, that is _true_ for a VMware/RHEV Template, and _false_ for a VM.


### $evm.execute

We can use `$evm.execute` to call a method from `/var/www/miq/vmdb/lib/miq_automation_engine/service_models/miq_ae_service_methods.rb`. The usable methods are:

```ruby
send_email
snmp_trap_v1
snmp_trap_v2
category_exists?
category_create
tag_exists?
tag_create
netapp_create_datastore
netapp_destroy_datastore
service_now_eccq_insert
service_now_task_get_records
service_now_task_update
service_now_task_service
create_provision_request
create_automation_request
```
For example:

```ruby
unless $evm.execute('tag_exists?', 'cost_centre', '3376')
  $evm.execute('tag_create', "cost_centre", :name => '3376', :description => '3376')
end
```

or

```ruby
to = 'pemcg@bit63.com'
from = 'cloudforms@bit63.com'
subject = 'Test Message'
body = 'What an awesome cloud management product!'
$evm.execute(:send_email, to, from, subject, body)
```

### $evm.instantiate

We can use `$evm.instantiate` to launch another Automation Instance programmatically from a running method, by specifying its URI within the Automate namespace e.g.

```ruby
$evm.instantiate('/Discovery/Methods/ObjectWalker')
```
Instances called in this way execute synchronously, so the calling method waits for completion before continuing. The called Instance also appears as a child object of the caller (it sees the caller as its `$evm.parent`).


