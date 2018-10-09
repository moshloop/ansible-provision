
### Loadbalancers

!!! example ""
    **Application Load Balancer**
    ```yaml
    elb:
        - { port: '8443', type: https, alb: true}
        - { port: '8080', type: http, alb: true}
    ```

!!! example ""
    **Classic Load Balancer**
    ```yaml
    elb:
        - { port: '8443', type: https}
        - { port: '8080', type: http}
    ```

!!! example ""
    **Public load balancers**
    ```yaml
    elb:
        - { port: '8443', type: https, scheme: 'internet-facing'}
        - { port: '8080', type: http, scheme: 'internet-facing'}
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
| unhealthyCount | 3                 |                                                       |
| healthyCount   | 5                 |                                                       |
| timeout        | 10                | Timeout in seconds                                    |
| internal       | 30                | Check interval in seconds                             |
| code           | 200               | ALB only                                              |
| sslId          | {default_ssl_arn} | ACM or IAM SSL certificate arn                        |
| alias          | {group_name}      |                                                       |
| security_group |                   |                                                       |
| subnet_name    |                   |                                                       |
| stickiness     | false             |                                                       |
| scheme         | internal          | `internal` or `internet-facing`                       |