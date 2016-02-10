## Event Processing

One of the powerful features of CloudForms / ManageIQ is its event handling capability. CloudForms has the ability to monitor and respond to external (Provider) events, and also to raise its own events.

### Catching Events

External events are monitored by _EventCatcher_ workers, which monitor the real-time message or event busses on the various Providers - AWS:config for Amazon, AMQP/RabbitMQ for OpenStack, the native VMware Message Bus, or the RHEV-M events exposed through the RESTful API for example.

From evm.log we can see:

```
MIQ(EventCatcherOpenstack) EMS [rhosp-cont] as [admin] Caught event [compute.instance.power_on.start]
MIQ(EventCatcherOpenstack) EMS [rhosp-cont] as [admin] Caught event [compute.instance.power_on.end]
MIQ(EventCatcherRedhat) EMS [rhevm01] as [admin@internal] Caught event [USER_STARTED_VM]
MIQ(EventCatcherRedhat) EMS [rhevm01] as [admin@internal] Caught event [USER_RUN_VM]
MIQ(EventCatcherRedhat) EMS [rhevm01] as [admin@internal] Caught event [USER_INITIATED_SHUTDOWN_VM]
MIQ(EventCatcherRedhat) EMS [rhevm01] as [admin@internal] Caught event [VM_DOWN]
MIQ(EventCatcherOpenstack) EMS [rhosp-cont] as [admin] Caught event [compute.instance.power_off.start]
MIQ(EventCatcherOpenstack) EMS [rhosp-cont] as [admin] Caught event [compute.instance.power_off.end]
```

The events are passed to one or more _EventHandler_ workers:

```
MIQ(EmsEventHandler-handle_event) Processing EMS event [compute.instance.power_off.start] chain_id [0] \
	on EMS [1000000000002]...
MIQ(EmsEventHandler-handle_event) Processing EMS event [compute.instance.power_off.start] chain_id [0] \
	on EMS [1000000000002]...Complete
MIQ(EmsEventHandler-handle_event) Processing EMS event [compute.instance.power_off.end] chain_id [0] \
	on EMS [1000000000002]...
MIQ(EmsEventHandler-handle_event) Processing EMS event [compute.instance.power_off.end] chain_id [0] \
	on EMS [1000000000002]...Complete
```

### Raising Events

In addition to catching external events, CloudForms / ManageIQ can raise its own events that can be processed by Control Policies or Alerts. An example of this can be seen with the following evm.log extract. In this case an OpenStack Instance and a RHEV VM have each been powered off, and the respective Provider events _compute.instance.power\_off.end_ (OpenStack) and _USER\_STOP\_VM_ (RHEV) have been caught. For each Provider-specific event caught, the Event Handler raises the same generic _vm\_poweroff_ event that can be optionally handled by Control:

```
MIQ(EventCatcherOpenstack) EMS [rhosp-cont] as [admin] Caught event [compute.instance.power_off.end]
MIQ(Event.raise_evm_event): Event Raised [vm_poweroff]
MIQ(Event.raise_evm_event): Alert for Event [vm_poweroff]
...
MIQ(EventCatcherRedhat) EMS [rhevm01] as [admin@internal] Caught event [USER_STOP_VM]
MIQ(Event.raise_evm_event): Event Raised [vm_poweroff]
MIQ(Event.raise_evm_event): Alert for Event [vm_poweroff]
```

#### Raising Events to Automate

Automate has its own event processing mechanism. An event can be raised or delivered "to Automate", which is then handled by a correspondingly named Instance under /System/Event (or _.missing_ if the named event Instance is not found). The following extract from evm.log shows a _USER\_RUN\_VM_ event being caught and forwarded to Automate. We could optionally create a /System/Event/USER\_RUN\_VM Instance to perform Automation actions whenever this event occurred.

```
MIQ(EventCatcherRedhat) EMS [rhevm01.bit63.net] as [admin@internal] Caught event [USER_RUN_VM]
...
MIQ(EmsEventHandler-handle_event) Processing EMS event [USER_RUN_VM] chain_id [] on EMS [1000000000001]...
MIQ(Event.raise_evm_event): Event Raised [vm_start]
MIQ(Event.raise_evm_event): Alert for Event [vm_start]
MIQ(MiqAeEngine.deliver) Delivering :event_id=>1000000003170, \
	:event_type=>"USER_RUN_VM", \
	"VmOrTemplate::vm"=>1000000000029, \
	:vm_id=>1000000000029,	\
	"Host::host"=>1000000000001, \
	:host_id=>1000000000001} for object [EmsEvent.1000000003170] with state [] to Automate
<AutomationEngine> Instantiating [/System/Process/Event? \
	EmsEvent%3A%3Aems_event=1000000003170& \
	Host%3A%3Ahost=1000000000001& \
	MiqServer%3A%3Amiq_server=1000000000001& \
	VmOrTemplate%3A%3Avm=1000000000029& \
	event_id=1000000003170& \
	event_type=USER_RUN_VM& \
	host_id=1000000000001& \
	object_name=Event& \
	vm_id=1000000000029& \
	vmdb_object_type=ems_event]
<AutomationEngine> Following Relationship [miqaedb:/System/Event/USER_RUN_VM#create]
<AutomationEngine> Updated namespace [miqaedb:/System/Event/USER_RUN_VM#create  ManageIQ/System]
<AutomationEngine> Instance [/ManageIQ/System/Event/USER_RUN_VM] not found in MiqAeDatastore - trying [.missing]
<AutomationEngine> Followed  Relationship [miqaedb:/System/Event/USER_RUN_VM#create]
MIQ(EmsEventHandler-handle_event) Processing EMS event [USER_RUN_VM] chain_id [] on EMS [1000000000001]...Complete
```

The MIQ Provision Request workflow also uses raised events to control the processing sequence: 

```
MIQ(MiqProvisionRequest.call_automate_event) Raising event [request_created] to Automate
MIQ(MiqProvisionRequest.call_automate_event) Raising event [request_approved] to Automate
MIQ(MiqProvisionRequest.call_automate_event) Raising event [request_starting] to Automate
```

The next section ([Event-Driven Automation](./event_driven_automation.md)) takes a detailed look at this workflow.

