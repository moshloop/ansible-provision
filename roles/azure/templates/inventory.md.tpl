


Name              | Role             |  Private IP      |  Zone        |  Type        | CPUS / RAM   |    Volumes
------------------|------------------|------------------|--------------|--------------|--------------|--------------
{% for host in groups['all'] %}
{% set h = hostvars[host] %}
{{h['inventory_hostname']}} | {{h['purpose'] | default(h['purposeId']) | default('')}}  |  {{h['ip'] | default('')}}   |  {{h['az']}}  |  {{h['instance_type'] | regex_replace('Standard_', '')}} | {{instance_types[h['instance_type']]}} | /: {{h['boot_disk_size']}}GB  {% if h.volumes is defined %}{% for vol in h.volumes %}<br>{{vol.mount | default ('?') }}: {{vol.size | default('?')}}GB{%- endfor %}{% endif %} |
{% endfor %}


### Firewall Rules


Host              | Port             |  Type            |  Description
------------------|------------------|------------------|--------------
{% for host in groups['all'] %}
{% if hostvars[host].public_ports is defined %}
{% for port in hostvars[host].public_ports  %}
{{hostvars[host]['ip'] | default(hostvars[host]['ansible_host'])}} | {{port }} | HTTPS | {{host}}
{% endfor %}
{% endif %}
{% endfor %}