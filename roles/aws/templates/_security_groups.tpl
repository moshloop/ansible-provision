{% if 'security_group_ids' in hostvars[item] %}
        SecurityGroupIds:
{% for id in hostvars[item]['security_group_ids'] %}
{% if id != '' %}
          - {{id}}
{% endif %}
{% endfor %}
{% endif %}