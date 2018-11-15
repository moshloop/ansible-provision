AWSTemplateFormatVersion: 2010-09-09
Resources:
{% for item in vars['play_hosts'] %}
{% if 'virtual' not in groups or item not in groups['virtual'] %}
  {{ hostvars[item].inventory_hostname }}:
      Type: "AWS::EC2::Instance"
      Properties:
        AvailabilityZone: {{hostvars[item].az}}
        ImageId: {{hostvars[item].ami}}
        InstanceType: {{hostvars[item].instance_type}}
{% if not boot_disk_size | is_empty %}
        BlockDeviceMappings:
          - DeviceName: {{ boot_disk_name | default ('/dev/sda1') }}
            Ebs:
              VolumeSize: {{boot_disk_size}}
{% if boot_disk_type != 'standard' %}
              VolumeType: {{boot_disk_type}}
{% endif %}
{% endif %}
        UserData: |
          {{hostvars[item]['userData'] | default('')}}
{% if 'instance_role' in hostvars[item] %}
        IamInstanceProfile: {{hostvars[item]['instance_role']}}
{% endif %}
{% if ssh_key_name is defined and ssh_key_name != '' %}
        KeyName: {{ssh_key_name}}
{% endif %}
        SubnetId: {{hostvars[item].subnet}}
        Tags:
{% for key in (hostvars[item].tags | sort) %}
            - {Key: "{{key}}", Value: "{{hostvars[item].tags[key]}}"}
{% endfor %}


{% include '_security_groups.tpl' %}
{% include '_volumes.tpl' %}

{% endif -%}
{% endfor -%}

{% include '_elbs.tpl' %}