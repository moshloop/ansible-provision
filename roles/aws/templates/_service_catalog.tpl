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