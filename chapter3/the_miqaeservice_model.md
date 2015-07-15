## The MiqAeService* Model

(This section contains background (albeit useful) information - feel free to skip over on a first pass of the book).

The objects that we work with in the Automation Engine are all _Service Models_ - instances of an MiqAeService* class that abstract and make available to us their corresponding Rails Active Record. For example we access the Rails _User_ Active Record indirectly using the _MiqAeServiceUser_ Automation Engine class.

Fortunately the Automation Engine hides this from us pretty well, and generally presents the appropriate object to us via $evm.root (for example if we're working with a ```$evm.root['vm']``` object from a RHEV provider, it's actually an instance of an _MiqAeServiceVmRedhat_ object).

All of the MiqAeService\* objects extend a common _MiqAeServiceModelBase_ class that contains some common methods available to all objects, such as...

```
.tagged_with?(category, name)
.tags(category = nil)
.tag_assign(tag)
```

(see section xxx on working with tags in Automate). Many of the Service Model objects have several levels of superclass, e.g.

```
MiqAeServiceMiqProvisionRedhatViaPxe <
	MiqAeServiceMiqProvisionRedhat <
		MiqAeServiceMiqProvision <
			MiqAeServiceMiqRequestTask <
				MiqAeServiceModelBase
```

The following list is the class definition for all of the CloudForms 3.2 MiqAeService Model classes, showing their immediate superclass...

```
 class MiqAeServiceAuthKeyPairCloud < MiqAeServiceAuthPrivateKey
 class MiqAeServiceAuthKeyPairOpenstack < MiqAeServiceAuthKeyPairCloud
 class MiqAeServiceAuthPrivateKey < MiqAeServiceAuthentication
 class MiqAeServiceAuthentication < MiqAeServiceModelBase
 class MiqAeServiceAutomationRequest < MiqAeServiceMiqRequest
 class MiqAeServiceAutomationTask < MiqAeServiceMiqRequestTask
 class MiqAeServiceAvailabilityZone < MiqAeServiceModelBase
 class MiqAeServiceAvailabilityZoneAmazon < MiqAeServiceAvailabilityZone
 class MiqAeServiceAvailabilityZoneOpenstack < MiqAeServiceAvailabilityZone
 class MiqAeServiceAvailabilityZoneOpenstackNull < MiqAeServiceAvailabilityZoneOpenstack
 class MiqAeServiceClassification < MiqAeServiceModelBase
 class MiqAeServiceCloudNetwork < MiqAeServiceModelBase
 class MiqAeServiceCloudObjectStoreContainer < MiqAeServiceModelBase
 class MiqAeServiceCloudObjectStoreObject < MiqAeServiceModelBase
 class MiqAeServiceCloudResourceQuota < MiqAeServiceModelBase
 class MiqAeServiceCloudResourceQuotaOpenstack < MiqAeServiceCloudResourceQuota
 class MiqAeServiceCloudSubnet < MiqAeServiceModelBase
 class MiqAeServiceCloudTenant < MiqAeServiceModelBase
 class MiqAeServiceCloudVolume < MiqAeServiceModelBase
 class MiqAeServiceCloudVolumeAmazon < MiqAeServiceCloudVolume
 class MiqAeServiceCloudVolumeOpenstack < MiqAeServiceCloudVolume
 class MiqAeServiceCloudVolumeSnapshot < MiqAeServiceModelBase
 class MiqAeServiceCloudVolumeSnapshotAmazon < MiqAeServiceCloudVolumeSnapshot
 class MiqAeServiceCloudVolumeSnapshotOpenstack < MiqAeServiceCloudVolumeSnapshot
 class MiqAeServiceConfigurationArchitecture < MiqAeServiceConfigurationTag
 class MiqAeServiceConfigurationComputeProfile < MiqAeServiceConfigurationTag
 class MiqAeServiceConfigurationDomain < MiqAeServiceConfigurationTag
 class MiqAeServiceConfigurationEnvironment < MiqAeServiceConfigurationTag
 class MiqAeServiceConfigurationLocation < MiqAeServiceModelBase
 class MiqAeServiceConfigurationManager < MiqAeServiceModelBase
 class MiqAeServiceConfigurationManagerForeman < MiqAeServiceConfigurationManager
 class MiqAeServiceConfigurationOrganization < MiqAeServiceModelBase
 class MiqAeServiceConfigurationProfile < MiqAeServiceModelBase
 class MiqAeServiceConfigurationProfileForeman < MiqAeServiceConfigurationProfile
 class MiqAeServiceConfigurationRealm < MiqAeServiceConfigurationTag
 class MiqAeServiceConfigurationTag < MiqAeServiceModelBase
 class MiqAeServiceConfiguredSystem < MiqAeServiceModelBase
 class MiqAeServiceConfiguredSystemForeman < MiqAeServiceConfiguredSystem
 class MiqAeServiceCustomizationScript < MiqAeServiceModelBase
 class MiqAeServiceCustomizationScriptMedium < MiqAeServiceCustomizationScript
 class MiqAeServiceCustomizationScriptPtable < MiqAeServiceCustomizationScript
 class MiqAeServiceCustomizationTemplate < MiqAeServiceModelBase
 class MiqAeServiceCustomizationTemplateCloudInit < MiqAeServiceCustomizationTemplate
 class MiqAeServiceCustomizationTemplateKickstart < MiqAeServiceCustomizationTemplate
 class MiqAeServiceCustomizationTemplateSysprep < MiqAeServiceCustomizationTemplate
 class MiqAeServiceDisk < MiqAeServiceModelBase
 class MiqAeServiceEmsAmazon <  MiqAeServiceEmsCloud
 class MiqAeServiceEmsCloud < MiqAeServiceExtManagementSystem
 class MiqAeServiceEmsCluster < MiqAeServiceModelBase
 class MiqAeServiceEmsClusterOpenstackInfra < MiqAeServiceEmsCluster
 class MiqAeServiceEmsEvent < MiqAeServiceModelBase
 class MiqAeServiceEmsFolder < MiqAeServiceModelBase
 class MiqAeServiceEmsInfra < MiqAeServiceExtManagementSystem
 class MiqAeServiceEmsMicrosoft < MiqAeServiceEmsInfra
 class MiqAeServiceEmsOpenstack <  MiqAeServiceEmsCloud
 class MiqAeServiceEmsOpenstackInfra <  MiqAeServiceEmsInfra
 class MiqAeServiceEmsRedhat < MiqAeServiceEmsInfra
 class MiqAeServiceEmsVmware < MiqAeServiceEmsInfra
 class MiqAeServiceExtManagementSystem < MiqAeServiceModelBase
 class MiqAeServiceFilesystem < MiqAeServiceModelBase
 class MiqAeServiceFirewallRule < MiqAeServiceModelBase
 class MiqAeServiceFlavor < MiqAeServiceModelBase
 class MiqAeServiceFlavorAmazon < MiqAeServiceFlavor
 class MiqAeServiceFlavorOpenstack < MiqAeServiceFlavor
 class MiqAeServiceFloatingIp < MiqAeServiceModelBase
 class MiqAeServiceFloatingIpAmazon < MiqAeServiceFloatingIp
 class MiqAeServiceFloatingIpOpenstack < MiqAeServiceFloatingIp
 class MiqAeServiceGuestApplication < MiqAeServiceModelBase
 class MiqAeServiceGuestDevice < MiqAeServiceModelBase
 class MiqAeServiceHardware < MiqAeServiceModelBase
 class MiqAeServiceHost < MiqAeServiceModelBase
 class MiqAeServiceHostMicrosoft < MiqAeServiceHost
 class MiqAeServiceHostOpenstackInfra < MiqAeServiceHost
 class MiqAeServiceHostRedhat < MiqAeServiceHost
 class MiqAeServiceHostVmware < MiqAeServiceHost
 class MiqAeServiceHostVmwareEsx < MiqAeServiceHostVmware
 class MiqAeServiceIsoImage < MiqAeServiceModelBase
 class MiqAeServiceJob < MiqAeServiceModelBase
 class MiqAeServiceLan < MiqAeServiceModelBase
 class MiqAeServiceMiqGroup < MiqAeServiceModelBase
 class MiqAeServiceMiqHostProvision < MiqAeServiceMiqRequestTask
 class MiqAeServiceMiqHostProvisionRequest < MiqAeServiceMiqRequest
 class MiqAeServiceMiqPolicy < MiqAeServiceModelBase
 class MiqAeServiceMiqProvision < MiqAeServiceMiqProvisionTask
 class MiqAeServiceMiqProvisionAmazon < MiqAeServiceMiqProvisionCloud
 class MiqAeServiceMiqProvisionCloud < MiqAeServiceMiqProvision
 class MiqAeServiceMiqProvisionConfiguredSystemRequest < MiqAeServiceMiqRequest
 class MiqAeServiceMiqProvisionMicrosoft < MiqAeServiceMiqProvision
 class MiqAeServiceMiqProvisionOpenstack < MiqAeServiceMiqProvisionCloud
 class MiqAeServiceMiqProvisionRedhat < MiqAeServiceMiqProvision
 class MiqAeServiceMiqProvisionRedhatViaIso < MiqAeServiceMiqProvisionRedhat
 class MiqAeServiceMiqProvisionRedhatViaPxe < MiqAeServiceMiqProvisionRedhat
 class MiqAeServiceMiqProvisionRequest < MiqAeServiceMiqRequest
 class MiqAeServiceMiqProvisionRequestTemplate < MiqAeServiceMiqProvisionRequest
 class MiqAeServiceMiqProvisionTask < MiqAeServiceMiqRequestTask
 class MiqAeServiceMiqProvisionTaskConfiguredSystemForeman < MiqAeServiceMiqProvisionTask
 class MiqAeServiceMiqProvisionVmware < MiqAeServiceMiqProvision
 class MiqAeServiceMiqProvisionVmwareViaPxe < MiqAeServiceMiqProvisionVmware
 class MiqAeServiceMiqRequest < MiqAeServiceModelBase
 class MiqAeServiceMiqRequestTask < MiqAeServiceModelBase
 class MiqAeServiceMiqServer < MiqAeServiceModelBase
 class MiqAeServiceMiqTemplate < MiqAeServiceVmOrTemplate
 class MiqAeServiceNetwork < MiqAeServiceModelBase
 class MiqAeServiceOperatingSystem < MiqAeServiceModelBase
 class MiqAeServiceOperatingSystemFlavor < MiqAeServiceModelBase
 class MiqAeServiceOrchestrationStack < MiqAeServiceModelBase
 class MiqAeServiceOrchestrationStackAmazon < MiqAeServiceOrchestrationStack
 class MiqAeServiceOrchestrationStackOpenstack < MiqAeServiceOrchestrationStack
 class MiqAeServiceOrchestrationStackOpenstackInfra < MiqAeServiceOrchestrationStack
 class MiqAeServiceOrchestrationStackOutput < MiqAeServiceModelBase
 class MiqAeServiceOrchestrationStackParameter < MiqAeServiceModelBase
 class MiqAeServiceOrchestrationStackResource < MiqAeServiceModelBase
 class MiqAeServiceOrchestrationTemplate < MiqAeServiceModelBase
 class MiqAeServiceOrchestrationTemplateCfn < MiqAeServiceOrchestrationTemplate
 class MiqAeServiceOrchestrationTemplateHot < MiqAeServiceOrchestrationTemplate
 class MiqAeServiceProvider < MiqAeServiceModelBase
 class MiqAeServiceProviderForeman < MiqAeServiceProvider
 class MiqAeServiceProvisioningManager < MiqAeServiceModelBase
 class MiqAeServiceProvisioningManagerForeman < MiqAeServiceProvisioningManager
 class MiqAeServicePxeImage < MiqAeServiceModelBase
 class MiqAeServicePxeImageIpxe < MiqAeServicePxeImage
 class MiqAeServicePxeImagePxelinux < MiqAeServicePxeImage
 class MiqAeServicePxeImageType < MiqAeServiceModelBase
 class MiqAeServicePxeServer < MiqAeServiceModelBase
 class MiqAeServiceResourcePool < MiqAeServiceModelBase
 class MiqAeServiceSecurityGroup < MiqAeServiceModelBase
 class MiqAeServiceSecurityGroupAmazon < MiqAeServiceSecurityGroup
 class MiqAeServiceSecurityGroupOpenstack < MiqAeServiceSecurityGroup
 class MiqAeServiceService < MiqAeServiceModelBase
 class MiqAeServiceServiceOrchestration < MiqAeServiceService
 class MiqAeServiceServiceReconfigureRequest < MiqAeServiceMiqRequest
 class MiqAeServiceServiceReconfigureTask < MiqAeServiceMiqRequestTask
 class MiqAeServiceServiceResource < MiqAeServiceModelBase
 class MiqAeServiceServiceTemplate < MiqAeServiceModelBase
 class MiqAeServiceServiceTemplateOrchestration < MiqAeServiceServiceTemplate
 class MiqAeServiceServiceTemplateProvisionRequest < MiqAeServiceMiqRequest
 class MiqAeServiceServiceTemplateProvisionTask < MiqAeServiceMiqRequestTask
 class MiqAeServiceSnapshot < MiqAeServiceModelBase
 class MiqAeServiceStorage < MiqAeServiceModelBase
 class MiqAeServiceSwitch < MiqAeServiceModelBase
 class MiqAeServiceTemplateAmazon < MiqAeServiceTemplateCloud
 class MiqAeServiceTemplateCloud < MiqAeServiceMiqTemplate
 class MiqAeServiceTemplateInfra < MiqAeServiceMiqTemplate
 class MiqAeServiceTemplateMicrosoft < MiqAeServiceTemplateInfra
 class MiqAeServiceTemplateOpenstack < MiqAeServiceTemplateCloud
 class MiqAeServiceTemplateRedhat < MiqAeServiceTemplateInfra
 class MiqAeServiceTemplateVmware < MiqAeServiceTemplateInfra
 class MiqAeServiceTemplateXen < MiqAeServiceTemplateInfra
 class MiqAeServiceUser < MiqAeServiceModelBase
 class MiqAeServiceVm < MiqAeServiceVmOrTemplate
 class MiqAeServiceVmAmazon < MiqAeServiceVmCloud
 class MiqAeServiceVmCloud < MiqAeServiceVm
 class MiqAeServiceVmInfra < MiqAeServiceVm
 class MiqAeServiceVmMicrosoft < MiqAeServiceVmInfra
 class MiqAeServiceVmMigrateRequest < MiqAeServiceMiqRequest
 class MiqAeServiceVmMigrateTask < MiqAeServiceMiqRequestTask
 class MiqAeServiceVmOpenstack < MiqAeServiceVmCloud
 class MiqAeServiceVmOrTemplate < MiqAeServiceModelBase
 class MiqAeServiceVmReconfigureRequest < MiqAeServiceMiqRequest
 class MiqAeServiceVmReconfigureTask < MiqAeServiceMiqRequestTask
 class MiqAeServiceVmRedhat < MiqAeServiceVmInfra
 class MiqAeServiceVmScan < MiqAeServiceJob
 class MiqAeServiceVmVmware < MiqAeServiceVmInfra
 class MiqAeServiceVmXen < MiqAeServiceVmInfra
 class MiqAeServiceWindowsImage < MiqAeServiceModelBase
```

###Distributed Ruby (druby)

Many of the $evm methods such as _.root_ and _.object_ are  Distributed Ruby (druby) stub objects (_DRb::DRbObject_ objects). The actual methods are DRb server methods that run in a different namespace, accessed using a URI such as...

 ```
 druby://127.0.0.1:52182
 ```

Although this is mostly transparent to us, it means that if we look at things like $evm.root['vm'].instance\_methods (hoping to find some useful VM-related method that we can call), we actually get a list of the instance methods for the local _DRb::DRbObject_ object, rather than the remote MiqAeServiceUser service model (not what we want). We also occasionally get a _DRb::DRbUnknown_ object returned to us, indicating that our receiver doesn't know about the class definition for a distributed object.
