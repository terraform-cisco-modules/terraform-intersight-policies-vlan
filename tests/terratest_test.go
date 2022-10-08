package test

import (
	"fmt"
	"os"
	"testing"

	iassert "github.com/cgascoig/intersight-simple-go/assert"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestFull(t *testing.T) {
	//========================================================================
	// Setup Terraform options
	//========================================================================

	// Generate a unique name for objects created in this test to ensure we don't
	// have collisions with stale objects
	uniqueId := random.UniqueId()
	instanceName := fmt.Sprintf("test-policies-vlan-%s", uniqueId)

	// Input variables for the TF module
	vars := map[string]interface{}{
		"apikey":        os.Getenv("IS_KEYID"),
		"secretkeyfile": os.Getenv("IS_KEYFILE"),
		"name":          instanceName,
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./full",
		Vars:         vars,
	})

	//========================================================================
	// Init and apply terraform module
	//========================================================================
	defer terraform.Destroy(t, terraformOptions) // defer to ensure that TF destroy happens automatically after tests are completed
	terraform.InitAndApply(t, terraformOptions)
	multicast := terraform.Output(t, terraformOptions, "multicast")
	moid := terraform.Output(t, terraformOptions, "moid")
	vlan := terraform.Output(t, terraformOptions, "vlan")
	assert.NotEmpty(t, multicast, "TF module multicast moid output should not be empty")
	assert.NotEmpty(t, moid, "TF module moid output should not be empty")
	assert.NotEmpty(t, vlan, "TF module vlan moid output should not be empty")

	vars2 := map[string]interface{}{
		"multicast":   multicast,
		"name":        instanceName,
		"vlan_policy": moid,
		"vlan":        vlan,
	}
	//========================================================================
	// Make Intersight API call(s) to validate module worked
	//========================================================================

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedJSONTemplate := `
{
	"Name":        "{{ .name }}",
	"Description": "{{ .name }} VLAN Policy."
}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/fabric/EthNetworkPolicies/%s", moid), expectedJSONTemplate, vars2)

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedVLANTemplate := `
{
	"AutoAllowOnUplinks": false,
	"EthNetworkPolicy": {
	  "ClassId": "mo.MoRef",
	  "Moid": "{{ .vlan_policy }}",
	  "ObjectType": "fabric.EthNetworkPolicy",
	  "link": "https://www.intersight.com/api/v1/fabric/EthNetworkPolicies/{{ .vlan_policy }}"
	},
	"IsNative": false,
	"MulticastPolicy": {
	  "ClassId": "mo.MoRef",
	  "Moid": "{{ .multicast_policy }}",
	  "ObjectType": "fabric.MulticastPolicy",
	  "link": "https://www.intersight.com/api/v1/fabric/MulticastPolicies/{{ .multicast_policy }}"
	},
	"Name": "other-vl0002",
	"VlanId": 2
}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/fabric/Vlans/%s", vlan), expectedVLANTemplate, vars2)
}
