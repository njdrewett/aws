package test

// Run with go test -v -timeout 30m

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"testing"
)

func TestAlb(t *testing.T) {
	opts := &terraform.Options{
		// This should point to the relative path of the alb
		TerraformDir: "../../../separation/alb"
	}

	defer terraform.Destroy(t , opts)

	terraform.InitAndApply(t, opts)

	albDnsName := terraform.OutputRequired(t, opts, "alb_dns_name")
	utl := fmt.Sprintf("http://%s", albDnsName)

	// Test the ALBs default action is working and returns error 404
	expectedStatus := 404
	expectedBody := "404: page not found"
	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetry( 
		t,
		url,
		nil,
		expectedStatus,
		expectedBody,
		maxRetries, 
		timeBetweenRetries,
	)
}
