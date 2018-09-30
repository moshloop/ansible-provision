# AWS Role

An opionionated ansible role for launching and configuring AWS EC2 instances, it provides the following functionality:

- Instance launch
- Attaching EBS volumes
- Formatting and mounting EBS and Instance volumes
- Tagging
- Creating security groups from graphviz defintions
- Adding instances to security group based on Inventory groups

It does not:

- Configure or create any VPC's or Subnets

### Assumptions

- You have an existing AWS account with credentials loaded in a manner that is usable by the `aws` CLI.
- You have default VPC and subnets configured, or you have their names to configure as follows
- When multiple instances are configured they are launched in all AZ's in a round robin fashion


### Runtime Arguments

Pass runtime arguments using `-e` e.g. `-e dry_run=true`

| Argument                  | Default | Description |
| -----------------------   | ------- | ----------- |
| dry_run                   | false   | Only render the templates and do not attempt to apply            |
| ami_update                | true    | Set to false to disable updating the AMI, causing the instance to be terminated and be re-created |
| userData_update           | true    | Set to false to disable updating the user-data which would normally cause instances to be restarted |
| debug                     | false   | Increase debug output of AWS responses |

### Global Configuration

```yaml
account_id:
internal_domain:
cf_template_bucket:
region:
security_groups:
    - default
    - "{{role}}"
default_ssl_certificate: self_signed_default
instance_type: m4.xlarge
subnet_name:
instance_role: Server
ami: base
ssh_key_name:
elbs:
    - group1
    - group2
```

| Config                  | Default                                       | Description                                          |
| ----------------------- | --------------------------------------------- | ---------------------------------------------------- |
| account_id              |                                               | aws account id                                       |
| internal_domain         |                                               | domain that is used for internal DNS lookup          |
| cf_template_bucket      |                                               | bucket name to upload the cloudformation template to |
| region                  |                                               | AWS region                                           |
| security_groups         | default <br>{{role}} <br>{{role}}-{{purpose}} | A list of security group names to apply              |
| default_ssl_certificate | self_signed_default                           | name to use for the self signed SSL placeholder      |
| elbs                    |                                               | a list of groups that include elb's                  |

### Instance Level Configuration

```yaml
role: liferay
purposeId: vcp
purpose: Liferay Server VSP
instance_role: K8-Worker
instance_type: m4.2xlarge
instance_volumes:
    - {dev: /dev/nvme0n1, mount: /mnt/nvm, format: xfs}
volumes:
    - {size: 100, id: docker, dev: /dev/xvdh, format: xfs, mount: /var/lib/docker}
    - {size: 100, id: thinpool, dev: /dev/xvdi}
conns:
    - {group: db, ports: "5446"}
logs:
    - /opt/liferay/tomcat-8.0.32/logs/catalina.out
elb:
    - {port: 8443}
```
| Config          | Default | Type | Description |
| --------------- | ------- | ---- | ----------- |
| instance_type** |         |      |             |
| instance_role** |         |      |             |
| subnet_name**   |         |      |             |
| ami**           |         |      |             |
| tags            |         |      |             |
| role            |         |      |             |
| purpose         |         |      |             |
| purposeId       |         |      |             |
| logs            |         |      |             |
| conns           |         |      |             |

** These configs can have defaults specified at the global level

### Loadbalancers

```yaml
elb:
	- {}
```
| Name           | Default           | Description                                           |
| -------------- | ----------------- | ----------------------------------------------------- |
| port           |                   |                                                       |
| type           | http              | http,https,tcp                                        |
| check          | {port}/           |                                                       |
| alb            | false             | Create a Application Load Balancer instead of classic |
| checkPath      | /                 | ALB only:                                             |
| checkPort      | {port}            | ALB only:                                             |
| checkType      | {type}            | ALB only:                                             |
| code           | 200               | ALB only                                              |
| sslId          | {default_ssl_arn} |                                                       |
| alias          | {group_name}      |                                                       |
| security_group |                   |                                                       |
| scheme         | internal          |                                                       |


### Network Volume

```yaml
volumes:
	- {}
```

| Name   | Default | Description                                                  |
| ------ | ------- | ------------------------------------------------------------ |
| size   |         | Size in GB of the volume                                     |
| id     |         | The name of the volume e.g. volume it will be used as suffix |
| dev    |         | The unique device path to use e.g. /dev/xvf                  |
| type   | gp2     |                                                              |
| format |         | Optional: Partition type e.g. xfs                            |
| mount  |         | Optional: Mount point for the volume e.g. /mnt/volume        |

### Instance Volume

```yaml
instance_volumes:
    - {}
```

| Name   | Default | Description |
| ------ | ------- | ----------- |
| dev    |         |             |
| format |         |             |
| mount  |         |             |

#### Tagging

```yaml
tags:
    CI OWNER NAME: JOHN DOE
all_tags:
    Name: "{{inventory_hostname}}"
    ROLE: "{{role}}"
    PURPOSE: "{{purposeId}}"
```

The way inventories work in ansible prevents dictionaries being merged, `all_tags` are the tags applied to all instances, while `tags` are specified on a group level. Values specified in `tags` will overwrite values in `all_tags`

Name, ROLE and PURPOSE tags are the minimum recommended tags

## Bootstrapping

| Name         | Default         | Description                                                  |
| ------------ | --------------- | ------------------------------------------------------------ |
| ssh_key_user | ec2-user        | The name of the preconfigured user in the image              |
| ssh_key_full |                 | The SSH public key to install as an authorized key for `ssh_key_user` |
| git_repo     |                 |                                                              |
| git_branch   | master          |                                                              |
| git_path     | /etc/repository |                                                              |
| git_account  |                 | Optional: The AWS account that `git_repo` is hosted in       |
| git_role     |                 | Optional: An IAM role in `git_account` that has *codecommit* permissions on `git_repo` |
| phone_home   |                 | A bash snippet that gets executed at the end of bootstrapping - e.g. To execute an initial Ansible Tower playbook run |

A cloud-init file is specified on launch that provides:

1. Inserts the `ssh_key_full` public key into the `ssh_key_user`'s authorized_keys file
1. Formats and mounts any volumes that have mount params and adds them into `/etc/fstab`
1. Updates the hostname
1. Updates `/etc/environment` with the *role, purpose, purposeId, environment, region, domain, ami* values
1. Configures git to use the `git_account/git_role` IAM role for AWS CodeCommit checkouts (if specified)
1. Clones `git_repo` to `git_path` and installs any git hooks in the `.hooks` directory and execute the *post-merge* hook.
1. Installs a systemd service and timer `git-sync` that keeps the git repo in sync.
1. Executes the script specified in `phone_home`


### Updating firewall rules
1. Update the `firewall/*.gv` definitions

> NB: If you need to override rules from ca-core first delete the symlink and then copy the file

1. (Optionally) Generate the diagrams using ./firewall/build.sh
1. Deploy the changes using

    ansible-playbook -i inventory/{env} -c local -t fw

> If this is not the first time creating the security groups, then a Cloudformation changeset will be created and will need to be manually applied in the AWS Console

### Running ansible container:

```bash
docker run -u 1001 -d -v ssh:/ssh --name=ssh-agent whilp/ssh-agent:latest
docker run -u 1001 --rm -v ssh:/ssh -v $HOME:$HOME -it whilp/ssh-agent:latest ssh-add $HOME/.ssh/id_rsa
./run.sh
```
