##$evm and the Workspace

When we program in the CloudForms Automation Engine, we access all of the CloudForms objects through a single _$evm_ variable, and for this reason it is sometimes referred to as the _Workspace_.

This variable is actually an instance of an _MiqAeService_ object (defined in _/var/www/miq/vmdb/lib/miq\_automation\_engine/engine/miq\_ae\_service.rb_ on the appliance), which contains over forty methods. In practice we generally only use a few of these methods, most commonly:

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

$evm.log is a simple method that we've used already. It writes a message to automation.log, and accepts two arguments, a log level, and the text string to write. The log level can be written as a Ruby symbol (e.g. :info, :warn), or as a text string (e.g. "info", "warn").

### $evm.root

$evm.root is a method that returns the root object in the workspace (environment, variables, linked objects etc.). This is the Instance whose invocation took us into the Automation Engine. From $evm.root hang several other Service Model objects that we can access programmatically such as $evm.root['vm'], $evm.root['user'], or $evm.root['miq_request'], (the actual objects available depend on the context of the Automation taks that we are performing).


![Object Model](images/object_model.png)


$evm.root contains a lot of useful information that we use programatically to establish our running context (for example to see if we've been called by an API call or from a button, e.g.

```
$evm.root['vmdb_object_type'] = vm   (type: String)
$evm.root['ae_provider_category'] = infrastructure   (type: String)
$evm.root['instance'] = ObjectWalker   (type: String)
$evm.root['miq_server_id'] = 1000000000001   (type: String)
$evm.root.namespace = ManageIQ/SYSTEM   (type: String)
$evm.root['object_name'] = Request   (type: String)
$evm.root['request'] = Call_Instance   (type: String)
```

(see also section xxx Investigative Debugging)

$evm.root also contains any variables that were defined on our entry into the Automation engine, such as the $evm.root['dialog_*'] variables that were defined from our service dialog.

### $evm.object ($evm.current) and $evm.parent

The $evm.object (more accurately _$evm.object(nil)_) method returns the currently instantiated instance (which can be also accessed via $evm.current). When we wanted to access our schema variable _username_, we accessed it from $evm.object['username'].

Instances can invoke or execute other instances (often via relationships), which then appear in a parent/child object relationship. In the example of calling an Automation Instance via a button on a VM object as we did when running GetCredentials:

```
$evm.object = /ACME/General/Methods/GetCredentials (the currently running instance)
$evm.parent = /ManageIQ/System/Request/Call_Instance
$evm.root = /ManageIQ/SYSTEM/PROCESS/Request
```

### $evm.vmdb

$evm.vmdb is a useful method that can be used to retrieve any _Service Model_ object (see section xxx The MiqAeService* Model). The method can be called with one or two arguments, 

When called with a single argument, the method returns the generic Service Model object type, and we can use any of the Rails helper methods (see section xxx A Little Rails Knowledge) to search by database column name, i.e.

```
vm = $evm.vmdb('vm').find_by_name(vm_name)
vm = $evm.vmdb('vm').find_by_guid(guid)
hosts = $evm.vmdb('host').find_tagged_with(:all => '/department/legal', :ns => '/managed')
all_vms = $evm.vmdb('vm_or_template').find(:all)
```

When called with two arguments, the second argument should be the Service Model ID to search for, i.e.

```
owner = $evm.vmdb('user', evm_owner_id)
```


### $evm.execute

We can use $evm.execute to call a method from _/var/www/miq/vmdb/lib/miq\_automation\_engine/service\_models/miq\_ae\_service\_methods.rb_. The usable methods are:

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
```
For example:

```ruby
unless $evm.execute('tag_exists?', 'cost_centre', '3376')
  $evm.execute('tag_create', "cost_centre", :name => '3376', :description => '3376')
end
```

### $evm.instantiate

We can use $evm.instantiate to launch another Automation Instance programmatically from a running method, e.g.

```ruby
$evm.instantiate('/Discovery/Methods/ObjectWalker')
```
Instances called in this way execute synchronously, and so our calling method waits for completion before continuing.


