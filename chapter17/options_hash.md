## The Options Hash

### miq\_provision\_request

The inputs and options selected from the Provisioning Dialog are added to the _miq\_provision\_request_ object as key/value pairs in a hash known as the _Options Hash_. The contents of the Options Hash varies slightly between provisioning targets (VMware, OpenStack, RHEV etc) and target VM Operating System (Linux, Windows etc.), but a typical hash for a Linux VM provision to a RHEV provider is...


```ruby
request.options[:addr_mode] = ["static", "Static"]   (type: Array)
request.options[:cluster_filter] = [nil, nil]   (type: Array)
request.options[:cores_per_socket] = [1, "1"]   (type: Array)
request.options[:current_tab_key] = customize   (type: Symbol)
request.options[:customization_template_script] = nil
request.options[:customize_enabled] = ["disabled"]   (type: Array)
request.options[:delivered_on] = 2015-06-05 07:33:20 UTC   (type: Time)
request.options[:disk_format] = ["default", "Default"]   (type: Array)
request.options[:dns_domain] = nil
request.options[:dns_servers] = nil
request.options[:dns_suffixes] = nil
request.options[:gateway] = nil
request.options[:hostname] = nil
request.options[:initial_pass] = true   (type: TrueClass)
request.options[:ip_addr] = nil
request.options[:linked_clone] = [nil, nil]   (type: Array)
request.options[:mac_address] = nil
request.options[:memory_reserve] = nil
request.options[:miq_request_dialog_name] = miq_provision_redhat_dialogs_template   (type: String)
request.options[:network_adapters] = [1, "1"]   (type: Array)
request.options[:number_of_sockets] = [1, "1"]   (type: Array)
request.options[:number_of_vms] = [1, "1"]   (type: Array)
request.options[:owner_address] = nil
request.options[:owner_city] = nil
request.options[:owner_company] = nil
request.options[:owner_country] = nil
request.options[:owner_department] = nil
request.options[:owner_email] = pemcg@bit63.com   (type: String)
request.options[:owner_first_name] = Peter   (type: String)
request.options[:owner_last_name] = McGowan   (type: String)
request.options[:owner_load_ldap] = nil
request.options[:owner_manager] = nil
request.options[:owner_manager_mail] = nil
request.options[:owner_manager_phone] = nil
request.options[:owner_office] = nil
request.options[:owner_phone] = nil
request.options[:owner_phone_mobile] = nil
request.options[:owner_state] = nil
request.options[:owner_title] = nil
request.options[:owner_zip] = nil
request.options[:pass] = 1   (type: Fixnum)
request.options[:placement_auto] = [false, 0]   (type: Array)
request.options[:placement_cluster_name] = [1000000000001, "Default"]   (type: Array)
request.options[:placement_dc_name] = [1000000000002, "Default"]   (type: Array)
request.options[:placement_ds_name] = [1000000000001, "Data"]   (type: Array)
request.options[:placement_host_name] = [1000000000001, "rhelh03.bit63.net"]   (type: Array)
request.options[:provision_type] = ["native_clone", "Native Clone"]   (type: Array)
request.options[:pxe_server_id] = [nil, nil]   (type: Array)
request.options[:request_notes] = nil
request.options[:retirement] = [0, "Indefinite"]   (type: Array)
request.options[:retirement_warn] = [604800, "1 Week"]   (type: Array)
request.options[:root_password] = nil
request.options[:schedule_time] = 2015-06-06 00:00:00 UTC   (type: Time)
request.options[:schedule_type] = ["immediately", "Immediately on Approval"]   (type: Array)
request.options[:src_ems_id] = [1000000000001, "RHEV"]   (type: Array)
request.options[:src_vm_id] = [1000000000004, "rhel7-generic"]   (type: Array)
request.options[:src_vm_lans] = []   (type: Array)
request.options[:src_vm_nics] = []   (type: Array)
request.options[:start_date] = 6/6/2015   (type: String)
request.options[:start_hour] = 00   (type: String)
request.options[:start_min] = 00   (type: String)
request.options[:stateless] = [false, 0]   (type: Array)
request.options[:subnet_mask] = nil
request.options[:vlan] = ["public", "public"]   (type: Array)
request.options[:vm_auto_start] = [false, 0]   (type: Array)
request.options[:vm_description] = nil
request.options[:vm_memory] = ["2048", "2048"]   (type: Array)
request.options[:vm_name] = rhel7srv002   (type: String)
request.options[:vm_prefix] = nil
request.options[:vm_tags] = []   (type: Array)
```
When we work with our own Methods that interact with the VM Provisioning process we can read any of the Options Hash keys using the ```miq_provision_request.get_option``` method, e.g.

```ruby
memory_in_request = miq_provision_request.get_option(:vm_memory).to_i
```

We can also set most options using the ```miq_provision_request.set_option``` method, e.g.

```ruby
miq_provision_request.set_option(:subnet_mask,'255.255.254.0')
```

Several Options Hash keys have their own 'set' method which we should use in place of request.set\_option...

|   Options Hash key   |   'set' method   | 
|:--------------------:|:------------------:|
| :vm_notes | request.set_vm_notes |
| :vlan | request.set_vlan |
| :dvs | request.set_dvs |
| :addr_mode | request.set_network_address_mode |
| :placement_host_name | request.set_host |
| :placement_ds_name | request.set_storage |
| :placement_cluster_name | request.set_cluster |
| :placement_rp_name | request.set_resource_pool |
| :placement_folder_name | request.set_folder |
| :pxe_server_id | request.set_pxe_server |
| :pxe_image_id (Linux server provision) | request.set_pxe_image|
| :pxe_image_id (Windows server provision) | request.set_windows_image|
| :customization_template_id | request.set_customization_template |
| :iso_image_id | request.set_iso_image |
| :placement_availability_zone | request.set_availability_zone |
| :cloud_tenant | request.set_cloud_tenant |
| :cloud_network | request.set_cloud_network |
| :cloud_subnet | request.set_cloud_subnet |
| :security_groups | request.set_security_group |
| :floating_ip_address | request.set_floating_ip_address |
| :instance_type | request.set_instance_type |
| :guest_access_key_pair | request.set_guest_access_key_pair |

All but the first four of the 'set' methods listed above perform a validity check that the value that we're setting is an eligible resource for the provisioning instance.


Tip - use one of the techniques discussed in [Investigative Debugging](../chapter11/investigative_debugging.md) to find out what key/value pairs are in the options hash to manipluate.


### miq\_provision

The Options Hash from the _Request_ object is propagated to each _Task_ object, where it is subsequently extended by _Task_-specific Methods such as those handling VM Naming and Placement, e.g....

```ruby
miq_provision.options[:dest_cluster] = [1000000000001, "Default"]   (type: Array)
miq_provision.options[:dest_host] = [1000000000001, "rhelh03.bit63.net"]   (type: Array)
miq_provision.options[:dest_storage] = [1000000000001, "Data"]   (type: Array)
miq_provision.options[:vm_target_hostname] = rhel7srv002   (type: String)
miq_provision.options[:vm_target_name] = rhel7srv002   (type: String)
```

Some Options Hash keys such as ```.options[:number_of_vms]``` have no effect if changed in the _Task_ object - they are only relevant for the _Request_.

### Correlation with the Provisioning Dialog

The key/value pairs that make up the Options Hash initially come from the Provisioning Dialog. If we look at an extract from one of the Provisioning Dialog YAML files, we see the dialog definitions for the _number\_of\_sockets_ and _cores\_per\_socket_ options...

```
      :number_of_sockets:
        :values:
          1: '1'
          2: '2'
          4: '4'
          8: '8'
        :description: Number of Sockets
        :required: false
        :display: :edit
        :default: 1
        :data_type: :integer
      :cores_per_socket:
        :values:
          1: '1'
          2: '2'
          4: '4'
          8: '8'
        :description: Cores per Socket
        :required: false
        :display: :edit
        :default: 1
        :data_type: :integer
```
...which correspond to...

```ruby
miq_provision_request.options[:cores_per_socket]
miq_provision_request.options[:number_of_sockets]
```
### Adding Our Own Options - The ws_values Hash

Sometimes we wish to add our own custom key/value pairs to the request or task object, so that they can be used in a subsequent stage in the VM Provision State Machine for custom processing. An example might be the size and mountpoint for a secondary disk to be added as part of the provisioning workflow. Although we could add our own key/value pairs directly to the option hash, we risk overwriting a key defined in the core provisioning code (or one added in a later release of ManageIQ/CloudForms).

There is an existing options hash key that is intended to be used for this, called _ws\_values_. The value of this key is itself a hash, containing our key/value pairs that we wish to save.

```ruby
miq_provision.options[:ws_values] = {:disk_dize_gb=>100, :mountpoint=>"/opt"}
```

The _ws\_values_ hash is also used to store custom values that we might supply if we provision a VM programmatically from either the RESTful API, or from _create\_provision\_request_ (see [Creating Provisoning Requests Programmatically](create_provision_request.md)). One of the arguments for a programmatic call to create a VM is a set of key/value pairs called _additional\_values_ (it was originally called _additionalValues_ in the SOAP call). Any key/value pairs supplied with this argument for the automation call will automatically be added to the _ws\_options_ hash.

By using the _ws\_options_ hash to store our own custom key/value pairs, we make our code compatible with the VM provision request being called programmatically.



