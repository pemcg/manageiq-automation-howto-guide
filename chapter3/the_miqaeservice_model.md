## The MiqAeService* Model

(This section is for background information only, feel free to skip)

The objects that we work with in the Automation Engine are all _Service Models_ - instances of an MiqAeService* class that abstract and make available to us their corresponding Rails Active Record. For example we access the Rails _User_ Active Record indirectly using the _MiqAeServiceUser_ Automation Engine class.

Fortunately the Automation Engine hides this from us pretty well, and generally presents the appropriate object to us via $evm.root (for example if we're working with a ```$evm.root['vm']``` object from a RHEV provider, it's actually an instance of an _MiqAeServiceVmRedhat_ object).

All of the MiqAeService* objects extend a common _MiqAeServiceModelBase_ class that contains some common methods available to all objects (such as ```.tagged_with?(category, name)```, ```.tags(category = nil)```, and ```.tag_assign(tag)``` (see section xxx on working with tags in Automate). Many of the Service Model objects have several level of superclass; the following list shows the class inheritance genealogy for each of the MiqAeService* objects:

```
MiqAeServiceAuthKeyPairAmazon < MiqAeServiceAuthKeyPairCloud < MiqAeServiceAuthPrivateKey < MiqAeServiceAuthentication < MiqAeServiceModelBase
MiqAeServiceAuthKeyPairCloud < MiqAeServiceAuthPrivateKey < MiqAeServiceAuthentication < MiqAeServiceModelBase
MiqAeServiceAuthKeyPairOpenstack < MiqAeServiceAuthKeyPairCloud < MiqAeServiceAuthPrivateKey < MiqAeServiceAuthentication < MiqAeServiceModelBase
MiqAeServiceAuthPrivateKey < MiqAeServiceAuthentication < MiqAeServiceModelBase
MiqAeServiceAuthentication < MiqAeServiceModelBase
MiqAeServiceAutomationRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceAutomationTask < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceAvailabilityZone < MiqAeServiceModelBase
MiqAeServiceAvailabilityZoneAmazon < MiqAeServiceAvailabilityZone < MiqAeServiceModelBase
MiqAeServiceAvailabilityZoneOpenstack < MiqAeServiceAvailabilityZone < MiqAeServiceModelBase
MiqAeServiceAvailabilityZoneOpenstackNull < MiqAeServiceAvailabilityZoneOpenstack < MiqAeServiceAvailabilityZone < MiqAeServiceModelBase
MiqAeServiceClassification < MiqAeServiceModelBase
MiqAeServiceCloudNetwork < MiqAeServiceModelBase
MiqAeServiceCloudSubnet < MiqAeServiceModelBase
MiqAeServiceCustomizationTemplate < MiqAeServiceModelBase
MiqAeServiceCustomizationTemplateCloudInit < MiqAeServiceCustomizationTemplate < MiqAeServiceModelBase
MiqAeServiceCustomizationTemplateKickstart < MiqAeServiceCustomizationTemplate < MiqAeServiceModelBase
MiqAeServiceCustomizationTemplateSysprep < MiqAeServiceCustomizationTemplate < MiqAeServiceModelBase
MiqAeServiceEmsCloud < MiqAeServiceExtManagementSystem < MiqAeServiceModelBase
MiqAeServiceEmsCluster < MiqAeServiceModelBase
MiqAeServiceEmsEvent < MiqAeServiceModelBase
MiqAeServiceEmsFolder < MiqAeServiceModelBase
MiqAeServiceEmsInfra < MiqAeServiceExtManagementSystem < MiqAeServiceModelBase
MiqAeServiceEmsKvm < MiqAeServiceEmsInfra < MiqAeServiceExtManagementSystem < MiqAeServiceModelBase
MiqAeServiceEmsMicrosoft < MiqAeServiceEmsInfra < MiqAeServiceExtManagementSystem < MiqAeServiceModelBase
MiqAeServiceEmsRedhat < MiqAeServiceEmsInfra < MiqAeServiceExtManagementSystem < MiqAeServiceModelBase
MiqAeServiceEmsVmware < MiqAeServiceEmsInfra < MiqAeServiceExtManagementSystem < MiqAeServiceModelBase
MiqAeServiceExtManagementSystem < MiqAeServiceModelBase
MiqAeServiceFilesystem < MiqAeServiceModelBase
MiqAeServiceFlavor < MiqAeServiceModelBase
MiqAeServiceFlavorAmazon < MiqAeServiceFlavor < MiqAeServiceModelBase
MiqAeServiceFlavorOpenstack < MiqAeServiceFlavor < MiqAeServiceModelBase
MiqAeServiceFloatingIp < MiqAeServiceModelBase
MiqAeServiceFloatingIpAmazon < MiqAeServiceFloatingIp < MiqAeServiceModelBase
MiqAeServiceFloatingIpOpenstack < MiqAeServiceFloatingIp < MiqAeServiceModelBase
MiqAeServiceGuestApplication < MiqAeServiceModelBase
MiqAeServiceGuestDevice < MiqAeServiceModelBase
MiqAeServiceHardware < MiqAeServiceModelBase
MiqAeServiceHost < MiqAeServiceModelBase
MiqAeServiceHostKvm < MiqAeServiceHost < MiqAeServiceModelBase
MiqAeServiceHostMicrosoft < MiqAeServiceHost < MiqAeServiceModelBase
MiqAeServiceHostRedhat < MiqAeServiceHost < MiqAeServiceModelBase
MiqAeServiceHostVmware < MiqAeServiceHost < MiqAeServiceModelBase
MiqAeServiceHostVmwareEsx < MiqAeServiceHostVmware < MiqAeServiceHost < MiqAeServiceModelBase
MiqAeServiceIsoImage < MiqAeServiceModelBase
MiqAeServiceJob < MiqAeServiceModelBase
MiqAeServiceLan < MiqAeServiceModelBase
MiqAeServiceMiqGroup < MiqAeServiceModelBase
MiqAeServiceMiqHostProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqHostProvisionRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceMiqPolicy < MiqAeServiceModelBase
MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionAmazon < MiqAeServiceMiqProvisionCloud < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionCloud < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionOpenstack < MiqAeServiceMiqProvisionCloud < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionRedhat < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionRedhatViaIso < MiqAeServiceMiqProvisionRedhat < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionRedhatViaPxe < MiqAeServiceMiqProvisionRedhat < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceMiqProvisionRequestTemplate < MiqAeServiceMiqProvisionRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceMiqProvisionVmware < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionVmwareViaNetAppRcu < MiqAeServiceMiqProvisionVmware < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProvisionVmwareViaPxe < MiqAeServiceMiqProvisionVmware < MiqAeServiceMiqProvision < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqProxy < MiqAeServiceModelBase
MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceMiqServer < MiqAeServiceModelBase
MiqAeServiceMiqTemplate < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceNetwork < MiqAeServiceModelBase
MiqAeServiceOperatingSystem < MiqAeServiceModelBase
MiqAeServicePxeImage < MiqAeServiceModelBase
MiqAeServicePxeImageIpxe < MiqAeServicePxeImage < MiqAeServiceModelBase
MiqAeServicePxeImagePxelinux < MiqAeServicePxeImage < MiqAeServiceModelBase
MiqAeServicePxeServer < MiqAeServiceModelBase
MiqAeServiceResourcePool < MiqAeServiceModelBase
MiqAeServiceSecurityGroup < MiqAeServiceModelBase
MiqAeServiceSecurityGroupAmazon < MiqAeServiceSecurityGroup < MiqAeServiceModelBase
MiqAeServiceSecurityGroupOpenstack < MiqAeServiceSecurityGroup < MiqAeServiceModelBase
MiqAeServiceService < MiqAeServiceModelBase
MiqAeServiceServiceResource < MiqAeServiceModelBase
MiqAeServiceServiceTemplate < MiqAeServiceModelBase
MiqAeServiceServiceTemplateProvisionRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceServiceTemplateProvisionTask < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceSnapshot < MiqAeServiceModelBase
MiqAeServiceStorage < MiqAeServiceModelBase
MiqAeServiceSwitch < MiqAeServiceModelBase
MiqAeServiceTemplateAmazon < MiqAeServiceTemplateCloud < MiqAeServiceMiqTemplate < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceTemplateCloud < MiqAeServiceMiqTemplate < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceTemplateInfra < MiqAeServiceMiqTemplate < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceTemplateKvm < MiqAeServiceTemplateInfra < MiqAeServiceMiqTemplate < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceTemplateMicrosoft < MiqAeServiceTemplateInfra < MiqAeServiceMiqTemplate < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceTemplateOpenstack < MiqAeServiceTemplateCloud < MiqAeServiceMiqTemplate < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceTemplateRedhat < MiqAeServiceTemplateInfra < MiqAeServiceMiqTemplate < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceTemplateVmware < MiqAeServiceTemplateInfra < MiqAeServiceMiqTemplate < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceTemplateXen < MiqAeServiceTemplateInfra < MiqAeServiceMiqTemplate < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceUser < MiqAeServiceModelBase
MiqAeServiceVdiFarm < MiqAeServiceModelBase
MiqAeServiceVdiFarmCitrix < MiqAeServiceVdiFarm < MiqAeServiceModelBase
MiqAeServiceVdiFarmRdp < MiqAeServiceVdiFarm < MiqAeServiceModelBase
MiqAeServiceVdiFarmVmware < MiqAeServiceVdiFarm < MiqAeServiceModelBase
MiqAeServiceVm < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceVmAmazon < MiqAeServiceVmCloud < MiqAeServiceVm < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceVmCloud < MiqAeServiceVm < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceVmInfra < MiqAeServiceVm < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceVmKvm < MiqAeServiceVmInfra < MiqAeServiceVm < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceVmMicrosoft < MiqAeServiceVmInfra < MiqAeServiceVm < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceVmMigrateRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceVmMigrateTask < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceVmOpenstack < MiqAeServiceVmCloud < MiqAeServiceVm < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceVmReconfigureRequest < MiqAeServiceMiqRequest < MiqAeServiceModelBase
MiqAeServiceVmReconfigureTask < MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
MiqAeServiceVmRedhat < MiqAeServiceVmInfra < MiqAeServiceVm < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceVmVmware < MiqAeServiceVmInfra < MiqAeServiceVm < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceVmXen < MiqAeServiceVmInfra < MiqAeServiceVm < MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
MiqAeServiceWindowsImage < MiqAeServiceModelBase
```