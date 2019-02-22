## AWS
The AWS provisioning lifecycle uses ansible to generate cloudformation - there are some [runtime arguments](#runtime-arguments) that can be used to reduce the aggressiveness of the Cloudformation replacement rules.

![](../images/aws_lifecycle.png)


### Dependencies

1. First setup the environment with AWS access credentials, either via `~/.aws/credentials`, `AWS_ACCESS_KEY` environment variable, or an IAM instance profile.
2. Create the VPC and subnet infrastracture - either via cloudformation in the `cloudformation` directory or manually.
3. Ensure all subnet's have Name tags which are used to lookup subnet-ids based on `subnet_name`



### Setup

```yaml
region: eu-west-1
account_id: 1234
vpc_id: vpc-223
```



### Options

| Config                  | Default                                       | Description                                          |
| ----------------------- | --------------------------------------------- | ---------------------------------------------------- |
| **account_id**          |                                               | AWS Account ID                          |
| **region** | | AWS region |
| **vpc_id** | |  |
| domain         |                                               | domain that is used for internal DNS lookup          |
| domain_id | |  |
| security_groups         | default <br>{{role}} <br>{{role}}-{{purpose}} | A list of security group names to apply              |
| default_ssl_certificate | self_signed_default                           | name to use for the self signed SSL placeholder      |
| elbs |  | a list of groups that include elb's |



### Runtime Arguments

Pass runtime arguments using `-e` e.g. `-e ami_update=true` or save on a per host / group level

| Argument          | Default | Description                                                  |
| ----------------- | ------- | ------------------------------------------------------------ |
| ami_update        | false   | Set to false to disable updating the AMI, causing the instance to be terminated and be re-created |
| userData_update   | false   | Set to false to disable updating the user-data which would normally cause instances to be restarted |
| boot_disk_update  | false   |                                                              |
| create_change_set | true    |                                                              |
