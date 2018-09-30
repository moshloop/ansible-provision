{{extra_inventory_md | default('')}}
{% if 'virtual' in groups %}
{% for dns in groups['virtual'] %}
- [{{dns}}.{{domain}}](http://{{dns}}.{{domain}})
{% endfor %}
{% endif %}
{% if 'elbs' in  hostvars[groups['all'][0]] %}
{% for _elb in hostvars[groups['all'][0]].elbs %}
{% if _elb in groups and groups[_elb] | length > 0 and hostvars[groups[_elb][0]].elb is defined  %}
{% set elbs = hostvars[groups[_elb][0]].elb %}
{% for elb in elbs %}
{% set url = (elb.type | default('http')) + '://' + _elb + "-elb." + domain + ':' + (elb.port | default('80') ) %}
- [{{url}}]({{url}})
{% endfor %}
{% endif %}
{% endfor %}
{% endif %}

{{extra_inventory_md | default('')}}



Name              | Role             |  Private IP      |  Zone        |  Type
------------------|------------------|------------------|--------------|--------------
{% for host in groups['all'] %}
{% set h = hostvars[host] %}
{% if 'ec2_instance' in h %}
{{h['inventory_hostname']}} | {{h['purpose'] | default(h['purposeId']) | default('')}}  |  {{h['ec2_instance']['private_ip_address'] | default('')}}   |  {{h['az']}}  |  {{h['instance_type']}}
{% endif %}
{% endfor %}



### Firewall Ports

Host              | Port             |  Type            |  Description
------------------|------------------|------------------|--------------

{% if 'elbs' in  hostvars[groups['all'][0]] %}
{% for _elb in hostvars[groups['all'][0]].elbs %}
{% if _elb in groups and groups[_elb] | length > 0 and hostvars[groups[_elb][0]].elb is defined  %}
{% set elbs = hostvars[groups[_elb][0]].elb %}
{% for elb in elbs %}
{% if elb.alias is defined %}
{% set alias = elb.alias + "." %}
{% else %}
{% set alias = _elb + "-elb." %}
{% endif %}
{% set records = lookup('dig', alias + domain).split("\n")  %}
{% for record in records %}
{{ record }} | {{ elb.publishPort | default(elb.port) | default('80') }} | {{ elb.type | default('http') }} | {{alias + domain}}
{% endfor %}
{% endfor %}
{% endif %}
{% endfor %}
{% endif %}
{% for host in groups['all'] %}
{% if hostvars[host].public_ports is defined %}
{% for port in hostvars[host].public_ports  %}
{{hostvars[host]['ip'] | default('')}} | {{port }} | HTTPS | {{host}}
{% endfor %}
{% endif %}
{% endfor %}
