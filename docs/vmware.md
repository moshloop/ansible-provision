# VMWare

VMWare provisioning is done via the vCenter api's and a cloud-init script that is bundled into an ISO (per VM).

![](../images/aws_lifecycle.png)

| Config                  | Default                                       | Description                                          |
| ----------------------- | --------------------------------------------- | ---------------------------------------------------- |
| datacenter     |                                               | *alias: region*                        |
| cluster  |                                               | *alias: az* |
| vlan | | *alias: subnet_name* |
| hostname | |  |
| username | |  |
| password | |  |
| vm_groups | |  |
| vm_attributes | | *alias: tags* |
| datastore | |  |