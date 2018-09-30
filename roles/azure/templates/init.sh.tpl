#!/usr/bin/bash

echo role={{role | lower}} >> /etc/environment
echo environment={{envFull | default(env)}} >> /etc/environment
echo inventory={{inventory_dir | basename}} >> /etc/environment
{% if purposeId is defined or purpose is defined %}
echo purpose={{purposeId | default(purpose)}} >> /etc/environment
{% endif %}
echo groups="{{group_names | join(' ')}}" >> /etc/environment
{% if domain is defined %}
echo domain={{domain}} >> /etc/environment
{% endif %}

{% if http_proxy is defined %}
echo http_proxy={{http_proxy}}  >> /etc/environment
echo https_proxy={{http_proxy}} >> /etc/environment
export http_proxy={{http_proxy}}
export https_proxy={{http_proxy}}
{% endif %}

echo $(date) setup environment >> /tmp/init.log
rpm -Uv https://github.com/moshloop/systools/releases/download/3.1/systools-3.1-1.x86_64.rpm
echo $(date) installed systools >> /tmp/init.log
{% if volumes is defined %}
{% for vol in volumes %}
{% if vol.format is defined %}
/usr/bin/bootstrap_volume "{{vol.dev}}" "{{vol.mount}}" "{{vol.format}}" "{{vol.owner | default('')}}" "{{vol.size | default('')}}"
{% endif %}
{% endfor %}
{% endif %}
echo $(date) bootstraped volumes >> /tmp/init.log
if ! which growpart; then
    yum install -y cloud-utils-growpart
fi
growpart /dev/sda 2
xfs_growfs /dev/sda2
echo $(date) grew root >> /tmp/init.log
{% for cmd in phone_home %}
{{cmd}}
{% endfor %}
echo $(date) phone home >> /tmp/init.log
echo $(date) done>> /tmp/init.log