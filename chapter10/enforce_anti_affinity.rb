#----------------------------------------------------------------------------
#
# CFME Automate Method: enforce_anti-affinity
#
# Author: Peter McGowan (Red Hat)
#
# Notes: This method enforces an anti-affinity rule based on server_role tag
#
#----------------------------------------------------------------------------

begin
  #----------------------------------------------------------------------------
  def relocate_vm(vm)
    #
    # Get our host name
    #
    our_host = vm.host_name
    #
    # Loop through the other hosts in our cluster
    #
    target_host = nil
    vm.ems_cluster.hosts.each do |this_host|
      next if this_host.name == our_host   # Skip if this Host == our Host
      host_invalid = false
      this_host.vms.each do |this_vm|
        if this_vm.tags(:server_role).first == our_server_role
          host_invalid = true
          break
        end
      end
      next if host_invalid
      #
      # If we get to here then no duplicate server_role VMs have been found on this host
      #
      target_host = this_host
      break
    end
    if target_host.nil?
      raise "No suitable Host found to migrate VM #{vm.name} to"
    else
      $evm.log(:info, "Migrating VM #{vm.name} to host: #{target_host.name}")
      #
      # Migrate the VM to this host
      #
      vm.migrate(target_host)
    end
    return target_host.name
  end
  #----------------------------------------------------------------------------
  
  #----------------------------------------------------------------------------
  def send_email(group_name, vm_name, new_host)
    #
    # Find the group passed to us, and pull out the user emails
    #
    recipients = []
    group = $evm.vmdb('miq_group').find_by_description(group_name)
    group.users.each do |group_member|
      recipients << group_member.email
    end
    #
    # 'from' is the current logged-user who clicked the button
    #
    from = $evm.root['user'].email
    subject = "VM migration"
    body = "VM Name: #{vm_name} was live-migrated to Host: #{new_host} in accordance with anti-affinity rules"
    #
    # Send emails
    #
    recipients.each do |recipient|
      $evm.log(:info, "Sending email to <#{recipient}> from <#{from}> subject: <#{subject}>")
      $evm.execute(:send_email, recipient, from, subject, body)
    end
  end
  #----------------------------------------------------------------------------
  
  
  #----------------------------------------------------------------------------
  # Main code
  #----------------------------------------------------------------------------
  #
  # We've been called from a button on the VM object, so we know that
  # $evm.root['vm'] will be loaded
  #
  vm = $evm.root['vm']
  #
  # Find out this VM's server_role tag
  #
  our_server_role = vm.tags(:server_role).first
  $evm.log(:info, "VM #{vm.name} has a server_role tag of: #{our_server_role}")
  #
  # Loop through the other VMs on the same host
  #
  vm.host.vms.each do |this_vm|
    next if this_vm.name == vm.name  # Skip if this VM == our VM
    if this_vm.tags(:server_role).first == our_server_role
      $evm.log(:info, "VM #{this_vm.name} also has a server_role tag of: #{our_server_role}, taking remedial action")
      new_host = relocate_vm(vm)
      send_email('EvmGroup-administrator', vm.name, new_host)
    end
  end
  exit MIQ_OK

rescue => err
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_STOP
end
