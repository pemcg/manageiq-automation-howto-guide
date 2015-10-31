## Ways of Entering Automation

So far we have launched Automation scripts in two ways; from **Simulate**, and from a **Custom Button**. Both of these methods can call an Automation Instance in either
_/System/Request_ or _/System/Event_ in the Automation Datastore, and in the examples we've seen so far we've called _/System/Request/Call\_Instance_ and _/System/Request/InspectMe_.

In fact all but one of the ways of invoking Automation must call an entry point Instance in either
_/System/Request_ or _/System/Event_; the exception being when calling Automation from the **RESTful API**, which can invoke any Instance anywhere in the Automation Datastore.

There are a further two ways that an Automation script can be launched.

### Control Policy Actions

A **Control Policy Action** can be created that launches a Custom Automation Instance.
<br> <br>

![screenshot](images/screenshot1.png?)

<br>
This can launch any Instance in _/System/Request_, but as before we can use _Call\_Instance_ to redirect the call via the in-built _rel2_ relationship to an Instance in our own Domain and Namespace.

### Alerts

An **Alert** can be created that sends a Management Event, which calls an Instance under _/System/Event_ in the Automation Datastore that corresponds to the Management Event name.
<br> <br>

![screenshot](images/screenshot2.png)

<br>
We can clone the _/System/Event_ namespace to our own domain, and add the corresponding Instance:
<br> <br>

![screenshot](images/screenshot3.png)

<br>
This Instance will now be run when the Alert is triggered.

### Writing Generic Methods

Our entry point into Automate governs the content of $evm.root - this is the object whose instantiation took us into Automate. If we write a generically useful method such as one that adds a disk to a VM, it might be useful to be able to call it in several ways, without necessarily knowing what $evm.root might contain.

For example we might wish to add a disk during the provisioning workflow for the VM; from a button on an existing VM object in the WebUI, or even from an external RESTful call into the Automate Engine (passing the VM ID as an argument). The contents of $evm.root is different in each of these cases.

For each of these cases we need to access the target VM Object in a different way, but we can use the ```$evm.root['vmdb_object_type']``` key to help us establish context...


```ruby
case $evm.root['vmdb_object_type']
when 'miq_provision'                  # called from a VM provision workflow
  vm = $evm.root['miq_provision'].destination
  ...
when 'vm'
  vm = $evm.root['vm']                # called from a button
  ...
when 'automation_task'                # called from a RESTful automation request
  attrs = $evm.root['automation_task'].options[:attrs]
  vm_id = attrs[:vm_id]
  vm = $evm.vmdb('vm').find_by_id(vm_id)
  ...
end
```
