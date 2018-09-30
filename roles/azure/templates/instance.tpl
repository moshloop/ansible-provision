---
"$schema": http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#
contentVersion: 1.0.0.0
variables:
  vnetId: "[resourceId('{{infra_resource_group}}','Microsoft.Network/virtualNetworks', '{{vpc_id}}')]"
  subnetRef: "[concat(variables('vnetId'), '/subnets/{{subnet_name}}')]"
resources:

{% if az_managed %}
- apiVersion: "[providers('Microsoft.Compute', 'availabilitySets').apiVersions[0]]"
  type: Microsoft.Compute/availabilitySets
  name: "{{az}}"
  sku:
    name: Aligned
  location: "[resourceGroup().location]"
  properties:
    platformUpdateDomainCount: 5
    platformFaultDomainCount: 2
{% endif %}

- name: "{{inventory_hostname}}"
  type: Microsoft.Compute/virtualMachines
  apiVersion: 2016-04-30-preview
  location: "{{region}}"
  dependsOn:
  - "['Microsoft.Network/networkInterfaces/{{inventory_hostname}}-nic']"
  properties:
    osProfile:
      computerName: "{{inventory_hostname | lower}}"
      adminUsername: "{{ssh_key_user}}"
      linuxConfiguration:
        disablePasswordAuthentication: 'true'
        ssh:
          publicKeys:
          - path: "/home/{{ssh_key_user}}/.ssh/authorized_keys"
            keyData: {{ lookup('file', '~/.ssh/id_rsa.pub') }}
          - path: "/home/{{ssh_key_user}}/.ssh/authorized_keys"
            keyData: {{ssh_key_full}}
    hardwareProfile:
      vmSize: "{{instance_type}}"
{% if az_managed %}
    availabilitySet:
        id: "[resourceId('Microsoft.Compute/availabilitySets', '{{az}}')]"
{% endif %}
    storageProfile:
      imageReference:
{% if image is defined %}
        id: "[resourceId('Microsoft.Compute/images', '{{image}}')]"
{% else %}
        publisher: {{image_publisher}}
        offer: {{image_offer}}
        sku: {{image_sku}}
        version: {{image_version}}
{% endif %}
      osDisk:
        osType: Linux
        createOption: FromImage
        managedDisk:
          storageAccountType: "{{boot_disk_type | default('Premium_LRS')}}"
        diskSizeGB: {{boot_disk_size}}

{% if volumes is defined %}
      dataDisks:
{% for vol in volumes %}
{% if vol.dev.startswith('/dev/') %}
        - diskSizeGB: {{vol.size}}
          lun: {{loop.index0 }}
          createOption: "Empty"
{% endif %}
{% endfor %}
{% endif %}

    networkProfile:
      networkInterfaces:
      - id: "[resourceId('Microsoft.Network/networkInterfaces', '{{inventory_hostname}}-nic')]"
    diagnosticsProfile:
      bootDiagnostics:
        enabled: true
        storageUri: "{{boot_diag_uri}}"
- name: "{{inventory_hostname}}-nic"
  type: Microsoft.Network/networkInterfaces
  apiVersion: '2017-09-01'
  location: "{{region}}"
  dependsOn:
{% if public_ip is defined and public_ip == true %}
  - "['Microsoft.Network/publicIpAddresses/{{inventory_hostname}}-publicip']"
{% endif %}
  properties:
    ipConfigurations:
    - name: ipconfig1
      properties:
        subnet:
          id: "[variables('subnetRef')]"
{% if ansible_host is defined and ansible_host != 'dynamic' %}
        privateIpAddress: "{{ansible_host}}"
        privateIpAllocationMethod: "Static"
{% else %}
        privateIPAllocationMethod: Dynamic
{% endif %}
{% if enable_asg == true %}
        applicationSecurityGroups:
{% for id in security_groups %}
{% if id != '' %}
          - id: "[resourceId('{{resource_group}}','Microsoft.Network/applicationSecurityGroups', '{{id}}')]"
{% endif %}
{% endfor %}
{% endif %}
{% if public_ip is defined and public_ip == true %}
        publicIpAddress:
          id: "[resourceId('{{resource_group}}','Microsoft.Network/publicIpAddresses', '{{inventory_hostname}}-publicip')]"
{% endif %}
{% if public_ip is defined and public_ip == true %}
- name: "{{inventory_hostname}}-publicip"
  type: Microsoft.Network/publicIpAddresses
  apiVersion: '2017-08-01'
  location: "{{region}}"
  properties:
    publicIpAllocationMethod: "Dynamic"
  sku:
    name: "Basic"
{% endif %}


- name: "{{inventory_hostname}}/CustomScript"
  type: Microsoft.Compute/virtualMachines/extensions
  apiVersion: '2015-06-15'
  location: "[resourceGroup().location]"
  dependsOn:
     - "[resourceId('Microsoft.Compute/virtualMachines', '{{inventory_hostname}}')]"
  properties:
    publisher: Microsoft.Azure.Extensions
    type: CustomScript
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings:
      commandToExecute: "[' echo $(whoami) > /tmp/whoami; echo {{userData}} | base64 --decode > /usr/bin/bootstrap.sh; bash /usr/bin/bootstrap.sh']"

- name: "{{inventory_hostname}}/LinuxDiagnostic"
  type: Microsoft.Compute/virtualMachines/extensions
  apiVersion: '2017-03-30'
  location: {{region}}
  scale:
  properties:
    publisher: Microsoft.OSTCExtensions
    type: LinuxDiagnostic
    typeHandlerVersion: 2.3
    autoUpgradeMinorVersion: true
    settings:
      storageAccount: "{{diag_storage}}"
      xmlCfg: {{lookup('template', '{{role_path}}/templates/WADcfg.xml') | b64encode }}
  dependsOn:
  - "[resourceId('Microsoft.Compute/virtualMachines', '{{inventory_hostname}}')]"

{% if backup_vault is defined and backup_vault != '' %}
- name: "[concat(resourceId('{{resource_group}}', 'Microsoft.Backup/BackupVault','{{backup_vault}}{{ inventory_hostname | zone(subnets_count) }}'),'/','{{inventory_hostname}}')]"
  apiVersion: '2015-03-15'
  type: Microsoft.Backup/BackupVault/registeredContainers/protectedItems
  copy:
    name: protectedItemsCopy
    count: 1
  properties:
    policyId: "{{backup_policy_prefix}}{{ inventory_hostname | zone(subnets_count) }}"
  dependsOn:
  - "[resourceId('Microsoft.Compute/virtualMachines', '{{inventory_hostname}}')]"
{% endif %}

