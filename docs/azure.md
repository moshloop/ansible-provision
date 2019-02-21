

### Options

| Config                  | Default                                       | Description                                          |
| ----------------------- | --------------------------------------------- | ---------------------------------------------------- |
| **account_id**          |                                               | Azure subscription id                     |
| **infra_resource_group** | | Resource group for the network |
| **resource_group** | | Resource group for VM's |
| **region** | |  |
| vpc_id | |  |
| az_managed | |  |
| boot_diag_uri | |  |
| backup_vault | |  |
| public_ip | |  |
| security_groups         | default <br>{{role}} <br>{{role}}-{{purpose}} | A list of security group names to apply              |
| image |  |  |
| OR |  |  |
| image_publisher | RedHat |  |
| image_offer | RHEL |  |
| image_sku | 7.5 |  |
| image_version | latest |  |