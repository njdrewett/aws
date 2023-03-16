

cd live\global\s3
terraform init -backend-config=../../../backend.hcl 
cd ../../..

cd live\stage/services/webserver-cluster
terraform init -backend-config=../../../../backend.hcl 
cd ../../../..

cd live\stage/data-stores/mysql
terraform init -backend-config=../../../../backend.hcl 
cd ../../../..

cd live\global\s3
terraform destroy -auto-approve
cd ../../..


cd live\stage/services/webserver-cluster
terraform destroy -auto-approve
cd ../../../..

cd live\stage/data-stores/mysql
terraform destroy -auto-approve
cd ../../../..

