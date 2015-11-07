begin
  #
  # Get the task object from root
  #
  service_template_provision_task = $evm.root['service_template_provision_task']
  #
  # Get destination service object
  #
  service = service_template_provision_task.destination
  #
  # Get dialog options
  #
  dialog_options = service_template_provision_task.dialog_options
  #
  # Name the service
  #
  if dialog_options.has_key? 'dialog_service_name'
    service.name = "#{dialog_options['dialog_service_name']}"
  end
  if dialog_options.has_key? 'dialog_service_description'
    service.description = "#{dialog_options['dialog_service_description']}"
  end

  $evm.root['ae_result'] = 'ok'
  exit MIQ_OK
rescue => err
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")
  $evm.root['ae_result'] = 'error'
  $evm.root['ae_reason'] = "Error: #{err.message}"
  exit MIQ_ERROR
end