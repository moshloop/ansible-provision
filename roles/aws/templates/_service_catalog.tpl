AWSTemplateFormatVersion: 2010-09-09
Resources:
  Product:
    Type: AWS::ServiceCatalog::CloudFormationProduct
    Properties:
      Owner: {{stack_name}}
      Name: {{stack_name}}
      ProvisioningArtifactParameters:
        - Info:
            LoadTemplateFromURL: {{cloudformation_template_url}}

  Association:
    Type: "AWS::ServiceCatalog::PortfolioProductAssociation"
    Properties:
      PortfolioId: {{service_catalog_portfolio_id}}
      ProductId: !Ref Product


  LaunchRole:
    Type: AWS::ServiceCatalog::LaunchRoleConstraint
    DependsOn: Association
    Properties:
      PortfolioId: {{service_catalog_portfolio_id}}
      ProductId:  !Ref Product
      RoleArn: arn:aws:iam::{{account_id}}:role/{{service_catalog_runas_role}}