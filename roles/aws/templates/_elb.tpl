{% set _elb = _elbs[0] %}
{% set config = hostvars[groups[elb_group][0]] %}
{% set alias = _elb.alias | default(elb_group) %}
{% set name = "LB" + env +  alias | regex_replace("-", "") %}
{% set stickiness = _elb.stickiness | default(false) %}
{{ _elb | debug_obj}}
{{ groups[elb_group][0] | debug_obj}}
{{ config.keys() | debug_obj }}

  {{name}}:
    Type: "AWS::ElasticLoadBalancing::LoadBalancer"
    Properties:
      LoadBalancerName: "LB-{{env}}-{{alias}}"
      Scheme:  {{ _elb.scheme | default('internal') }}
      SecurityGroups:

{% if _elb['security_group'] is defined %}
          - {{sg_groups.get(_elb['security_group'] | lower, 'missing: ' + _elb['security_group'])}}
{% elif config['security_group_ids'] is defined %}
{{ config | debug_obj}}
{% for id in config['security_group_ids'] %}
{% if id != '' %}
          - {{id}}
{% endif %}
{% endfor %}
{% elif config['security_groups'] is defined %}
{% for id in config['security_groups'] %}
{% if id != '' %}
          - {{sg_groups.get(id, 'missing' + id)}}
{% endif %}
{% endfor %}
{% endif %}
      HealthCheck:
        HealthyThreshold: "5"
        Interval: "30"
        Target: "{{ _elb.check | default( _elb.type | default('http') | upper + ':' + _elb.port + '/') }}"
        Timeout: "10"
        UnhealthyThreshold: "2"
      Instances:
{% for target in groups[elb_group] %}
        - !Ref "{{target}}"
{% endfor %}

{% include '_subnets.tpl' %}
{% if stickiness %}
      LBCookieStickinessPolicy:
      - PolicyName: LBCookiePolicy
        CookieExpirationPeriod: '86400'
{% endif %}
      Listeners:
{% for port in _elbs  %}
          - LoadBalancerPort: '{{port.publishPort | default(port.port)}}'
            InstancePort: '{{port.port}}'
            Protocol: "{{port.type | default('HTTP') | upper }}"
            InstanceProtocol: "{{port.type | default('HTTP') | upper }}"
{%  if port.type is defined and port.type == 'https'  %}
            SSLCertificateId: "{{port.sslId | default(default_ssl_arn)}}"
{%  endif %}
{%  if stickiness %}
            PolicyNames: [LBCookiePolicy]
{%  endif %}
{% endfor %}

{% if dns %}
{% for record in _elbs  %}
{%  if loop.index == 1 or record.alias is defined %}
{%    if record.alias is defined %}
{%      set alias = record.alias %}
{%    else %}
{%      set alias = elb_group + "-elb" %}
{%    endif %}
  DNS{{alias |  regex_replace("-", "")}}:
    Type: "AWS::Route53::RecordSet"
    Properties:
      HostedZoneId: "{{domain_id}}"
      Name: "{{alias}}.{{domain}}"
      Type: A
      AliasTarget:
        DNSName: !Join ["", [!GetAtt "{{name}}.DNSName", "."]]
        HostedZoneId: !GetAtt "{{name}}.CanonicalHostedZoneNameID"
{% endif %}
{% endfor %}
{% endif %}
