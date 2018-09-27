# Getting Started

Opionated role for creating shortcuts for various ansible tasks

### Folder Structure



```yaml
├── cloudformation           # applies to AWS only
│   └── iam.cf
├── firewall
│   ├── all.gv
│   └── mapping.yml
├── inventory
│   ├── group_vars
│   │   ├── all
│   │   ├── app
│   │   ├── db
│   │   ├── dev
│   │   ├── test
│   │   └── web
│   └── hosts
├── play.yml
└── roles
    └── requirements.yml
```



### Global Configuration

```yaml
account_id:
domain:
domain_id:
region:
security_groups:
    - default
    - "{{role}}"
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
| domain         |                                               | domain that is used for internal DNS lookup          |
| domain_id | |  |
| region                  |                                               | AWS region                                           |
| security_groups         | default <br>{{role}} <br>{{role}}-{{purpose}} | A list of security group names to apply              |
| default_ssl_certificate | self_signed_default                           | name to use for the self signed SSL placeholder      |
| elbs                    |                                               | a list of groups that include elb's                  |


