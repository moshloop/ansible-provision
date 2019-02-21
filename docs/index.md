# Getting Started

`ansible-provision` is part of suite of ansible roles that provide a common interface for provisioning infrastructure.
While there is a slant towards AWS services many interfaces support vmware vCenter and Azure.

## Design Principles

* Convention over configuration - Require as minimal configuration as possible, lookup ids in the background and use conventions whenever possible
* Prefer declarative template (e.g. AWS Cloudformation / Azure Resource Templates) to direct API calls
* Use cloud-init extensively to setup volumes and bootstrap instances for deployment.

## Dependencies

* ansible
* [ansible-deploy](http://www.moshloop.com/ansible-deploy) is used to generate cloudinit config files for bootrapping instances once they have been provisioned.

    `ansible-deploy` shares many of the same interfaces as `ansible-provision` so that for example an EBS volume can be provisioned and then formatted and mounted it into the filesystem on startup.

* [systools](https://github.com/moshloop/systools) provides many helpers and bootstraping tools (systools will be installed by ansible-deploy if it is missing)
* [fireviz](https://github.com/moshloop/fireviz) is a tool to convert Graphviz firewall diagrams into Cloudformation/ARM templates
* (Optional) [ansible-dependencies](https://github.com/moshloop/ansible-dependencies) provides RPM, DEB and pip packages that simplify the installation of ansible with all the required dependencies to use cloud and networking modules
* (Optional) [ansible-run](http://www.moshloop.com/ansible-run) provides CLI tools for easily running and testing ansible playbooks using ansible-dependencies.

### Quickstart with Virtual Box

1. Install Virtual Box and create a VM named "Ubuntu_Template"

2. Create an inventory file under `inventory/group_vars/all.yml`

   ```yaml
   target: virtualbox
   template: Ubuntu_Template
   ```

3. Install the CLI: `pip install ansible-provision`

4. Provision an instance: `ansible-provision --hostname test_instance`

## Targets

| Target              | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| [aws](./aws)                 | Generates and then executes CloudFormation templates for each ansible group |
| [aws-service-catalog](./aws-service-catalog) | Similar to `aws` but instead of creating an instance it creates a [service catalog](https://aws.amazon.com/servicecatalog/) product |
| [azure](./azure)               | Generates Azure Resource Templates and then executes them    |
| [vmware](./vmware)              | Creates VM's using the native ansible VMware modules and vCenter / vSphere        |
| [vmware-fusion](./vmware-fusion)       | Clones VM's using the `vmrun` CLI included with [VMware Fusion](https://www.vmware.com/products/fusion) |
| [VirtualBox](./virtualbox)         | Clones VM's using the `VBoxManage` CLI included with [VirtualBox](https://www.virtualbox.org/) |



### Pinning Versions

Both ansible-provision and ansible-deploy can be pinned to specific versions at an inventory level, rather than at an installation level. This works by checking out specific tags or branches just before running the role:

`inventory/group_vars/all.yml`

```yaml
ansible_deploy_version: 2.9.2
ansible_provision_version: 4.1
```



## Sample Folder Structure

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
