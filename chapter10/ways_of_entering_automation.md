## Ways of Entering Automation

So far we have launched Automation scripts in two ways; from **Simulate**, and from a **Custom Button**. Both of these methods can call an Automation Instance in either 
_/System/Request_ or _/System/Event_ in the Automation Datastore, and in the examples we've seen so far we've called _/System/Request/Call\_Instance_ and _/System/Process/InspectMe_.

In fact all but one of the ways of invoking Automation must call an entry point Instance in either 
_/System/Request_ or _/System/Event_; the exception being when calling Automation from the **RESTful API**, which can invoke any Instance anywhere in the Automation Datastore.

There is a slightly special-case when provisoning a VM interactively from the Infrastructure -> Virtual Machines -> Lifecycle -> Provision VMs menu. This always launches into Automation via the _/System/Request/UI\_Provision\_Info_ Instance.

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
We can clone the _/System/Event_ namespace to our own domain, and add the corresponding Instance
<br> <br>

![screenshot](images/screenshot3.png)

<br>
This Instance will now be run when the Alert is triggered.


