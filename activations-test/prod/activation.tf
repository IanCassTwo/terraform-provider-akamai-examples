provider "akamai" {
  edgerc = "/home/icass/.edgerc"
  papi_section = "papi"
}

resource "akamai_property_activation" "test-wheep-co-uk-prod" {
        property = "prp_572911"
        contact = ["icass@akamai.com"]
        network = "PRODUCTION"
        activate = true
	  lifecycle {
	    create_before_destroy = true
	  }
}

