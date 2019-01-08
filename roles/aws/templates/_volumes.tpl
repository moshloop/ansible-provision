{% if hostvars[item].volumes is defined %}
        Volumes:
{% for vol in hostvars[item].volumes %}
{% if vol.dev.startswith('/dev/') %}
            - VolumeId: !Ref "{{ hostvars[item].inventory_hostname }}{{vol.id}}"
              Device: "{{vol.dev}}"
{% endif %}
{% endfor %}
{% endif %}


{% if hostvars[item].volumes is defined %}
{% for vol in hostvars[item].volumes %}
{% if vol.dev.startswith('/dev/') %}
  {{ hostvars[item].inventory_hostname }}{{vol.id}}:
      Type: "AWS::EC2::Volume"
      Properties:
        Size: {{vol.size}}
{% if vol.encrypted | default( hostvars[item].disk_encryption_default) | default('true') %}
        Encrypted: True
{% endif %}
        VolumeType: {{vol.type | default('gp2')}}
{% if target == 'aws' %}
        AvailabilityZone: {{hostvars[item].az}}
        Tags:
          - Key: Name
            Value: "{{ hostvars[item].inventory_hostname }}-{{vol.id}}"
{% else %}
        AvailabilityZone: !Ref Zone
        Tags:
          - Key: Name
            Value: !Sub "${Hostname}-{{vol.id}}"
{% endif %}

{% endif %}
{% endfor -%}
{% endif -%}