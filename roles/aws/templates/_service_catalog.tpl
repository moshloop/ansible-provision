AWSTemplateFormatVersion: 2010-09-09
Resources:
  Product:
    Type: AWS::ServiceCatalog::CloudFormationProduct
    Properties:
      Owner: {{stack_name}}
      Name: {{stack_name}}
      ProvisioningArtifactParameters:
        - Info:
            LoadTemplateFromURL: {{url.url}}

  Association:
    Type: "AWS::ServiceCatalog::PortfolioProductAssociation"
    Properties:
      PortfolioId: {{service_catalog_portfolio_id}}
      ProductId: !Ref Product


  LaunchConstraint:
    DependsOn: Association
    Type: AWS::ServiceCatalog::LaunchRoleConstraint
    Properties:
      Description: {{service_catalog_role | basename}}
      PortfolioId: {{service_catalog_portfolio_id}}
      ProductId: !Ref Product
      RoleArn: {{service_catalog_role}}