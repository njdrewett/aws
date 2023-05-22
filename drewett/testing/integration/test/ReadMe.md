Runs go to Test the terraform deployment 

run the validate app using:
go test -v -timeout 30m -run "TestHelloWorldApp"

to run in stages, test for terraform
use SKIP_<stagename> true environemnt variables to skip specific stages e.g.

set SKIP_teardown_db=true
set SKIP_teardown_app=true
go test -v -timeout 30m -run "TestHelloWorldAppInStages"
