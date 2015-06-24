## The Options Hash

### miq\_provision\_request

The inputs and options selected from the Provisioning Dialog are added to the _miq\_provision\_request_ object as key/value pairs in a hash known as the _Options Hash_. The contents of the Options Hash varies slightly between provisioning targets (VMware, OpenStack, RHEV etc) and target VM Operating System (Linux, Windows etc.), but a typical hash for a Linux VM provision to a RHEV provider is...


```ruby
miq_provision_request.options[:addr_mode] = ["static", "Static"]   (type: Array)
miq_provision_request.options[:cluster_filter] = [nil, nil]   (type: Array)
miq_provision_request.options[:cores_per_socket] = [1, "1"]   (type: Array)
miq_provision_request.options[:current_tab_key] = customize   (type: Symbol)
miq_provision_request.options[:customization_template_script] = nil
miq_provision_request.options[:customize_enabled] = ["disabled"]   (type: Array)
miq_provision_request.options[:delivered_on] = 2015-06-05 07:33:20 UTC   (type: Time)
miq_provision_request.options[:disk_format] = ["default", "Default"]   (type: Array)
miq_provision_request.options[:dns_domain] = nil
miq_provision_request.options[:dns_servers] = nil
miq_provision_request.options[:dns_suffixes] = nil
miq_provision_request.options[:gateway] = nil
miq_provision_request.options[:hostname] = nil
miq_provision_request.options[:initial_pass] = true   (type: TrueClass)
miq_provision_request.options[:ip_addr] = nil
miq_provision_request.options[:linked_clone] = [nil, nil]   (type: Array)
miq_provision_request.options[:mac_address] = nil
miq_provision_request.options[:memory_reserve] = nil
miq_provision_request.options[:miq_request_dialog_name] = miq_provision_redhat_dialogs_template   (type: String)
miq_provision_request.options[:network_adapters] = [1, "1"]   (type: Array)
miq_provision_request.options[:number_of_sockets] = [1, "1"]   (type: Array)
miq_provision_request.options[:number_of_vms] = [1, "1"]   (type: Array)
miq_provision_request.options[:owner_address] = nil
miq_provision_request.options[:owner_city] = nil
miq_provision_request.options[:owner_company] = nil
miq_provision_request.options[:owner_country] = nil
miq_provision_request.options[:owner_department] = nil
miq_provision_request.options[:owner_email] = pemcg@bit63.com   (type: String)
miq_provision_request.options[:owner_first_name] = Peter   (type: String)
miq_provision_request.options[:owner_last_name] = McGowan   (type: String)
miq_provision_request.options[:owner_load_ldap] = nil
miq_provision_request.options[:owner_manager] = nil
miq_provision_request.options[:owner_manager_mail] = nil
miq_provision_request.options[:owner_manager_phone] = nil
miq_provision_request.options[:owner_office] = nil
miq_provision_request.options[:owner_phone] = nil
miq_provision_request.options[:owner_phone_mobile] = nil
miq_provision_request.options[:owner_state] = nil
miq_provision_request.options[:owner_title] = nil
miq_provision_request.options[:owner_zip] = nil
miq_provision_request.options[:pass] = 1   (type: Fixnum)
miq_provision_request.options[:placement_auto] = [false, 0]   (type: Array)
miq_provision_request.options[:placement_cluster_name] = [1000000000001, "Default"]   (type: Array)
miq_provision_request.options[:placement_dc_name] = [1000000000002, "Default"]   (type: Array)
miq_provision_request.options[:placement_ds_name] = [1000000000001, "Data"]   (type: Array)
miq_provision_request.options[:placement_host_name] = [1000000000001, "rhelh03.bit63.net"]   (type: Array)
miq_provision_request.options[:provision_type] = ["native_clone", "Native Clone"]   (type: Array)
miq_provision_request.options[:pxe_server_id] = [nil, nil]   (type: Array)
miq_provision_request.options[:request_notes] = nil
miq_provision_request.options[:retirement] = [0, "Indefinite"]   (type: Array)
miq_provision_request.options[:retirement_warn] = [604800, "1 Week"]   (type: Array)
miq_provision_request.options[:root_password] = nil
miq_provision_request.options[:schedule_time] = 2015-06-06 00:00:00 UTC   (type: Time)
miq_provision_request.options[:schedule_type] = ["immediately", "Immediately on Approval"]   (type: Array)
miq_provision_request.options[:src_ems_id] = [1000000000001, "RHEV"]   (type: Array)
miq_provision_request.options[:src_vm_id] = [1000000000004, "rhel7-generic"]   (type: Array)
miq_provision_request.options[:src_vm_lans] = []   (type: Array)
miq_provision_request.options[:src_vm_nics] = []   (type: Array)
miq_provision_request.options[:start_date] = 6/6/2015   (type: String)
miq_provision_request.options[:start_hour] = 00   (type: String)
miq_provision_request.options[:start_min] = 00   (type: String)
miq_provision_request.options[:stateless] = [false, 0]   (type: Array)
miq_provision_request.options[:subnet_mask] = nil
miq_provision_request.options[:vlan] = ["public", "public"]   (type: Array)
miq_provision_request.options[:vm_auto_start] = [false, 0]   (type: Array)
miq_provision_request.options[:vm_description] = nil
miq_provision_request.options[:vm_memory] = ["2048", "2048"]   (type: Array)
miq_provision_request.options[:vm_name] = rhel7srv002   (type: String)
miq_provision_request.options[:vm_prefix] = nil
miq_provision_request.options[:vm_tags] = []   (type: Array)
```
When we work with our own Methods that interact with the VM Provisioning process we can read any of the Options Hash keys using the ```miq_provision_request.get_option``` method, e.g.

```ruby
memory_in_request = miq_provision_request.get_option(:vm_memory).to_i
```

We can also set most options using the ```miq_provision_request.set_option``` method, e.g.

```ruby
miq_provision_request.set_option(:subnet_mask,'255.255.254.0')
```

...although some options that have a specific format have their own _mixin_ method...

```
miq_provision_request.set_vlan
miq_provision_request.set_dvs
miq_provision_request.set_network_address_mode
miq_provision_request.set_network_adapter
```

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