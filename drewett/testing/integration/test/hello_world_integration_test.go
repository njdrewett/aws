package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/require"
	"strings"
	"testing"
	"time"
)

const appDir = "../hello-world-app"
const dbDir = "../mysql"

// Test the hello world application
func TestHelloWorldApp(t *testing.T) {
	t.Parallel()

	// Deploy the MYSql Database
	dbOpts := createDbOptions(t, dbDir)
	defer terraform.Destroy(t, dbOpts)
	terraform.InitAndApply(t, dbOpts)

	// Deploy the hello world application
	helloOptions := createHelloWorldOpts(dbOpts, appDir)
	defer terraform.Destroy(t, helloOptions)
	terraform.InitAndApply(t, helloOptions)

	// Validate the hello-world-app works
	validateHelloApp(t, helloOptions)

}

// Test the Hello World application but using stages
func TestHelloWorldAppInStages(t *testing.T) {
	t.Parallel()

	// Store the function in a variable
	stage := test_structure.RunTestStage

	defer stage(t, "teardown_db", func() { teardownDB(t, dbDir) })
	stage(t, "deploy_db", func() { deployDB(t, dbDir) })

	// Deploy the hello world app
	defer stage(t, "teardown_app", func() { teardownApp(t, appDir) })
	stage(t, "deploy_app", func() { deployApp(t, dbDir, appDir) })

	// validate the hello world application works
	stage(t, "validate_app", func() { validateApp(t, appDir) })
}

func deployDB(t *testing.T, terraformDir string) {
	dbOpts := createDbOptions(t, dbDir)
	// saves the data to disk so the other test stages are executed at a later
	// time can read the data back
	test_structure.SaveTerraformOptions(t, dbDir, dbOpts)
	terraform.InitAndApply(t, dbOpts)
}

func teardownDB(t *testing.T, terraformDir string) {
	// reload in the options that were saved dsuring deploy
	dbOpts := test_structure.LoadTerraformOptions(t, dbDir)
	defer terraform.Destroy(t, dbOpts)
}

func deployApp(t *testing.T, dbDir string, appDir string) {
	dbOpts := test_structure.LoadTerraformOptions(t, dbDir)

	appOpt := createHelloWorldOpts(dbOpts, appDir)
	test_structure.SaveTerraformOptions(t, appDir, appOpt)

	terraform.InitAndApply(t, appOpt)
}

func teardownApp(t *testing.T, appDir string) {

	appOpts := test_structure.LoadTerraformOptions(t, appDir)

	terraform.Destroy(t, appOpts)
}

func validateApp(t *testing.T, appDir string) {
	appOpts := test_structure.LoadTerraformOptions(t, appDir)
	validateHelloApp(t, appOpts)
}

func createDbOptions(t *testing.T, terraformDir string) *terraform.Options {
	uniqueId := random.UniqueId()

	bucketForTesting := "drewett-testing-state"
	bucketRegionForTesting := "eu-west-2"
	dbStateKey := fmt.Sprintf("%s/%s/terraform.tfstate", t.Name(), uniqueId)

	return &terraform.Options{
		TerraformDir: terraformDir,

		Vars: map[string]interface{}{
			"db_name":     fmt.Sprintf("test%s", uniqueId),
			"db_username": "admin",
			"db_password": "admin1234!",
		},

		BackendConfig: map[string]interface{}{
			"bucket":  bucketForTesting,
			"region":  bucketRegionForTesting,
			"key":     dbStateKey,
			"encrypt": true,
		},
	}
}

func createHelloWorldOpts(dbOpts *terraform.Options, terraformDir string) *terraform.Options {
	return &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"db_remote_state_bucket": dbOpts.BackendConfig["bucket"],
			"db_remote_state_key":    dbOpts.BackendConfig["key"],
			"environment":            dbOpts.Vars["db_name"],
		},

		// Retry up to 3 times with 5 seconds inbetween retries
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			"RequestError: send request failed!!": "Throttling issue?",
		},
	}
}

func validateHelloApp(t *testing.T, helloOptions *terraform.Options) {
	albDnsName := terraform.OutputRequired(t, helloOptions, "alb_dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)

	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		url,
		nil,
		maxRetries,
		timeBetweenRetries,
		func(status int, body string) bool {
			return status == 200 && strings.Contains(body, "Hello, World")
		},
	)
}

func TestAlbPlan(t *testing.T) {
	t.Parallel()

	albName := fmt.Sprintf("test-%s", random.UniqueId())

	opts := &terraform.Options{
		// You should update this relative path to poiint to your alb
		TerraformDir: "../../../separation/alb",
		Vars: map[string]interface{}{
			"alb_name": albName,
		},
	}

	planString := terraform.InitAndPlan(t, opts)

	resourceCounts := terraform.GetResourceCount(t, planString)
	require.Equal(t, 5, resourceCounts.Add)
	require.Equal(t, 0, resourceCounts.Change)
	require.Equal(t, 0, resourceCounts.Destroy)

	planStruct := terraform.InitAndPlanAndShowWithStructNoLogTempPlanFile(t, opts)
	alb, exists := planStruct.ResourcePlannedValuesMap["module.alb.aws_lb.linux_lb"]
	require.True(t, exists, "aws-lb resource must exist")

	name, exists := alb.AttributeValues["name"]
	require.True(t, exists, "missing name parameter")
	require.Equal(t, albName, name)
}
