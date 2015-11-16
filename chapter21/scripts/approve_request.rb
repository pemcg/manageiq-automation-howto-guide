#
# Description: This method is executed when the automation request is auto-approved
#
# Auto-Approve request
$evm.log("info", "AUTO-APPROVING automation request")
$evm.root["miq_request"].approve("admin", "Auto-Approved")