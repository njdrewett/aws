FIle-base isolation example


Initialise with terraform init 

in global s3: 
terraform init -backend-config=../../backend.hcl 

in webserver-cluster
terraform init -backend-config=../../../backend.hcl 

in stage/data-stores/mysel
terraform init -backend-config=../../../backend.hcl 



