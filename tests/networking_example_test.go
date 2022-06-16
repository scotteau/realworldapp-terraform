package test

import (
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"testing"
)

func TestNetworkingExample(t *testing.T) {
	t.Parallel()

	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	vpcCidr := "10.0.0.0/16"
	publicSubnetsCidr := []string{"10.0.101.0/24", "10.0.102.0/24"}
	privateSubnetsCidr := []string{"10.0.11.0/24", "10.0.12.0/24"}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/networking-example",
		Vars: map[string]interface{}{
			"main_vpc_cidr":       vpcCidr,
			"project_name":        "terraform-module-test",
			"environment":         "test",
			"public_cidr_blocks":  publicSubnetsCidr,
			"private_cidr_blocks": privateSubnetsCidr,
			"region":              awsRegion,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	publicSubnets := terraform.OutputList(t, terraformOptions, "public_subnets_ids")
	privateSubnets := terraform.OutputList(t, terraformOptions, "private_subnets_ids")

	expectedPublicSubnets := 2
	expectedPrivateSubnets := 2
	require.Equal(t, expectedPublicSubnets, len(publicSubnets))
	require.Equal(t, expectedPrivateSubnets, len(privateSubnets))

	for _, subnet := range publicSubnets {
		assert.True(t, aws.IsPublicSubnet(t, subnet, awsRegion))
	}

	for _, subnet := range privateSubnets {
		assert.False(t, aws.IsPublicSubnet(t, subnet, awsRegion))
	}
}
