

cd global\s3
terraform init -backend-config=../../backend.hcl 
cd ../..

cd stage/services/webserver-cluster
terraform init -backend-config=../../../backend.hcl 
cd ../../../

cd stage/data-stores/mysql
terraform init -backend-config=../../../backend.hcl 
cd ../../..

set TF_VAR_db_username=neil
set TF_VAR_db_password=password123

cd global\s3
terraform apply -auto-approve
cd ../..



cd stage/data-stores/mysql
terraform apply -auto-approve
cd ../../..


cd stage/services/webserver-cluster
terraform apply -auto-approve
cd ../../../