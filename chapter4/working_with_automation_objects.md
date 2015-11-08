## Working with Automation Objects

When we write our own Automation scripts, we work with the MiqAeService\* Automation objects that the CloudForms/ManageIQ Automation Engine makes available to us. These Automation objects have four types of property that we frequently work with, **Attributes**, **Virtual Columns**, **Associations** and **Methods**.

### Attributes

Just like any other Ruby object, the MiqAeService\* Automation objects that we work with have **Attributes** that we often use. For example, the Attributes for a RHEV Host object (_MiqAeServiceHostRedhat_), with some typical values, are:

```
host.admin_disabled = nil
host.asset_tag = nil
host.connection_state = connected   (type: String)
host.created_on = 2014-11-13 17:53:34 UTC   (type: ActiveSupport::TimeWithZone)
host.ems_cluster_id = 1000000000001   (type: Fixnum)
host.ems_id = 1000000000001   (type: Fixnum)
host.ems_ref = /api/hosts/b959325b-c667-4e3a-a52e-fd936c225a1a   (type: String)
host.ems_ref_obj = /api/hosts/b959325b-c667-4e3a-a52e-fd936c225a1a   (type: String)
host.failover = nil
host.guid = fcea82c8-6b5d-11e4-98ac-001a4aa01599   (type: String)
host.hostname = 192.168.1.224   (type: String)
host.hyperthreading = nil
host.id = 1000000000001   (type: Fixnum)
host.ipaddress = 192.168.1.224   (type: String)
host.ipmi_address = nil
host.last_perf_capture_on = 2015-06-05 10:25:46 UTC   (type: ActiveSupport::TimeWithZone)
host.mac_address = nil
host.name = rhelh03.bit63.net   (type: String)
host.next_available_vnc_port = nil
host.power_state = on   (type: String)
host.service_tag = nil
host.settings = {:autoscan=>false, :inherit_mgt_tags=>false, :scan_frequency=>0}   (type: Hash)
host.smart = 1   (type: Fixnum)
host.ssh_permit_root_login = nil
host.type = HostRedhat   (type: String)
host.uid_ems = b959325b-c667-4e3a-a52e-fd936c225a1a   (type: String)
host.updated_on = 2015-06-05 10:43:00 UTC   (type: ActiveSupport::TimeWithZone)
host.user_assigned_os = nil
host.vmm_buildnumber = nil
host.vmm_product = rhel   (type: String)
host.vmm_vendor = RedHat   (type: String)
host.vmm_version = nil
```

We can enumerate an object's Attributes using:

```ruby
this_object.attributes.each do |key, value|
```

### Virtual Columns

In addition to the standard object Attributes, Rails makes available a number of **Virtual Columns** and attaches them to the object. We access theses Virtual Columns just as we would access Attributes, using "object.virtual\_column\_name" syntax.

For example, the Virtual Columns for our same RHEV Host object, with some typical values, are:


```
host.all_enabled_ports = []   (type: Array)
host.authentication_status = Valid   (type: String)
host.cpu_usagemhz_rate_average_avg_over_time_period = 0.0   (type: Float)
host.cpu_usagemhz_rate_average_high_over_time_period = 0.0   (type: Float)
host.cpu_usagemhz_rate_average_low_over_time_period = 0.0   (type: Float)
host.custom_1 = nil
host.custom_2 = nil
host.custom_3 = nil
host.custom_4 = nil
host.custom_5 = nil
host.custom_6 = nil
host.custom_7 = nil
host.custom_8 = nil
host.custom_9 = nil
host.derived_memory_used_avg_over_time_period = 790.1026640002773   (type: Float)
host.derived_memory_used_high_over_time_period = 2586.493300608264   (type: Float)
host.derived_memory_used_low_over_time_period = 0   (type: Fixnum)
host.enabled_inbound_ports = []   (type: Array)
host.enabled_outbound_ports = []   (type: Array)
host.enabled_run_level_0_services = []   (type: Array)
host.enabled_run_level_1_services = []   (type: Array)
host.enabled_run_level_2_services = []   (type: Array)
host.enabled_run_level_3_services = []   (type: Array)
host.enabled_run_level_4_services = []   (type: Array)
host.enabled_run_level_5_services = []   (type: Array)
host.enabled_run_level_6_services = []   (type: Array)
host.first_drift_state_timestamp = nil
host.ipmi_enabled = false   (type: FalseClass)
host.last_compliance_status = nil
host.last_compliance_timestamp = nil
host.last_drift_state_timestamp = nil
host.last_scan_on = nil
...
host.os_image_name = linux_generic   (type: String)
host.platform = linux   (type: String)
host.ram_size = 15821   (type: Fixnum)
host.region_description = Region 1   (type: String)
host.region_number = 1   (type: Fixnum)
host.service_names = []   (type: Array)
host.total_cores = 2   (type: Fixnum)
host.total_vcpus = 2   (type: Fixnum)
host.v_annotation = nil
host.v_owning_cluster = Default   (type: String)
host.v_owning_datacenter =    (type: String)
host.v_owning_folder =    (type: String)
host.v_total_miq_templates = 0   (type: Fixnum)
host.v_total_storages = 3   (type: Fixnum)
host.v_total_vms = 3   (type: Fixnum)
```

We can enumerate an object's Virtual Columns using:

```ruby
this_object.virtual_column_names.each do |virtual_column_name|
  virtual_column_value = this_object.send(virtual_column_name)
```

### Associations

We saw from [A Little Rails Knowledge](../chapter4/a_little_rails_knowledge.md) that there are **Associations** between many of the Active Records (and hence Service Models), and we use these extensively when scripting. For example to find the name of the cluster that our VM is running on, we follow the assocation between the VM object ( _MiqAeServiceVmRedhat_ ) and its Cluster object ( _MiqAeServiceEmsCluster_ ), and referencing to the Cluster object's _name_ attribute:

```ruby
cluster = $evm.root['vm'].ems_cluster.name
```

We find more about the hardware that our VM has by following associations between the VM object (_MiqAeServiceVmRedhat_), and its Hardware and GuestDevice objects ( _MiqAeServiceHardware_ and _MiqAeServiceGuestDevice_ ):

```ruby
hardware = $evm.root['vm'].hardware
hardware.guest_devices.each do |guest_device|
  if guest_device.device_type == "ethernet"
    nic_name = guest_device.device_name
  end
end
```

We can find out a user's role by following the association between the User object ( _MiqAeServiceUser_ ) and its Group object ( _MiqAeServiceMiqGroup_ ), and referencing the Group object's _miq\_user\_role\_name_ attribute:

```ruby
role = $evm.root['user'].current_group.miq_user_role_name
```

As Automation scripters, we don't need to know anything about the Active Records or Service Models behind the scenes, we just follow the links. See [Investigative Debugging](../chapter9/investigative_debugging.md) to find out what associations there are to follow.

Continuing our exploration of our RHEV Host object ( _MiqAeServiceHostRedhat_ ), the Associations available to this object are:
<br> <br>

```
host.datacenter
host.directories
host.ems_cluster
host.ems_events
host.ems_folder
host.ext_management_system
host.files
host.guest_applications
host.hardware
host.lans
host.operating_system
host.storages
host.switches
host.vms
```

We can enumerate an object's Associations using:

```ruby
this_object.associations.each do |association|
```

### Methods

Most of the objects that we work with have **Methods** defined, either in their own class or superclasses. The description of (most of) these Methods is in the _Management Engine 5.x Methods Available for Automation_ manual.

For example the Methods available to call for our RHEV Host object ( _MiqAeServiceHostRedhat_ ) are:

```
host.authentication_password
host.authentication_userid
host.credentials
host.current_cpu_usage
host.current_memory_headroom
host.current_memory_usage
host.custom_get
host.custom_keys
host.custom_set
host.domain
host.ems_custom_get
host.ems_custom_keys
host.ems_custom_set
host.event_log_threshold?
host.get_realtime_metric
host.scan
host.ssh_exec
```

Enumerating an MiqAeService* object's methods is more challenging, because the actual object that we want to enumerate is on the remote side of a druby call, and all we have is the local DRb::DRbObject. We can use _method\_missing_, but we get returned the entire Method list, which includes Attribute names, Virtual Column names, Association names, superclass methods, etc.

```ruby
this_object.method_missing(:class).instance_methods
```
