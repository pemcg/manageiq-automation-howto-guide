## Example - Creating a Service Catalog Bundle

We learnt in [Example - Creating a Service Catalog Item](creating_a_service_item.md) how to create Service Catalog Items that enable our users to provision fully-configured VMs from a single **Order** button.

We can populate our Service Catalog with useful items, for example:
<br> <br>

![screenshot](images/screenshot36.png)

<br>
In this example the VMs are provisioned from "fat" VMware templates, pre-configured with the application packages. The Service Dialog purely prompts for a VM Name:
<br> <br>

![screenshot](images/screenshot38.png)


The next logical step on from this is to be able to provision several items together as a single _Service Catalog Bundle_.

### Creating the Service Dialog for the Bundle

When we create a Service Catalog Bundle, we handle the dialog input for each of the catalog items in a single Service Dialog that we create for the bundle. For our Web, Middleware and Database Server items, we must prompt for the VM name of each, but we'll also prompt for a service name:
<br> <br>

![screenshot](images/screenshot37.png)

We name the dialog elements according to _sequence_ in which we want our individual items provisioned. Our sequence will be:

1. Database Server
2. Middleware Server
3. Web Server

Our four dialog elements are therefore constructed as:

![screenshot](images/screenshot39.png)

![screenshot](images/screenshot40.png)

![screenshot](images/screenshot41.png)

![screenshot](images/screenshot42.png)

The number in the element name reflects the sequence number, and the `CatalogItemInitialization` and `CatalogBundleInitialization` methods use this sequence number to pass the dialog value to the correct grandchild miq\_request\_task (see [The Service Provisioning State Machine](state_machine.md)).

Note that here we are explicitly setting just the `:vm_target_name` key in the miq\_request\_task's options hash. We could alternatively have named our elements as **option\__{1,2,3}_\_vm_name**. The value **vm\_name** is recognised and special-cased by `CatalogItemInitialization`, which sets both the `:vm_target_name` and `:vm_target_hostname` keys in the miq\_request\_task's options hash to the value input. The `:vm_target_name` key sets the name of the resulting VM. The `:vm_target_hostname` key can be used to input a Linux _hostname_ (i.e. FQDN) into a VMware Customization Specification, which can then set this in the VM using VMware Tools on firstboot.

### Preparing the Service Catalog Items

As we will be handling dialog input when the bundle is ordered, we need to edit each catalog item to remove the Dialog selection. We must also _untick_ the **Display in Catalog** option (this will remove the display of the Catalog and Dialog drop-downs, and the Entry Point selections):
<br> <br>

![screenshot](images/screenshot43.png)

Once we've done this, the Items will appear as **Unassigned**:
<br> <br>

![screenshot](images/screenshot44.png)

### Creating the Service Catalog Bundle
Now we can go ahead and create our Catalog Bundle. Highlight the Catalog name, and select **Configuration -> Add a New Catalog Bundle**:
<br> <br>

![screenshot](images/screenshot45.png)

Enter a Name and Description:

![screenshot](images/screenshot46.png)

Tick the **Display in Catalog** check-box to expose the remaining fields to be filled in:
<br><br>

![screenshot](images/screenshot47.png)

Select an appropriate Catalog, and the newly created bundle Dialog, from the appropriate drop-downs. 

For the Provisioning Entry Point, navigate to: `ManageIQ/Service/Provisioning/StateMachines/ServiceProvision_Template/CatalogBundleInitialization`. 

For this service we'll configure a Retirement Entry Point, so navigate to `ManageIQ/Service/Retirement/StateMachines/ServiceRetirement/Default`.


Click on the **Details** tab, and enter some HTML-formatted text to describe the Catalog Item to anyone viewing in the Catalog. 

```html
<h1>Three Tier Web Server Bundle</h1>  
<hr>  
<br>  
<h2>Internally hosted cloud environment</h2>  
<br>  
<p>Deploy a <strong>Web, Middleware</strong> and <strong>Database</strong> server together 
as a single service using Red Hat CloudForms</p>
```

Click on the **Resources** tab, and select each of the unassigned catalog items to add them to the bundle:
<br><br>

![screenshot](images/screenshot48.png)

Change the **Action Order** and **Provisioning Order** according to our desired sequence ('3' won't be visible until '2' is set for an option):
<br><br>

![screenshot](images/screenshot49.png)

Finally click the **Add** button.

Select a suitable sized icon for a Custom Image:

![screenshot](images/screenshot50.png)

### Ordering the Catalog Bundle

Navigate to the **Service Catalogs** section in the accordion, expand the **VMware Services** Catalog, and highlight the **Three Tier Web Server Bundle** Catalog Item:
<br><br>

![screenshot](images/screenshot51.png)

<br>
Click **Order**, and fill out the Service Dialog values:

![screenshot](images/screenshot52.png)

Click **Submit**

After a few minutes, the new Service should be visible in **My Services**, containing the new VMs:
<br><br>

![screenshot](images/screenshot53.png)

<br>
If we weren't watching the order that the VMs were created in, we could look in the database to check that our desired provisioning sequence was followed:

```
vmdb_production=# select id,name from vms order by id asc;
      id       |                     name
---------------+----------------------------------------------
...
 1000000000115 | new-project-db01
 1000000000116 | new-project-mid01
 1000000000117 | new-project-web01
```

Here we see that the VMs were created (and named) in the correct order.

### Provisioning into Multiple Providers

One of the cool features of Service Bundles is that we can mix and match catalog items that provision into different Providers. For example we may have a Bimodal infrastructure comprising RHEV for our traditional Mode 1 "Pet" workloads, and an in-house OpenStack private cloud for our Mode 2 "Cattle" workloads. Using CloudForms service bundles we could provision our relatively static database server into RHEV, and our dynamically scalable mid-tier and front-end servers into OpenStack.


