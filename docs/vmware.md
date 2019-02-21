# VMWare

VMWare provisioning is done via the vCenter api's and a cloud-init script that is bundled into an ISO (per VM).

![](../images/vmware_lifecycle.png)



You first need to create a base VM template or image to use for cloning from:

```yaml
target: vmware
template: BASE_TEMPLATE
vcenter_hostname: 
vcenter_username:
vcenter_password: 
region: dc1 
az: cluster1
#Specify either the VLAN ID or switch name
subnet_name: 1
```

### Options

| Config                  | Default                                       | Description                                          |
| ----------------------- | --------------------------------------------- | ---------------------------------------------------- |
| **datacenter** |                                               | *alias: region*                        |
| **cluster** |                                               | *alias: az* |
| **vlan** | | *alias: subnet_name* |
| **vcenter_hostname** | |  |
| **vcenter_username** | |  |
| **vcenter_password** | |  |
| vm_groups | |  |
| vm_attributes | | *alias: tags* |
| datastore | |  |

