# Remote 
 Example terraform to reference username and password db credentials that have be manually created in the
 AWS Secrets Manager

 The secrets are created as a JSON file, manually via the AWS Console.

 The terrafrom references this secret in order to retrieve the Secrets and user them in creation of a 
 Database username and password. 
 JSON value can be retreive out of the JSON file with the Terraform function jsondecode()

 




