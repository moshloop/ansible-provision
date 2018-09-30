#cloud-config
runcmd:
{% if static_ip is defined %}
  - [cloud-init-per, instance, static ip,sh, "-c", "nmcli con mod ens192 +ipv4.method static +ipv4.addr {{static_ip}}/{{static_network.cidr | ipaddr('prefix')}} +ipv4.gateway {{ static_network.gw }} +ipv4.dns  {{dns_servers | first}}"]
  - [cloud-init-per, always, restart net, sh, "-c","ifdown ens192; ifup ens192"]
{% endif %}
  - [cloud-init-per, always, register, sh, "-c","subscription-manager register --org={{ organisation }} --activationkey={{ act_key }} --force"]
  - [cloud-init-per, always, attach,sh, "-c", "subscription-manager attach"]
  - [cloud-init-per, always, enable, sh, "-c","subscription-manager repos | grep -i ID | awk '{print $3}' | xargs -n 1 subscription-manager repos --enable"]
  - [cloud-init-per, instance, delete cloud-user, sh, "-c","userdel cloud-user"]
  - [cloud-init-per, instance, grow root, sh, "-c", "growpart /dev/sda 2 && pvresize /dev/sda2 && lvextend /dev/rhel/root /dev/sda2 && xfs_growfs /dev/mapper/rhel-root"]
{% if volumes is defined %}
{% for vol in volumes %}
{% if vol.format is defined %}
  - [ cloud-init-per, always, bootstrap-volume-{{vol.id}}, /usr/bin/bootstrap_volume, "{{vol.dev}}","{{vol.mount}}","{{vol.format}}","{{vol.owner | default('')}}","{{vol.size | default('')}}"]
{% endif %}
{% endfor %}
{% endif %}
{% if phone_home is defined %}
{% for cmd in phone_home %}
  - [cloud-init-per, always, phonehome, sh, "-c", "{{cmd}}"]
{% endfor %}
{% endif %}