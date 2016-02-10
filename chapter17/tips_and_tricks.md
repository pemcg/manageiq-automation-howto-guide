## Tips and Tricks

There are a number of useful tips and tricks to be aware of when developing services.

#### Test VM Provisioning First

Before developing a service catalog item to provision a VM, test that an interactive provision (**Infrastructure -> Virtual Machines -> Lifecycle -> Provision VMs**) from the same VM Template, using the same VM settings, works successfully.

This should include the same placement type (auto or manually selected), and the same CPU count and memory size ranges that will be offered from the service dialog.

Troubleshooting a failing interactive VM provision is simpler than troubleshooting a failing service order.

#### Re-Create the Service Item if the Template Changes

If any changes are made to the Template that would result in a new internal Template ID, then the Service Catalog Item must be re-created (even if the new Template has the same name as the old).
