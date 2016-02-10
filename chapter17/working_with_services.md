## Working with Services

We have seen that we can use CloudForms to easily provision VMs from the **Infrastructure -> Virtual Machines -> Lifecycle** or **Clouds -> Instances -> Lifecycle** button groups. This does however require the requester to supply values for all of the VM Provisioning Dialog options, for every provision request.

CloudForms enables us to create Service Catalogs. These contain Catalog Items, and Bundles of Items, to enable users to provision one or more VMs (or other components) from a single **Order** button:
<br> <br>

![screenshot](images/screenshot1.png)
<br>

When we create a Service Catalog Item, we pre-select the VM Provisioning Dialog options, and optionally create a _Service Dialog_ to allow for user input when the service is ordered. In this way we can create pre-configured service definitions that suit our own use cases, for example, offering **small**, **medium** or **large** to specify VM sizes:
<br> <br>

![screenshot](images/screenshot2.png)
<br>

The remaining sections in this chapter discuss the details of creating and using Service Catalogs.

