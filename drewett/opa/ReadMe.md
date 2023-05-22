# Using Open Policy Agent

This is an example of tusing the Open Plan Policy agent. for enforcing policy restrictions
OPS can be downloaded here https://www.openpolicyagent.org/docs/latest/#running-opa

set path=%path%;C:\programming\opa
or 
$env:Path += ';C:\programming\opa'

for example required tags: run:  terraform plan -out tfplan.binary

convert to json

terraform show -json tfplan.binary > tfplan.json

enforce the policy
opa eval --data enforce_tagging.rego --input tfplan.json --format pretty data.terraform.allow

If there is no ManagedBy tag then undefined is displayed...
if there is then true is displayed


