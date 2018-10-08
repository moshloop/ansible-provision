## AWS
The AWS provisioning lifecycle uses ansible to generate cloudformation - there are some runtime arguments that can be used to reduce the aggressiveness of the Cloudformation replacement rules. 

![](../images/aws_lifecycle.png)

| Config                  | Default                                       | Description                                          |
| ----------------------- | --------------------------------------------- | ---------------------------------------------------- |
| account_id              |                                               | aws account id                                       |
| domain         |                                               | domain that is used for internal DNS lookup          |
| domain_id | |  |
| region                  |                                               | AWS region                                           |
| security_groups         | default <br>{{role}} <br>{{role}}-{{purpose}} | A list of security group names to apply              |
| default_ssl_certificate | self_signed_default                           | name to use for the self signed SSL placeholder      |
| elbs |  | a list of groups that include elb's |



### Runtime Arguments

Pass runtime arguments using `-e` e.g. `-e ami_update=true`

| Argument          | Default | Description                                                  |
| ----------------- | ------- | ------------------------------------------------------------ |
| ami_update        | false   | Set to false to disable updating the AMI, causing the instance to be terminated and be re-created |
| userData_update   | false   | Set to false to disable updating the user-data which would normally cause instances to be restarted |
| boot_disk_update  | false   |                                                              |
| create_change_set | true    |                                                              |
