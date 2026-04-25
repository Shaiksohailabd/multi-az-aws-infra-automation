This repo used to setup multi-AZ AWS infrastrcture automation. For that we have using the Terrafom which help to setup infrstrcture as code. 
By following command we can setup our infra at different environmnets.

# Dev
cd environments/dev/
terraform init

# Staging
cd environments/staging/
terraform init

# Prod
cd environments/prod/
terraform init