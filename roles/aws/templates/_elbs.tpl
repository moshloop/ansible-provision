{% if elb | bool and 'elbs' in hostvars[groups['all'][0]]  %}
{%    for elb_group in hostvars[groups['all'][0]].elbs  %}
{%      if elb_group in play_groups  %}
{%         set elbs = hostvars[groups[elb_group][0]].elb  %}
{%         if elbs is mapping  %}
{%          for elbName in elbs  %}
{%              set _elbs = elbs[elbName]  %}
{%              if _elbs[0].alb is defined  %}
{%                  include '_elbv2.tpl'  %}
{%              else  %}
{%                  include '_elb.tpl'  %}
{%              endif  %}
{%          endfor  %}
{%         else %}
{%              set _elbs = elbs  %}
{%              if _elbs[0].alb is defined  %}
{%                  include '_elbv2.tpl'  %}
{%              else  %}
{%                  include '_elb.tpl'  %}
{%              endif  %}
{%         endif  %}
{%      endif  %}
{%    endfor %}
{% endif %}