{% set item = vars['play_hosts'][0] %}
{% set host = hostvars[item] %}

AWSTemplateFormatVersion: 2010-09-09
Parameters:
  Zone:
    Type: AWS::EC2::AvailabilityZone::Name
  Subnet:
    Type: AWS::EC2::Subnet::Id
    Description: Select subnet for the Instance
    ConstraintDescription: must be an existing subnet
  InstanceType:
    AllowedValues:
{% for type in allowed_instance_types %}
      - {{type}}
{% endfor %}
    Type: String
  Hostname:
    Type: String


Resources:
  AMI:
      Type: Custom::AMI
      Properties:
        Region: '{{region}}'
        Filters:
          name: '{{host.ami}}'
        ServiceToken: 'arn:aws:lambda:{{region}}:{{account_id}}:function:cfn-ami-provider'
  SecurityGroups:
      Type: Custom::SecurityGroup
      Properties:
        SecurityGroupNames:
{% for id in host['security_groups'] %}
          - {{id}}
{% endfor %}
        ServiceToken: 'arn:aws:lambda:{{region}}:{{account_id}}:function:cfn-securitygroup-provider'
  Instance:
      Type: "AWS::EC2::Instance"
      Properties:
        AvailabilityZone: !Ref Zone
        ImageId: !Ref AMI
        SecurityGroupIds: !GetAtt SecurityGroups.Ids
        InstanceType: !Ref InstanceType
        BlockDeviceMappings:
          - DeviceName: {{boot_disk_name | default ('/dev/sda1') }}
            Ebs:
              VolumeSize: {{boot_disk_size}}
              VolumeType: {{boot_disk_type | default('gp2')}}
          - DeviceName: {{data_disk_name | default ('/dev/sdb') }}
            Ebs:
              VolumeSize: {{data_disk_size}}
              VolumeType: {{data_disk_type | default('gp2')}}
        UserData: |
          {{hostvars[item]['userData'] | default('')}}
{% if 'instance_role' in hostvars[item] %}
        IamInstanceProfile: {{hostvars[item]['instance_role']}}
{% endif %}
{% if ssh_key_name is defined and ssh_key_name != '' %}
        KeyName: {{ssh_key_name}}
{% endif %}
        SubnetId: !Ref Subnet
        Tags:
            - {Key: "Name", Value: !Ref Hostname }
{% for key in (hostvars[item].tags | sort | reject('==', 'Name')) %}
            - {Key: "{{key}}", Value: "{{hostvars[item].tags[key]}}"}
{% endfor %}

{% include '_volumes.tpl' %}