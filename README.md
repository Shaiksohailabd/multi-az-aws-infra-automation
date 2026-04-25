This repo used to setup multi-AZ AWS infrastructure automation. For that we have using the Terraform which help to setup infrastructure as code. 
By following command we can setup our infra at different environments.

# Dev
cd environments/dev/
terraform init

# Staging
cd environments/qa/
terraform init

# Prod
cd environments/prod/
terraform init