

cd global\s3
terraform init -backend-config=../../backend.hcl 
cd ../..

cd stage/services/webserver-cluster
terraform init -backend-config=../../../backend.hcl 
cd ../../../

cd stage/data-stores/mysql
terraform init -backend-config=../../../backend.hcl 
cd ../../..

cd global\s3
terraform destroy -auto-approve
cd ../..


cd stage/services/webserver-cluster
terraform destroy -auto-approve
cd ../../../

cd stage/data-stores/mysql
terraform destroy -auto-approve
cd ../../..

