## Requests and Tasks

Many Automation operations have two distinct stages - the **Request** and the **Task**. There are corresponding request and task objects representing these stages, each holding information relevant to the operation.

|   Operation          |   Request Object   |   Task Object   |
|:--------------------:|:------------------:|:---------------:|
|  Generic Operation   | miq_request        | miq\_request\_task  |
| Automation Request   | automation\_request | automation\_task |
| Provisioning a Host  | miq\_host\_provision\_request | miq\_host\_provision |
| Provisioning a VM    | miq\_provision\_request | miq\_provision |
| Provisioning a VM from Template | miq\_provision\_request\_template | miq\_provision |
| Reconfiguring a VM   | vm\_reconfigure\_request | vm\_reconfigure\_task |
| Requesting a Service | service\_template\_provision\_request | service\_template\_provision\_task |
| Migrating a VM       | vm\_migrate\_request | vm\_migrate\_task |

If the _Request_ is approved, one or more _Task_ objects will be created from information contained in the _Request_ object.

If we look at the class ancestry for the _Request_ objects...

```
MiqAeServiceAutomationRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceMiqHostProvisionRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceMiqProvisionRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceMiqProvisionRequestTemplate < MiqAeServiceMiqProvisionRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceServiceTemplateProvisionRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceVmMigrateRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceVmReconfigureRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
```

...and for the _Task_ objects...

```
MiqAeServiceAutomationTask < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqHostProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionAmazon < MiqAeServiceMiqProvisionCloud < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionCloud < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionOpenstack < MiqAeServiceMiqProvisionCloud < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionRedhat < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionRedhatViaIso < MiqAeServiceMiqProvisionRedhat < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionRedhatViaPxe < MiqAeServiceMiqProvisionRedhat < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionVmware < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionVmwareViaNetAppRcu < MiqAeServiceMiqProvisionVmware < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionVmwareViaPxe < MiqAeServiceMiqProvisionVmware < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceServiceTemplateProvisionTask < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceVmMigrateTask < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceVmReconfigureTask < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
```

... we see that there are twice as many types of _Task_ object. This is because a request to perform an action (e.g. provision a VM) can be converted into one of several ways of performing the task (e.g. provision a VMware VM via PXE).

When we develop our own scripts to work with Automation, depending on the workflow stage of the operation that we're interacting with (for example provisioning a VM), we may be working with either a Request _or_ a Task object, so we sometimes have to search for one and if that fails, fallback to the other, e.g.

```ruby
prov = $evm.root['miq_provision_request'] || $evm.root['miq_provision'] || $evm.root['miq_provision_request_template']
```

If we have a Request object, there may not necessarily be a Task object (yet), but if we have a Task object we can always follow an association to find the Request object that preceeded it. 

### Object Contents

The _Request_ object contains details about the requester (person), approval status, approver (person) and reason, and the parameters to be used for the resulting Task in the form of an _options hash_.

We can use object_walker to show the difference between an Automation Request and Task object.

Using the following walk\_association\_whitelist...

```ruby
@walk_association_whitelist = { "MiqAeServiceAutomationTask" => ["automation_request", "miq_request"]}
```

...we can call ObjectWalker from the RESTful API, using the /api/automation_requests URI.


When the Automation Instance (in this case ObjectWalker) runs, the Request has already been approved and so the Task object exists.

The Request object is reachable via an Association from the Task object...

```
object_walker:   automation_request = $evm.root['automation_task'].automation_request
|    object_walker:   (object type: MiqAeServiceAutomationRequest, object ID: 2000000000003)
|    object_walker:   automation_request.approval_state = approved   (type: String)
|    object_walker:   automation_request.created_on = 2015-06-07 09:14:03 UTC   (type: ActiveSupport::TimeWithZone)
|    object_walker:   automation_request.description = Automation Task   (type: String)
|    object_walker:   automation_request.id = 2000000000003   (type: Fixnum)
|    object_walker:   automation_request.message = Automation Request initiated   (type: String)
|    object_walker:   automation_request.options[:attrs] = {:userid=>"admin"}   (type: Hash)
|    object_walker:   automation_request.options[:class_name] = Methods   (type: String)
|    object_walker:   automation_request.options[:delivered_on] = 2015-06-07 09:14:10 UTC   (type: Time)
|    object_walker:   automation_request.options[:instance_name] = ObjectWalker   (type: String)
|    object_walker:   automation_request.options[:namespace] = Bit63/Discovery   (type: String)
|    object_walker:   automation_request.options[:user_id] = 2000000000001   (type: Fixnum)
|    object_walker:   automation_request.request_state = active   (type: String)
|    object_walker:   automation_request.request_type = automation   (type: String)
|    object_walker:   automation_request.requester_id = 2000000000001   (type: Fixnum)
|    object_walker:   automation_request.requester_name = Administrator   (type: String)
|    object_walker:   automation_request.status = Ok   (type: String)
|    object_walker:   automation_request.type = AutomationRequest   (type: String)
|    object_walker:   automation_request.updated_on = 2015-06-07 09:14:13 UTC   (type: ActiveSupport::TimeWithZone)
|    object_walker:   automation_request.userid = admin   (type: String)
|    object_walker:   --- virtual columns follow ---
|    object_walker:   automation_request.reason = Auto-Approved   (type: String)
|    object_walker:   automation_request.region_description = Region 2   (type: String)
|    object_walker:   automation_request.region_number = 2   (type: Fixnum)
|    object_walker:   automation_request.request_type_display = Automation   (type: String)
|    object_walker:   automation_request.resource_type = AutomationRequest   (type: String)
|    object_walker:   automation_request.stamped_on = 2015-06-07 09:14:04 UTC   (type: ActiveSupport::TimeWithZone)
|    object_walker:   automation_request.state = active   (type: String)
|    object_walker:   automation_request.v_approved_by = Administrator   (type: String)
|    object_walker:   automation_request.v_approved_by_email =    (type: String)
|    object_walker:   --- end of virtual columns ---
|    object_walker:   --- associations follow ---
|    object_walker:   automation_request.approvers (type: Association (empty))
|    object_walker:   automation_request.automation_tasks (type: Association)
|    object_walker:   *** not walking: 'automation_tasks' isn't in the @walk_association_whitelist hash for MiqAeServiceAutomationRequest ***
|    object_walker:   automation_request.destination (type: Association (empty))
|    object_walker:   automation_request.miq_request (type: Association)
|    object_walker:   *** not walking: 'miq_request' isn't in the @walk_association_whitelist hash for MiqAeServiceAutomationRequest ***
|    object_walker:   automation_request.miq_request_tasks (type: Association)
|    object_walker:   *** not walking: 'miq_request_tasks' isn't in the @walk_association_whitelist hash for MiqAeServiceAutomationRequest ***
|    object_walker:   automation_request.requester (type: Association)
|    object_walker:   *** not walking: 'requester' isn't in the @walk_association_whitelist hash for MiqAeServiceAutomationRequest ***
|    object_walker:   automation_request.resource (type: Association)
|    object_walker:   *** not walking: 'resource' isn't in the @walk_association_whitelist hash for MiqAeServiceAutomationRequest ***
|    object_walker:   automation_request.source (type: Association (empty))
|    object_walker:   --- end of associations ---
|    object_walker:   --- methods follow ---
|    object_walker:   automation_request.add_tag
|    object_walker:   automation_request.approve
|    object_walker:   automation_request.authorized?
|    object_walker:   automation_request.clear_tag
|    object_walker:   automation_request.deny
|    object_walker:   automation_request.description=
|    object_walker:   automation_request.get_classification
|    object_walker:   automation_request.get_classifications
|    object_walker:   automation_request.get_option
|    object_walker:   automation_request.get_option_last
|    object_walker:   automation_request.get_tag
|    object_walker:   automation_request.get_tags
|    object_walker:   automation_request.pending
|    object_walker:   automation_request.set_message
|    object_walker:   automation_request.set_option
|    object_walker:   automation_request.user_message=
|    object_walker:   --- end of methods ---
```

...but the Task object is available from $evm.root...


```
object_walker:   $evm.root['automation_task'] => #<MiqAeMethodService::MiqAeServiceAutomationTask:0x0000000800a0c0>   (type: DRb::DRbObject, URI: druby://127.0.0.1:35216)
|    object_walker:   $evm.root['automation_task'].created_on = 2015-06-07 09:14:10 UTC   (type: ActiveSupport::TimeWithZone)
|    object_walker:   $evm.root['automation_task'].description = Automation Task   (type: String)
|    object_walker:   $evm.root['automation_task'].id = 2000000000003   (type: Fixnum)
|    object_walker:   $evm.root['automation_task'].message = Automation Request initiated   (type: String)
|    object_walker:   $evm.root['automation_task'].miq_request_id = 2000000000003   (type: Fixnum)
|    object_walker:   $evm.root['automation_task'].options[:attrs] = {:userid=>"admin"}   (type: Hash)
|    object_walker:   $evm.root['automation_task'].options[:class_name] = Methods   (type: String)
|    object_walker:   $evm.root['automation_task'].options[:delivered_on] = 2015-06-07 09:14:10 UTC   (type: Time)
|    object_walker:   $evm.root['automation_task'].options[:instance_name] = ObjectWalker   (type: String)
|    object_walker:   $evm.root['automation_task'].options[:namespace] = Bit63/Discovery   (type: String)
|    object_walker:   $evm.root['automation_task'].options[:user_id] = 2000000000001   (type: Fixnum)
|    object_walker:   $evm.root['automation_task'].phase_context = {}   (type: Hash)
|    object_walker:   $evm.root['automation_task'].request_type = automation   (type: String)
|    object_walker:   $evm.root['automation_task'].state = active   (type: String)
|    object_walker:   $evm.root['automation_task'].status = retry   (type: String)
|    object_walker:   $evm.root['automation_task'].type = AutomationTask   (type: String)
|    object_walker:   $evm.root['automation_task'].updated_on = 2015-06-07 09:14:13 UTC   (type: ActiveSupport::TimeWithZone)
|    object_walker:   $evm.root['automation_task'].userid = admin   (type: String)
|    object_walker:   --- virtual columns follow ---
|    object_walker:   $evm.root['automation_task'].region_description = Region 2   (type: String)
|    object_walker:   $evm.root['automation_task'].region_number = 2   (type: Fixnum)
|    object_walker:   --- end of virtual columns ---
|    object_walker:   --- associations follow ---
|    object_walker:   $evm.root['automation_task'].automation_request (type: Association)
|    object_walker:   automation_request = $evm.root['automation_task'].automation_request
|    object_walker:   $evm.root['automation_task'].destination (type: Association (empty))
|    object_walker:   $evm.root['automation_task'].miq_request (type: Association)
|    object_walker:   miq_request = $evm.root['automation_task'].miq_request
|    |    object_walker:   (object type: MiqAeServiceAutomationRequest, object ID: 2000000000003)
|    |    object_walker:   Object MiqAeServiceAutomationRequest with ID 2000000000003 has already been dumped...
|    object_walker:   $evm.root['automation_task'].miq_request_task (type: Association (empty))
|    object_walker:   $evm.root['automation_task'].miq_request_tasks (type: Association (empty))
|    object_walker:   $evm.root['automation_task'].source (type: Association (empty))
|    object_walker:   --- end of associations ---
|    object_walker:   --- methods follow ---
|    object_walker:   $evm.root['automation_task'].add_tag
|    object_walker:   $evm.root['automation_task'].clear_tag
|    object_walker:   $evm.root['automation_task'].execute
|    object_walker:   $evm.root['automation_task'].finished
|    object_walker:   $evm.root['automation_task'].get_classification
|    object_walker:   $evm.root['automation_task'].get_classifications
|    object_walker:   $evm.root['automation_task'].get_option
|    object_walker:   $evm.root['automation_task'].get_option_last
|    object_walker:   $evm.root['automation_task'].get_tag
|    object_walker:   $evm.root['automation_task'].get_tags
|    object_walker:   $evm.root['automation_task'].message=
|    object_walker:   $evm.root['automation_task'].set_option
|    object_walker:   $evm.root['automation_task'].statemachine_task_status
|    object_walker:   $evm.root['automation_task'].user_message=
|    object_walker:   --- end of methods ---
object_walker:   $evm.root['automation_task_id'] = 2000000000003   (type: String)
```

We can look at these two objects to infer some interesting things:



