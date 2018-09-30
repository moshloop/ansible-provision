{% if _elbs[0]['subnet_name'] is defined %}
{%  set _name = _elbs[0]["subnet_name"] %}
{% else %}
{%  set _name = config["subnet_name"] %}
{% endif %}
      Subnets:
{% for id in all_subnets | find_subnets(_name,'') | map(attribute='id') %}
        - {{id}}
{% endfor %}