# Getting Started

`ansible-provision` is a suite of ansible roles that provide a common interface for provisioning infrastructure.
While there is a slant towards AWS services many interfaces support vmware vCenter and Azure.

The general worklow is to generate declarative templates (e.g. AWS Cloudformation / Azure Resource Templates) rather than interfacing directly with API's.

cloud-init is used extensively to setup volumes and bootstrap instances for deployment.

## Dependencies

* [ansible-deploy](http://www.moshloop.com/ansible-deploy) which shares many of the same interfaces is used to generate cloudinit config.
* [systools](https://github.com/moshloop/systools) provides many helpers and bootstraping tools and will be installed by ansible-deploy if it is missing.


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
