
#!/usr/bin/python
# Copyright: Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type


ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = '''
'''

EXAMPLES = ''''''

import traceback
import sys

try:
    import boto3
    from botocore.exceptions import ClientError
    HAS_BOTO3 = True
except ImportError:
    HAS_BOTO3 = False

from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.ec2 import (ansible_dict_to_boto3_filter_list,
                                      boto3_conn, boto3_tag_list_to_ansible_dict, camel_dict_to_snake_dict,
                                      ec2_argument_spec, get_aws_connection_info)

def main():

    argument_spec = ec2_argument_spec()
    argument_spec.update(
        dict(
            name=dict(required=True),
            provider_name=dict(required=False),
            principals=dict(type='list',required=True)
        )
    )

    module = AnsibleModule(argument_spec=argument_spec,
                           supports_check_mode=True
                           )

    if not HAS_BOTO3:
        module.fail_json(msg='boto3 required for this module')

    region, ec2_url, aws_connect_params = get_aws_connection_info(module, boto3=True)

    if region:
        catalog = boto3_conn(module, conn_type='client', resource='servicecatalog', region=region, endpoint=ec2_url, **aws_connect_params)
    else:
        module.fail_json(msg="region must be specified")

    name = module.params.get('name')
    provider = module.params.get('provider_name')
    if provider is None:
        provider = name
    principals = module.params.get('principals')
    portfolio = None
    for p in catalog.list_portfolios()['PortfolioDetails']:
        if p['DisplayName'] == name:
            portfolio = p['Id']

    if portfolio is None:
        sys.stderr.write("Creating new portfolio: %s" % name)
        portfolio = catalog.create_portfolio(DisplayName=name,ProviderName=provider)['PortfolioDetail']['Id']

    for principal in catalog.list_principals_for_portfolio(PortfolioId=portfolio)['Principals']:
        if principal['PrincipalARN'] in principals:
            principals.remove(principal['PrincipalARN'])

    for principal in principals:
        sys.stderr.write("Associating %s with portfolio: %s" % (principal, name))
        catalog.associate_principal_with_portfolio(PortfolioId=portfolio,PrincipalARN=principal,PrincipalType="IAM")

    module.exit_json(id=portfolio)


if __name__ == '__main__':
    main()