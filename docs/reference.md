
| Option           | Description                                  | AWS      | Azure | vSphere             |
| ---------------- | -------------------------------------------- | -------- | ----- | ------------------- |
| ami              | Image name                                  |          |       | *alias: template*   |
| region |  | | | *alias: datacenter* |
| az               | Availability zone                            |          |       | *alias: cluster*    |
| cpu | Number of cores, Default: 2 | ✖ | ✖ |  |
| mem | GB of memory, Default: 2 | ✖ | ✖ |  |
| instance_type |  |  |  | ✖ *Use mem and cpu* |
| subnet_name |  | | | *alias: vlan* |
| tags, all_tags | Map of tags | | |  |
| **Volumes** |  | | |  |
| boot_disk_size   |                                              |          |       |                     |
| boot_disk_type   |                                              | gp2      | ✖     | ✖                   |
| data_volume_size | Shorthand for creating a default data volume |          |       |                     |
| instance_volumes |  | | ✖ | ✖ |
| volumes | List of volumes | | | |
| **Security** |  |  |  | |
| instance_role    | IAM Instance Role                            |          | ✖     | ✖                   |
| security_groups  | List of security group names                 |          | ✖     | ✖                   |
| ssh_key_full     |                                              |          |       |                     |
| ssh_key_name     | AWS SSH Key Pair Name                        |          | ✖     | ✖                   |
| ssh_key_user     | Defaults to: ec2-user |  |       |                     |
| **Bootstrapping** |  | | | |
| phone_home | List of commands to run on startup | | | |
| **Load Balancing** |  | | | |
| elbs | List of group names to create load balancers for | | ✖ | ✖ |