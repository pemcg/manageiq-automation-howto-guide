## The Service Provisioning State Machine

The Service Provisioning State Machine (Class _ServiceProvision\_Template_) controls the sequence of steps involved in provisioning the service.

![screenshot](images/screenshot8.png)

The _ServiceProvision\_Template_ Class schema contains a number of States, as shown (illustrated is the _default_ Instance of this State Machine)...
<br>

![screenshot](images/screenshot4.png)

<br>
As can be seen, most of the fields are _pre_ and _post_ placeholders around the main _provision_ and _checkprovisioned_ states, to allow for optional processing if required. The _configurechilddialog_ state (by default commented out) can be used to populate the options[:dialog] hash in the child task if required.

### Passing Service Dialog Options to the Child and Grandchild Tasks

One of the more complex tasks that must be achieved by some state in the Service Provisioning State Machine is to pass the values received from the Service Dialog (if there is one), to the actual Tasks performing the provisioning of the VM(s). The complexity arises from the multiple types of Task object that are involved in creating the Service, the Service Resources, and the actual VMs.

<br> <br>
![task hierachy](images/task_hierarchy.png?)
<br> <br>

This object hierarchy is represented at the highest level by the Service Template Provisioning Task (which we access from ```$evm.root['service_template_provision_task']```). 

The Service Template Provisioning Task has an assocation, _miq\_request\_tasks_, containing the _miq\_request\_task_ objects representing the creation of the _service resource(s)_, which are items or resources making up the service request (even a single service catalog item is treated as a bundle containing one service resource).

Each _child_ (service resource) miq\_request\_task also has an _miq\_request\_tasks_ assocation  containing the VM Provisioning Tasks associated with creating the actual VMs for the service resource. This _miq\_request\_task_ is provider-specific.

It is to the second level of miq\_request\_task (also known as the _grandchild task_) that we must pass the Service Dialog values that affect the provisioning of the VM (such as _:vm\_memory_ or _:vm\_target\_name_).

(see [Service Objects](service_objects.md) for more details of the service object structure)

### Accessing the Service Dialog Options

If a service dialog has been used in the creation of an Automation request (either from a Button or from a Service), then the key/value pairs from the service dialog are added to the Request and subsequent Task objects both as individual keys accessible from $evm.root, and to the Task object's options hash as the _:dialog_ key.

```ruby
$evm.root['service_template_provision_task'].options[:dialog] = \
	 {"dialog_option_0_service_name"=>"New Server", \
	 "dialog_option_0_service_description"=>"My New Server", \
	 "dialog_option_0_vm_name"=>"rhel7srv023", \
	 "dialog_tag_0_department"=>"engineering", \
	 "request"=>"clone_to_service"}
```

or

```ruby
$evm.root['dialog_option_0_service_description'] = My New Server
$evm.root['dialog_option_0_service_name'] = New Server
$evm.root['dialog_option_0_vm_name'] = rhel7srv023
$evm.root['dialog_tag_0_department'] = engineering
```

Accessing the dialog options from options[:dialog] is easier when we don't necessarily know the option name.

When we have several generations of child _Task_ object (as we do when provisioning VMs from a service), we also need to pass the dialog options from the parent object (the Service Template Provision Task), to the various child objects, otherwise they won't be visible to the children.

The key/value pairs from the service dialog can be inserted into the options[:dialog] hash of a child Task object, using the ```.set_dialog_option``` method...

```ruby
stp_task = $evm.root["service_template_provision_task"]
vm_size = $evm.root['dialog_vm_size']
stp_task.miq_request_tasks.each do |child_task|
  case vm_size
  when "Small"
    memory_size = 4096
  when "Large"
    memory_size = 8192
  end
  child_task.set_dialog_option('dialog_memory', memory_size)
end
```

This enables the child and grandchild VM Provision workflows (which run through the standard VM Provision State Machine that we have already studied) to access their own Task object options[:dialog] hash, and set the custom provisioning options accordingly.





