request = $evm.root['miq_request']
resource = request.resource
raise "Automation Request not found" if request.nil? || resource.nil?

$evm.log("info", "Checking for auto_approval")
approval_type = $evm.object['approval_type'].downcase
if approval_type == 'auto'
  $evm.root["miq_request"].approve("admin", "Auto-Approved")
  $evm.root['ae_result'] = 'ok'
else
  msg =  "Request was not auto-approved"
  resource.set_message(msg)
  $evm.root['ae_result'] = 'error'
  $evm.object['reason'] = msg
end