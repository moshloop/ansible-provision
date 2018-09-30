{% set _elb = _elbs[0] %}
{% set config = hostvars[groups[elb_group][0]] %}
{% set alias = _elb.alias | default(elb_group) %}
{% set name = ("LB" + env + alias |  cf_name) %}

  {{name}}:
    Type: "AWS::ElasticLoadBalancingV2::LoadBalancer"
    Properties:
      Name: "LB-{{env}}-{{alias}}"
      Scheme:  {{ _elb.scheme | default('internal') }}
      SecurityGroups:
{% if _elb['security_group'] is defined %}
          - {{config['sg_groups'].get(_elb['security_group'] | lower, 'missing: ' + _elb['security_group'])}}
{% else %}
{% for id in config['security_group_ids'] %}
{% if id != '' %}
          - {{id}}
{% endif %}
{% endfor %}
{% endif %}
      Type: {{  (_elb.type | default('http')  == 'tcp') | ternary('network', 'application') }}
{% include '_subnets.tpl' %}
{% for _port in _elbs %}
{% set port = _port.port %}
{% set type = _port.type | default('http') | upper  %}
{% set checkPath = _port.checkPath | default('/') %}
{% set checkPort = _port.checkPort | default(_port.port) %}
{% set checkType = _port.checkType | default(type) %}
{% set stickiness = _port.stickiness | default(false) %}

  {{name}}{{port}}Listener:
    Type: "AWS::ElasticLoadBalancingV2::Listener"
    Properties:
{% if type == 'HTTPS' %}
      Certificates:
        - CertificateArn: "{{_port.sslId | default(default_ssl_arn)}}"
{% endif %}
      DefaultActions:
        - {TargetGroupArn: !Ref "{{name}}{{port}}", Type: "forward"}
      LoadBalancerArn: !Ref "{{name}}"
      Port: {{port}}
      Protocol: "{{type}}"

  {{name}}{{port}}:
    Type: "AWS::ElasticLoadBalancingV2::TargetGroup"
    Properties:
      HealthCheckIntervalSeconds: {{_port.interval | default(30)}}
      HealthCheckPath: {{checkPath}}
      HealthCheckPort: {{checkPort}}
      HealthCheckProtocol: {{checkType}}
      HealthCheckTimeoutSeconds: {{_port.timeout | default(10)}}
      UnhealthyThresholdCount: {{_port.unhealthyCount | default(3) }}
      HealthyThresholdCount: {{_port.healthyCount | default(5) }}
{% if stickiness %}
      TargetGroupAttributes:
        - {Key: stickiness.enabled, Value: true}
        - {Key: stickiness.lb_cookie.duration_seconds, Value: 86400}
        - {Key: stickiness.type, Value:  lb_cookie}
{% endif %}
      Matcher:
        HttpCode: {{_port.code | default('200')}}
      Name: "LB-{{env}}-{{alias}}-{{port}}"
      Port: {{port}}
      Protocol: "{{type}}"
      VpcId: "{{vpc}}"
      Targets:
{% for target in groups[elb_group] %}
        - {Id: !Ref "{{target}}" }
{% endfor %}
{% endfor %}

  DNS{{alias | cf_name }}:
    Type: "AWS::Route53::RecordSet"
    Properties:
      HostedZoneId: "{{domain_id}}"
      Name: "{{alias}}-elb.{{domain}}"
      Type: A
      AliasTarget:
        DNSName: !Join ["", [!GetAtt "{{name}}.DNSName", "."]]
        HostedZoneId: !GetAtt "{{name}}.CanonicalHostedZoneID"
