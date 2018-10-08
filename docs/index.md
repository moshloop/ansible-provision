# Getting Started

`ansible-provision` is part of suite of ansible roles that provide a common interface for provisioning infrastructure.
While there is a slant towards AWS services many interfaces support vmware vCenter and Azure.

## Design Principles

* Convention over configuration - Require as minimal configuration as possible, lookup ids in the background and use conventions whenever possible
* Prefer declarative template (e.g. AWS Cloudformation / Azure Resource Templates) to direct API calls
* Use cloud-init extensively to setup volumes and bootstrap instances for deployment.

## Dependencies

* ansible (duh)
* [ansible-deploy](http://www.moshloop.com/ansible-deploy) is used to generate cloudinit config (It shares many of the same interfaces as ansible-provision)
* [systools](https://github.com/moshloop/systools) provides many helpers and bootstraping tools (systools will be installed by ansible-deploy if it is missing)
* [fireviz](https://github.com/moshloop/fireviz) is a tool to convert Graphviz firewall diagrams into Cloudformation/ARM templates
* (Optional) [ansible-dependencies](https://github.com/moshloop/ansible-dependencies) provides RPM, DEB and pip packages that simplify the installation of ansible with all the required dependencies to use cloud and networking modules
* (Optional) [ansible-run](http://www.moshloop.com/ansible-run) provides CLI tools for easily running and testing ansible playbooks using ansible-dependencies.

## Folder Structure

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
