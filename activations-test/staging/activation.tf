provider "akamai" {
  edgerc = "/home/icass/.edgerc"
  papi_section = "papi"
}

resource "akamai_property_activation" "test-wheep-co-uk-staging" {
        property = "prp_572911"
        contact = ["icass@akamai.com"]
        network = "STAGING"
        activate = true
	  lifecycle {
	    create_before_destroy = true
	  }
}

