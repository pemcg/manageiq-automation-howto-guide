## Log Analysis During Service Provisioning

If we grep for the "Following.. Followed" message pairs in automation.log during a service provisioning request from a non-admin user, we see some interestings things (here _service\_template\_provision_ is abbreviated to _stp_ for brevity).

We see the initial automation request being created though the /System/Request/UI\_PROVISION\_INFO entry point...

```
Following Rel'ship [miqaedb:/System/Request/UI_PROVISION_INFO#create]
Following Rel'ship [miqaedb:/unknown/VM/Provisioning/Profile/Bit63Group_vm_user#get_domains]
Followed  Rel'ship [miqaedb:/unknown/VM/Provisioning/Profile/Bit63Group_vm_user#get_domains]
Followed  Rel'ship [miqaedb:/System/Request/UI_PROVISION_INFO#create]
Following Rel'ship [miqaedb:/System/Event/request_created#create]
Following Rel'ship [miqaedb:/System/Policy/request_created#create]
Following Rel'ship [miqaedb:/System/Process/parse_provider_category#create]
Followed  Rel'ship [miqaedb:/System/Process/parse_provider_category#create]
Following Rel'ship [miqaedb:/System/Policy/ServiceTemplateProvisionRequest_created#create]
```
We see a _service_ provisioning profile lookup to get the auto-approval state machine, and some events raised and processed...

```
Following Rel'ship [miqaedb:/service/Provisioning/Profile/Bit63Group_vm_user#get_auto_approval_state_machine]
Followed  Rel'ship [miqaedb:/service/Provisioning/Profile/Bit63Group_vm_user#get_auto_approval_state_machine]
Following Rel'ship [miqaedb:/service/Provisioning/StateMachines/ServiceProvisionRequestApproval/Default#create]
Followed  Rel'ship [miqaedb:/service/Provisioning/StateMachines/ServiceProvisionRequestApproval/Default#create]
Followed  Rel'ship [miqaedb:/System/Policy/ServiceTemplateProvisionRequest_created#create]
Followed  Rel'ship [miqaedb:/System/Policy/request_created#create]
Followed  Rel'ship [miqaedb:/System/Event/request_created#create]
Following Rel'ship [miqaedb:/System/Event/request_approved#create]
Following Rel'ship [miqaedb:/System/Policy/request_approved#create]
Following Rel'ship [miqaedb:/System/Process/parse_provider_category#create]
Followed  Rel'ship [miqaedb:/System/Process/parse_provider_category#create]
Following Rel'ship [miqaedb:/System/Policy/ServiceTemplateProvisionRequest_Approved#create]
Following Rel'ship [miqaedb:/Service/Provisioning/Email/ServiceTemplateProvisionRequest_Approved#create]
```

We see some processing in the context of the service template provisioning _request_...

```
Q-task_id([stp_request_10...11]) Following Rel'ship [miqaedb:/System/Event/request_starting#create]
Q-task_id([stp_request_10...11]) Following Rel'ship [miqaedb:/System/Policy/request_starting#create]
Q-task_id([stp_request_10...11]) Following Rel'ship [miqaedb:/System/Process/parse_provider_category#create]
Followed  Rel'ship [miqaedb:/Service/Provisioning/Email/ServiceTemplateProvisionRequest_Approved#create]
Followed  Rel'ship [miqaedb:/System/Policy/ServiceTemplateProvisionRequest_Approved#create]
Followed  Rel'ship [miqaedb:/System/Policy/request_approved#create]
Followed  Rel'ship [miqaedb:/System/Event/request_approved#create]
Q-task_id([stp_request_10...11]) Followed  Rel'ship [miqaedb:/System/Process/parse_provider_category#create]
Q-task_id([stp_request_10...11]) Following Rel'ship [miqaedb:/System/Policy/ServiceTemplateProvisionRequest_starting#create]
Q-task_id([stp_request_10...11]) Following Rel'ship [miqaedb:/service/Provisioning/Profile/Bit63Group_vm_user#get_quota_state_machine]
Q-task_id([stp_request_10...11]) Followed  Rel'ship [miqaedb:/service/Provisioning/Profile/Bit63Group_vm_user#get_quota_state_machine]
Q-task_id([stp_request_10...11]) Following Rel'ship [miqaedb:/service/Provisioning/StateMachines/ServiceProvisionRequestQuotaVerification/Default#create]
Q-task_id([stp_request_10...11]) Followed  Rel'ship [miqaedb:/service/Provisioning/StateMachines/ServiceProvisionRequestQuotaVerification/Default#create]
Q-task_id([stp_request_10...11]) Followed  Rel'ship [miqaedb:/System/Policy/ServiceTemplateProvisionRequest_starting#create]
Q-task_id([stp_request_10...11]) Followed  Rel'ship [miqaedb:/System/Policy/request_starting#create]
Q-task_id([stp_request_10...11]) Followed  Rel'ship [miqaedb:/System/Event/request_starting#create]
Q-task_id([stp_request_10...11]) Following Rel'ship [miqaedb:/System/Request/UI_PROVISION_INFO#create]
Q-task_id([stp_request_10...11]) Following Rel'ship [miqaedb:/infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_vmname]
Q-task_id([stp_request_10...11]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Naming/Default#create]
Q-task_id([stp_request_10...11]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Naming/Default#create]
Q-task_id([stp_request_10...11]) Followed  Rel'ship [miqaedb:/infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_vmname]
Q-task_id([stp_request_10...11]) Followed  Rel'ship [miqaedb:/System/Request/UI_PROVISION_INFO#create]
```

Notice that this _request_ processing runs the naming method, which is therefore processed **before** CatalogItemInitialization (which is processed in _task_ context).

We see two service template provisioning _tasks_ created, our top-level and child task objects (service\_template\_provision\_task\_1000000000031 and service\_template\_provision\_task\_1000000000032)...

```
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/DialogParser#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/DialogParser#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CatalogItemInitialization#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CatalogItemInitialization#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/Provision#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/Provision#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/GroupSequenceCheck#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/GroupSequenceCheck#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/Provision#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/Provision#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
```

We see our grandchild miq_provision task object created (miq\_provision\_1000000000033), and it processing the /Infrastructure/VM/Provisioning/StateMachines methods in the state machine defined in our user profile...

```
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CustomizeRequest#VMware]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CustomizeRequest#VMware]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Placement/default#VMware]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Placement/default#VMware]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/PreProvision#VMware]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/PreProvision#VMware]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/Provision#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/Provision#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/System/Request/UI_PROVISION_INFO#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_host_and_storage]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_host_and_storage]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/System/Request/UI_PROVISION_INFO#create]
```

We see both top-level and child service template provisioning tasks running their _CheckProvisioned_ methods...

```
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
```

We see the entire /Infrastructure/VM/Provisioning/StateMachines state machine being re-instantiated for each call of its _CheckProvisioned_ method, including the profile lookup...

 _/Infrastructure/VM/Provisioning/Profile/Bit63Group\_vm\_user#get\_state\_machine_. 

(recall that if a state/stage exits with ```$evm.root['ae_result'] = 'retry'```, the entire state machine is re-launched after the retry interval, starting at the state/stage to be retried)

```
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
```

We see the _Infrastructure/VM_ provisioning state machine _CheckProvisioned_ method return success, and continue with the remainder of the state machine...

```
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Profile/Bit63Group_vm_user#get_state_machine]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/PostProvision#VMware]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/Methods/PostProvision#VMware]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Email/MiqProvision_Complete?event=vm_provisioned#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/Email/MiqProvision_Complete?event=vm_provisioned#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/System/CommonMethods/StateMachineMethods/vm_provision_finished#create]
Q-task_id([miq_provision_10...33]) Following Rel'ship [miqaedb:/System/Event/service_provisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/System/Event/service_provisioned#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/System/CommonMethods/StateMachineMethods/vm_provision_finished#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/Infrastructure/VM/Provisioning/StateMachines/VMProvision_vm/template#create]
Q-task_id([miq_provision_10...33]) Followed  Rel'ship [miqaedb:/infrastructure/VM/Lifecycle/Provisioning#create]
```

...and finally we see the _Service_ provisioning state machine _CheckProvisioned_ method return success, and continue with the remainder of the state machine...

```
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/Service/Provisioning/Email/ServiceProvision_complete?event=service_provisioned#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/Service/Provisioning/Email/ServiceProvision_complete?event=service_provisioned#create]
Q-task_id([stp_task_10...32]) Following Rel'ship [miqaedb:/System/CommonMethods/StateMachineMethods/service_provision_finished#create]
Q-task_id([stp_task_10...32]) Followed  Rel'ship [miqaedb:/System/CommonMethods/StateMachineMethods/service_provision_finished#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/StateMachines/Methods/CheckProvisioned#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/Service/Provisioning/Email/ServiceProvision_complete?event=service_provisioned#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/Service/Provisioning/Email/ServiceProvision_complete?event=service_provisioned#create]
Q-task_id([stp_task_10...31]) Following Rel'ship [miqaedb:/System/CommonMethods/StateMachineMethods/service_provision_finished#create]
Q-task_id([stp_task_10...31]) Followed  Rel'ship [miqaedb:/System/CommonMethods/StateMachineMethods/service_provision_finished#create]
```



