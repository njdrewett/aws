package test

// Run with go test -v -timeout 30m

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
	"time"
)

func TestAlb(t *testing.T) {
	// Run in parallel
	t.Parallel()

	opts := &terraform.Options{
		// This should point to the relative path of the alb
		TerraformDir: "../../separation/alb",

		Vars: map[string]interface{}{
			"alb_name": fmt.Sprintf("test-%s", random.UniqueId()),
		},
	}

	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)

	albDnsName := terraform.OutputRequired(t, opts, "alb_dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)

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
