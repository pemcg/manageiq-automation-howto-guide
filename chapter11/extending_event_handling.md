## Extending Automate Event Handling

As seen in [Event Processing](./event_processing.md), we can create our own Instances under /System/Event to handle events raised to Automate, that are not handled by default.

As an example the _compute.instance.power\_on.end_ OpenStack event is not handled by default (this is probably a bug that will be fixed soon). As a result, the Cloud Instance's tile quadrant in the WebUI that shows power status doesn't change to reflect the Instance being powered on.

We can override this behaviour in either of two ways.

### Adding a New Automation Instance to /System/Event

We can add a new Automate Instance called _/System/Event/compute.instance.power\_on.end_, that runs a method containing the following code:

```ruby
if $evm.root['ems_event'].source == 'OPENSTACK' 
  $evm.vmdb('ems', $evm.root['ems_event'].ems_id).refresh
end
```

This will trigger an EMS refresh of the OpenStack Provider for any OpenStack Instance power on event. Unfortunately we can't trigger a targeted VM refresh yet on OpenStack, so we have to trigger an entire EMS refresh, which generally transfers far more information than we need. The Cloud Instance power states in the icon tile will however be set correctly after this operation.

### Edit /var/www/miq/vmdb/config/event_handling.tmpl.yml

There is a YAML file on each appliance _/var/www/miq/vmdb/config/event\_handling.tmpl.yml_ that controls the default actions to be taken when each event type is raised. This file has the following section to hande OpenStack _compute.instance.power\_off.end_ events:

```
  compute.instance.power_off.end:
  - refresh:
    - ems
  - policy:
    - src_vm
    - vm_poweroff
```

If we add:

```
  compute.instance.power_on.end:
  - refresh:
    - ems
```

and restart the evmserverd service, our _compute.instance.power\_off.end_ events are now handled as expected without having to create new Instances under /System/Event