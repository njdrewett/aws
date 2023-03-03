
echo "running terraform apply"
terraform apply -auto-approve

rem only if single ec2 instance setup
rem echo "Getting public ip.."
rem for /f %%i in ('terraform output public_ip') do set PUBLIC_IP=%%i
rem echo "Public IP: %PUBLIC_IP%"

rem echo "Getting Server Port.."
rem for /f %%i in ('terraform output server_port') do set SERVER_PORT=%%i
rem echo "Server Port: %SERVER_PORT%"

rem echo "calling curl to http://%PUBLIC_IP%:%SERVER_PORT%"
rem curl -o - -I http://%PUBLIC_IP%:%SERVER_PORT%

echo "Getting load balancer DNS.."
for /f %%i in ('terraform output alb_dns_name') do set DNS=%%i
echo "DNS: %DNS%"

echo "calling curl to http://%DNS%"
curl -o - -I http://%DNS%
