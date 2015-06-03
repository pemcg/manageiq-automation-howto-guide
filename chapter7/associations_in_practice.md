## Associations in Practice

We saw from [Active Record Associations](### Active Record Associations) that there are associations been many of the Active Records (and hence Service Models). We use this extensively when scripting, so for example to find the name of the cluster that our VM is running on, we follow the assocation between MiqAeServiceVmRedhat and MiqAeServiceEmsCluster...

```ruby
cluster = $evm.root['vm'].ems_cluster.name
```

We find more about the hardware that our VM has by following associations between MiqAeServiceVmRedhat, MiqAeServiceHardware and MiqAeServiceGuestDevice...

```ruby
hardware = $evm.root['vm'].hardware
hardware.guest_devices.each do |guest_device|
  if guest_device.device_type == "ethernet"
    nic_name = guest_device.device_name
  end
end
```

We can find out a user's role by following the association between MiqAeServiceUser and MiqAeServiceMiqGroup...

```ruby
role = $evm.root['user'].current_group.miq_user_role_name
```

We can find out the email address of the person who requested a VM by following the associations between MiqAeServiceVmRedhat, MiqAeServiceMiqProvisionRedhat and MiqAeServiceMiqProvisionRequest...

```ruby
owner_email = $evm.root['vm'].miq_provision.miq_provision_request.options[:owner_email]
```

The beauty is that we don't (as Automation scripters) need to know anything about the Active Records or Service Models behind the scenes, we just follow the links. See [Investigative Debugging](## Investigative Debugging) to find out what associations there are to follow.