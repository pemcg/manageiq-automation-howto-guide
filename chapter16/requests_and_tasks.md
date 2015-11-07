## Requests and Tasks

User-initiated Automation operations have two distinct stages - the **Request** and the **Task**. There are corresponding request and task objects representing these stages, each holding information relevant to the operation.

|   Operation          |   Request Object   |   Task Object   |
|:--------------------:|:------------------:|:---------------:|
|  Generic Operation   | miq_request        | miq\_request\_task  |
| Automation Request   | automation\_request | automation\_task |
| Provisioning a Host  | miq\_host\_provision\_request | miq\_host\_provision |
| Provisioning a VM    | miq\_provision\_request | miq\_provision |
| Reconfiguring a VM   | vm\_reconfigure\_request | vm\_reconfigure\_task |
| Requesting a Service | service\_template\_provision\_request | service\_template\_provision\_task |
| Reconfiguring a Service | service\_reconfigure\_request | service\_reconfigure\_task |
| Migrating a VM       | vm\_migrate\_request | vm\_migrate\_task |

In addition to those listed above, a kind of pseudo-request object is created when we add a Service Catalog Item to provision a VM. 

When we create the Catalog Item, we fill out the _Request Info_ fields, as if we were provisioning a VM interactively via the Infrastructure -> Virtual Machines -> Lifecycle -> Provision VMs menu (See [Example - Creating a Service Catalog Item](../chapter18/creating_a_service_item.md)). 

The values that we select or enter are added to the options hash in a newly created _miq\_provision\_request\_template_ object. This then serves as the "request" template for all subsequent VM provision operations from this Service Catalog Item.


|   Operation          |   "Request" Object   |   Task Object   |
|:--------------------:|:------------------:|:---------------:|
| VM Ordered from a Service Catalog Item | miq\_provision\_request\_template | miq\_provision |

### Approval
_Requests_ need to be approved before the Task is created. Admin-level users can auto-approve their own requests, while non-admin users sometimes need the request explicitly approved, depending on the Automation Request type.

The most common Automation operation that non-admin users frequently perform is to provision a VM, and for this there are approval thresholds in place (_max\_vms, max\_cpus, max\_memory, max\_retirement\_days_). VM Provision Requests specifying numbers or sizes below these thresholds are auto-approved, whereas requests exceeding these thresholds are blocked, pending approval by an admin-level user.

### Objects
If the _Request_ is approved, one or more _Task_ objects will be created from information contained in the _Request_ object (a single request for three VMs will result in three task objects for example).

If we look at the class ancestry for the _Request_ objects...

```
MiqAeServiceAutomationRequest < MiqAeServiceMiqRequest
MiqAeServiceMiqHostProvisionRequest < MiqAeServiceMiqRequest
MiqAeServiceMiqProvisionRequest < MiqAeServiceMiqRequest
MiqAeServiceMiqProvisionRequestTemplate < MiqAeServiceMiqProvisionRequest
MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceServiceTemplateProvisionRequest < MiqAeServiceMiqRequest
MiqAeServiceVmMigrateRequest < MiqAeServiceMiqRequest
MiqAeServiceVmReconfigureRequest < MiqAeServiceMiqRequest
```

...and for the _Task_ objects...

```
MiqAeServiceAutomationTask < MiqAeServiceMiqRequestTask
MiqAeServiceMiqHostProvision < MiqAeServiceMiqRequestTask
MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask
MiqAeServiceMiqProvisionAmazon < MiqAeServiceMiqProvisionCloud
MiqAeServiceMiqProvisionCloud < MiqAeServiceMiqProvision
MiqAeServiceMiqProvisionOpenstack < MiqAeServiceMiqProvisionCloud
MiqAeServiceMiqProvisionRedhat < MiqAeServiceMiqProvision
MiqAeServiceMiqProvisionRedhatViaIso < MiqAeServiceMiqProvisionRedhat
MiqAeServiceMiqProvisionRedhatViaPxe < MiqAeServiceMiqProvisionRedhat
MiqAeServiceMiqProvisionVmware < MiqAeServiceMiqProvision
MiqAeServiceMiqProvisionVmwareViaNetAppRcu < MiqAeServiceMiqProvisionVmware
MiqAeServiceMiqProvisionVmwareViaPxe < MiqAeServiceMiqProvisionVmware
MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceServiceTemplateProvisionTask < MiqAeServiceMiqRequestTask
MiqAeServiceVmReconfigureTask < MiqAeServiceMiqRequestTask
```

... we see that there are twice as many types of _Task_ object. This is because a request to perform an action (e.g. provision a VM) can be converted into one of several ways of performing the task (e.g. provision a VMware VM via PXE).

### Context

When we develop our own scripts to work with Automation, depending on the workflow stage of the operation that we're interacting with (for example provisioning a VM), we may be working with either a Request _or_ a Task object, so we sometimes have to search for one and if that fails, fallback to the other, e.g.

```ruby
prov = $evm.root['miq_provision_request'] || $evm.root['miq_provision'] \
    || $evm.root['miq_provision_request_template']
```

If we have a Request object, there may not necessarily be a Task object (yet), but if we have a Task object we can always follow an association to find the Request object that preceeded it.

Tip - when we're developing automation methods, having an understanding of whether we're running in a Request or Task context can be really useful. Think about what stage in the Automation flow the method will be running - before or after approval.

Example - we wish to set the number of VMs to be provisioned as part of a VM provisioning operation. We know that an options hash key _:number\_of\_vms_ can be set, but this appears in the options hash for both the _Task_ and _Request_ objects. (See [The Options Hash](../chapter17/options_hash.md) for more details). Where should we set it?

Answer - the _Task_ objects are created after the _Request_ is approved, and the number of VMs to be provisioned is one of the criteria that auto-approval uses to decide whether or not to approve the request. The _:number\_of\_vms_ key also determines how many _Task_ objects are created (it is the _Task_ object that contains the VM-specific options hash keys such as _:vm\_target\_name_, _:ip\_addr_, etc.) 

We must therefore set _:number\_of\_vms_ in the _Request_ options hash, **before** the _Task_ objects are created.

### Object Contents

The _Request_ object contains details about the requester (person), approval status, approver (person) and reason, and the parameters to be used for the resulting Task in the form of an _options hash_. The options hash contains  whatever optional information is required for the task to complete, and the size of the options hash depends on the Automation Request type. In the case of an _miq\_provision\_request_ the options hash has over 70 key/value pairs, specifying the characteristics of the VM to be provisioned, e.g.

```
...
miq_provision_request.options[:vlan] = ["rhevm", "rhevm"]   (type: Array)
miq_provision_request.options[:vm_auto_start] = [true, 1]   (type: Array)
miq_provision_request.options[:vm_description] = nil
miq_provision_request.options[:vm_memory] = ["2048", "2048"]   (type: Array)
miq_provision_request.options[:vm_name] = rhel7srv003   (type: String)
...
```

Much of the information in the Request object is propagated to the Task object, including the options hash.

#### Dumping the Object Contents
We can use object_walker to show the difference between an Automation Request and Task object.

Using the following walk\_association\_whitelist...

```ruby
@walk_association_whitelist = \
    { "MiqAeServiceAutomationTask" => ["automation_request", "miq_request"]}
```

...we can call the ObjectWalker from the RESTful API, using the /api/automation_requests URI.


When the Automation Instance (in this case ObjectWalker) runs, the Request has already been approved and so the Task object exists.

The Request object is reachable via an Association from the Task object...

```
automation_request = $evm.root['automation_task'].automation_request
|    (object type: MiqAeServiceAutomationRequest, object ID: 2000000000003)
|    automation_request.approval_state = approved   (type: String)
|    automation_request.created_on = 2015-06-07 09:14:03 UTC   (type: ActiveSupport::TimeWithZone)
|    automation_request.description = Automation Task   (type: String)
|    automation_request.id = 2000000000003   (type: Fixnum)
|    automation_request.message = Automation Request initiated   (type: String)
|    automation_request.options[:attrs] = {:userid=>"admin"}   (type: Hash)
|    automation_request.options[:class_name] = Methods   (type: String)
|    automation_request.options[:delivered_on] = 2015-06-07 09:14:10 UTC   (type: Time)
|    automation_request.options[:instance_name] = ObjectWalker   (type: String)
|    automation_request.options[:namespace] = Bit63/Discovery   (type: String)
|    automation_request.options[:user_id] = 2000000000001   (type: Fixnum)
|    automation_request.request_state = active   (type: String)
|    automation_request.request_type = automation   (type: String)
|    automation_request.requester_id = 2000000000001   (type: Fixnum)
|    automation_request.requester_name = Administrator   (type: String)
|    automation_request.status = Ok   (type: String)
|    automation_request.type = AutomationRequest   (type: String)
|    automation_request.updated_on = 2015-06-07 09:14:13 UTC   (type: ActiveSupport::TimeWithZone)
|    automation_request.userid = admin   (type: String)
|    --- virtual columns follow ---
|    automation_request.reason = Auto-Approved   (type: String)
|    automation_request.region_description = Region 2   (type: String)
|    automation_request.region_number = 2   (type: Fixnum)
|    automation_request.request_type_display = Automation   (type: String)
|    automation_request.resource_type = AutomationRequest   (type: String)
|    automation_request.stamped_on = 2015-06-07 09:14:04 UTC   (type: ActiveSupport::TimeWithZone)
|    automation_request.state = active   (type: String)
|    automation_request.v_approved_by = Administrator   (type: String)
|    automation_request.v_approved_by_email =    (type: String)
|    --- end of virtual columns ---
|    --- associations follow ---
|    automation_request.approvers (type: Association (empty))
|    automation_request.automation_tasks (type: Association)
|    *** not walking: 'automation_tasks' isn't in the @walk_association_whitelist hash for MiqAeServiceAutomationRequest ***
|    automation_request.destination (type: Association (empty))
|    automation_request.miq_request (type: Association)
|    *** not walking: 'miq_request' isn't in the @walk_association_whitelist hash for MiqAeServiceAutomationRequest ***
|    automation_request.miq_request_tasks (type: Association)
|    *** not walking: 'miq_request_tasks' isn't in the @walk_association_whitelist hash for MiqAeServiceAutomationRequest ***
|    automation_request.requester (type: Association)
|    *** not walking: 'requester' isn't in the @walk_association_whitelist hash for MiqAeServiceAutomationRequest ***
|    automation_request.resource (type: Association)
|    *** not walking: 'resource' isn't in the @walk_association_whitelist hash for MiqAeServiceAutomationRequest ***
|    automation_request.source (type: Association (empty))
|    --- end of associations ---
|    --- methods follow ---
|    automation_request.add_tag
|    automation_request.approve
|    automation_request.authorized?
|    automation_request.clear_tag
|    automation_request.deny
|    automation_request.description=
|    automation_request.get_classification
|    automation_request.get_classifications
|    automation_request.get_option
|    automation_request.get_option_last
|    automation_request.get_tag
|    automation_request.get_tags
|    automation_request.pending
|    automation_request.set_message
|    automation_request.set_option
|    automation_request.user_message=
|    --- end of methods ---
```

...but the Task object is available from $evm.root...


```
$evm.root['automation_task'] => #<MiqAeMethodService::MiqAeServiceAutomationTask:0x0000000800a0c0>   (type: DRb::DRbObject, URI: druby://127.0.0.1:35216)
|    $evm.root['automation_task'].created_on = 2015-06-07 09:14:10 UTC   (type: ActiveSupport::TimeWithZone)
|    $evm.root['automation_task'].description = Automation Task   (type: String)
|    $evm.root['automation_task'].id = 2000000000003   (type: Fixnum)
|    $evm.root['automation_task'].message = Automation Request initiated   (type: String)
|    $evm.root['automation_task'].miq_request_id = 2000000000003   (type: Fixnum)
|    $evm.root['automation_task'].options[:attrs] = {:userid=>"admin"}   (type: Hash)
|    $evm.root['automation_task'].options[:class_name] = Methods   (type: String)
|    $evm.root['automation_task'].options[:delivered_on] = 2015-06-07 09:14:10 UTC   (type: Time)
|    $evm.root['automation_task'].options[:instance_name] = ObjectWalker   (type: String)
|    $evm.root['automation_task'].options[:namespace] = Bit63/Discovery   (type: String)
|    $evm.root['automation_task'].options[:user_id] = 2000000000001   (type: Fixnum)
|    $evm.root['automation_task'].phase_context = {}   (type: Hash)
|    $evm.root['automation_task'].request_type = automation   (type: String)
|    $evm.root['automation_task'].state = active   (type: String)
|    $evm.root['automation_task'].status = retry   (type: String)
|    $evm.root['automation_task'].type = AutomationTask   (type: String)
|    $evm.root['automation_task'].updated_on = 2015-06-07 09:14:13 UTC   (type: ActiveSupport::TimeWithZone)
|    $evm.root['automation_task'].userid = admin   (type: String)
|    --- virtual columns follow ---
|    $evm.root['automation_task'].region_description = Region 2   (type: String)
|    $evm.root['automation_task'].region_number = 2   (type: Fixnum)
|    --- end of virtual columns ---
|    --- associations follow ---
|    $evm.root['automation_task'].automation_request (type: Association)
|    automation_request = $evm.root['automation_task'].automation_request
|    $evm.root['automation_task'].destination (type: Association (empty))
|    $evm.root['automation_task'].miq_request (type: Association)
|    miq_request = $evm.root['automation_task'].miq_request
|    |    (object type: MiqAeServiceAutomationRequest, object ID: 2000000000003)
|    |    Object MiqAeServiceAutomationRequest with ID 2000000000003 has already been dumped...
|    $evm.root['automation_task'].miq_request_task (type: Association (empty))
|    $evm.root['automation_task'].miq_request_tasks (type: Association (empty))
|    $evm.root['automation_task'].source (type: Association (empty))
|    --- end of associations ---
|    --- methods follow ---
|    $evm.root['automation_task'].add_tag
|    $evm.root['automation_task'].clear_tag
|    $evm.root['automation_task'].execute
|    $evm.root['automation_task'].finished
|    $evm.root['automation_task'].get_classification
|    $evm.root['automation_task'].get_classifications
|    $evm.root['automation_task'].get_option
|    $evm.root['automation_task'].get_option_last
|    $evm.root['automation_task'].get_tag
|    $evm.root['automation_task'].get_tags
|    $evm.root['automation_task'].message=
|    $evm.root['automation_task'].set_option
|    $evm.root['automation_task'].statemachine_task_status
|    $evm.root['automation_task'].user_message=
|    --- end of methods ---
$evm.root['automation_task_id'] = 2000000000003   (type: String)
```

We can see some interesting things...

* From the Task object, the Request object is available from either of two associations, its specific object type ```$evm.root['automation_task'].automation_request``` and the more generic ```$evm.root['automation_task'].miq_request```. These both link to the same Request object, and this is the case with all Task objects - we can always follow a ```.miq_request``` association to get back to the request, regardless of Request object type.

* We see that the Request object has several approval-specific methods that the Task object doesn't have (or need), i.e.

```
automation_request.approve
automation_request.authorized?
automation_request.deny
automation_request.pending
automation_request.message=
```

We can use these methods to implement our own approval workflow mechanism if we wish.





