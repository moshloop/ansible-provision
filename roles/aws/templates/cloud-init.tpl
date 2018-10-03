#cloud-config
preserve_hostname: true
hostname: {{inventory_hostname | lower}}
users:
    - name: {{ssh_key_user}}
      ssh-authorized-keys:
{% if ssh_key_full is defined %}
        - {{ssh_key_full}}
{% endif %}
{% if '~/.ssh/id_rsa.pub' is exists %}
        - {{ lookup('file', '~/.ssh/id_rsa.pub') }}
{% endif %}
package_update: true
write_files:
    - path: /usr/bin/bootstrap.sh
      permissions: '0755'
      content: |
        #!/bin/bash

        echo role={{role | lower}} >> /etc/environment
        echo environment={{envFull | default(env)}} >> /etc/environment
        echo inventory={{inventory_dir | basename}} >> /etc/environment
{% if purposeId is defined or purpose is defined %}
        echo purpose={{purposeId | default(purpose)}} >> /etc/environment
{% endif %}
        echo groups="{{group_names | join(',')}}" >> /etc/environment
        echo domain={{domain}} >> /etc/environment
        echo AWS_REGION={{region}} >> /etc/environment
        /usr/bin/aws_environment_updater
        . /etc/environment
        aws configure set region $AWS_REGION
        echo {{inventory_hostname | lower}}.{{internal_domain}} > /etc/hostname
        hostnamectl set-hostname --static {{inventory_hostname | lower}}.{{internal_domain}}
{% if bootstrap %}
        install_timer aws-env-sync /usr/bin/aws_environment_updater "*:0/5"
        AWS_REGION={{region}} install_aws_codecommit {{git_account | default('')}} {{git_role | default('')}}
        # wait for all instances in cluster to be running
        sleep 120
        systemctl start aws-env-sync
        install_git_sync {{git_repo}} {{git_path}}
{% endif %}
{% if phone_home is defined %}
{% for cmd in phone_home %}
        {{cmd}}
{% endfor %}
{% endif %}

runcmd:
{% for pkg in packages %}
    - [ cloud-init-per, instance, install-{{pkg | basename | splitext | first}}, sh, "-c", "/usr/bin/rpm -U {{pkg}}"]
{% endfor %}
{% if volumes is defined %}
{% for vol in volumes %}
{% if vol.format is defined %}
    - [ cloud-init-per, always, bootstrap-volume-{{vol.id}}, /usr/bin/bootstrap_volume, "{{vol.dev}}","{{vol.mount}}","{{vol.format}}","{{vol.owner | default('')}}","{{vol.size | default('')}}"]
{% endif %}
{% endfor %}
{% endif %}
{% if instance_volumes is defined %}
{% for vol in instance_volumes %}
{% if vol.format is defined %}
    - [ cloud-init-per, always, bootstrap-volume-{{vol.mount | regex_replace("/", "_")}}, /usr/bin/bootstrap_volume,  "{{vol.dev}}","{{vol.mount}}","{{vol.format}}","{{vol.owner | default('')}}","{{vol.size | default('')}}"]
{% endif %}
{% endfor %}
{% endif %}
    - [ cloud-init-per, instance, bootstrap, "/usr/bin/bootstrap.sh" ]
