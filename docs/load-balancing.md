
### Loadbalancers

```yaml
elb:
    - {}
```
| Name           | Default           | Description                                           |
| -------------- | ----------------- | ----------------------------------------------------- |
| port           |                   |                                                       |
| type           | http              | http,https,tcp                                        |
| check          | {port}/           |                                                       |
| alb            | false             | Create a Application Load Balancer instead of classic |
| checkPath      | /                 | ALB only:                                             |
| checkPort      | {port}            | ALB only:                                             |
| checkType      | {type}            | ALB only:                                             |
| code           | 200               | ALB only                                              |
| sslId          | {default_ssl_arn} |                                                       |
| alias          | {group_name}      |                                                       |
| security_group |                   |                                                       |
| scheme         | internal          |                                                       |