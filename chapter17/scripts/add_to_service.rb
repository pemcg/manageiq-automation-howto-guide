begin
  parent_service_id = $evm.root['dialog_service']
  parent_service = $evm.vmdb('service').find_by_id(parent_service_id)
  if parent_service.nil?
    $evm.log(:error, "Can't find service with ID: #{parent_service_id}")
    exit MIQ_ERROR
  else
    case $evm.root['vmdb_object_type']
    when 'service'
      $evm.log(:info, "Adding Service #{$evm.root['service'].name} to #{parent_service.name}")
      $evm.root['service'].parent_service = parent_service
    when 'vm'
      vm = $evm.root['vm']
      #
      # See if the VM is already part of a service
      #
      unless vm.service.nil?
        old_service = vm.service
        vm.remove_from_service
        if old_service.v_total_vms.zero?
          $evm.log(:info, "Old service #{old_service.name} is now empty, removing it from VMDB")
          old_service.remove_from_vmdb
        end
      end
      $evm.log(:info, "Adding VM #{vm.name} to #{parent_service.name}")
      vm.add_to_service(parent_service)
    end
  end
  exit MIQ_OK
rescue => err
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  exit MIQ_ERROR
end

