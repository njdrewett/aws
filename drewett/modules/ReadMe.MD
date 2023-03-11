module example


Initialise with terraform init 

in global s3: 
terraform init -backend-config=../../backend.hcl 

in webserver-cluster
terraform init -backend-config=../../../backend.hcl 

in stage/data-stores/mysel
terraform init -backend-config=../../../backend.hcl 

and terrafomr apply in each

run.bat - initialise and execute. WebServer Hello world + parameters argument forRDS connection is displayed.

destory.bat - destory the environment
