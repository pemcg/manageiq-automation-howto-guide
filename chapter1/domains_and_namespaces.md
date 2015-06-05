## Domains and Namespaces

### Domains
A **domain** is a collection of **namespaces**, **classes**, **instances** and **methods**. The ManageIQ upstream project provides a single _ManageIQ_ domain for all supplied automation code, while Red Hat adds the supplemental _RedHat_ domain containing added-value code for the CloudForms product.

![Screenshot](images/screenshot1.png)

Domains are a new feature of the Automation engine for the ManageIQ _Anand_ release (CloudForms 3.1). Prior to this release all factory-supplied and user-created automation code was contained in a common structure, which made updates difficult when any user-added code was introduced (the user-supplied modifications needed exporting and re-importing/merging whenever an automation update was released).

Both the ManageIQ and RedHat domains are locked, indicating their read-only nature, however we are free to create our own domains for our custom automation code. Organising our own code into custom domains greatly simplifies the task of exporting and importing code (simplifying code portability and re-use), and leaves ManageIQ/Red Hat free to update the locked domains through minor releases without fear of overwriting our customisations.

#### Domain Priority
User-added domains can be individually enabled or disabled, and all domains can be layered in a priority order such that if code exists in the same path in multiple domains (for example /Infrastructure/VM/Provisioning/StateMachines/Methods), the code in the highest priority enabled domain will be executed.

#### Importing / Exporting Domains
Domains can be exported using _rake_ from the command line, and imported either using _rake_ or from the WebUI. (Using rake enables us to specify more import and export options). A typical rake import line is...

```
script/rails runner script/rake evm:automate:import YAML_FILE=Buttons.yaml IMPORT_AS=Bit63 SYSTEM=false ENABLED=true DOMAIN=Export PREVIEW=false
```

See the following kbase articles for details and examples of importing and exporting domains using rake:

[Cloudforms 3.1 Exporting Automate Domains](https://access.redhat.com/solutions/1225313)  
[Cloudforms 3.1 Importing Automate Domains](https://access.redhat.com/solutions/1225383)

#### Copying Objects Between Domains

We frequently need to customise code in the locked RedHat or ManageIQ Domains, for example when implementing our own VM placement method. Fortunately we can easily copy any object from the locked Domains into our own using Configuration -> Copy this ...

![Screenshot](images/screenshot3.png)

###Namespaces
A **namespace** is a folder-like container for **classes**, **instances** and **methods**, and is purely used for organisational purposes. 

![Screenshot](images/screenshot2.png)

We create namespaces (nested if required) to arrange our code logically.
