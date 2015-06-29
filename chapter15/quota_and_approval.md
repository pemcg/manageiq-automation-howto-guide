## Approval and Quota

### Approval

The approval process for a VM Provision Request is entered as a result of the _MiqProvisionRequest\_created_ event being triggered. This results in a Provisioning Profile lookup to read the value of the _auto\_approval\_state\_machine_ Attribute, which by default is _ProvisionRequestApproval_ for an Infrastructure VM Provision Request. The second relationship from the event runs the _Default_ Instance of this State Machine.
<br> <br>

![screenshot](images/screenshot33.png)

<br>
The Schema for the _ProvisionRequestApproval_ State Machine is...
<br> <br>

![screenshot](images/screenshot34.png)

<br>
...and the _Default_ Instance has the following Attribute values...
<br> <br>

![screenshot](images/screenshot35.png)
<br>

This Instance will auto-approve any VM Provisioning Request containing a single VM, but requests for more than this number will require explicit approval from an Administrator, or anyone in a Group with the role _EvmRole-approver_ (or equivalent).

We are free to copy the _ProvisionRequestApproval_ State Machine to our own Domain and change or set any of the auto-approval schema Attributes, i.e. _max\_cpus, max\_vms, max\_memory_ or _max\_retirement\_days_.

### Overriding the Default - Template Tagging

We can override the auto-approval _max\_*_ values stored in the _ProvisionRequestApproval_ State Machine on a per-Template basis, by applying tags from one or more of the following tag categories to the Template...


|  Tag Category Name  | Tag Category Display Name  |
|:----------:|:----------------:|
| prov\_max\_cpu | Auto Approve - Max CPU |
| prov\_max\_memory | Auto Approve - Max Memory |
| prov\_max\_retirement\_days | Auto Approve - Max Retirement Days |
| prov\_max\_vm | Auto Approve - Max VM |

If a Template is tagged in such a way, then any VM Provisioning Request _from_ that Template will result in the Template's tag value being used for auto-approval considerations, rather than the Attribute value from the schema. 

### VM Provisioning-Related Email

There are four Email Instances with corresponding Methods that are used to handle the sending of VM Provisioning-related emails. The Instances each have the Attributes _to\_email\_address, from\_email\_address_ and _signature_ that can (and should) be customised, after copying the Instances to our own Domain.

Three of the Instances are approval-related. The _to\_email\_address_ value for the _MiqProvisionRequest\_Pending_ Instance should contain the email address of a user (or mailing list) who is able to login to the CloudForms appliance as an Administrator or as a member of a Group with the role _EvmRole-approver_ (or equivalent).
<br> <br>

![screenshot](images/screenshot36.png?)
<br>

##### Can't remember why I wrote the following...
Services -> Requests -> Operate -> Approve and Deny 


### Quota