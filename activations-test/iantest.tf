provider "akamai" {
  edgerc = "/home/icass/.edgerc"
  papi_section = "papi"
}

variable "tdenabled" {
	default = true
}

variable "activate" {
  default = true
}

data "akamai_group" "group" {
  name = "Ian Cass"
}

data "akamai_contract" "contract" {
  group = "${data.akamai_group.group.name}"
}

data "template_file" "property_json" {
   template = "${file("${path.module}/rules.json")}"
   vars = {
	tdenabled = "${var.tdenabled}"
   }
}

resource "akamai_cp_code" "test-wheep-co-uk" {
    product  = "prd_Site_Accel"
    contract = "${data.akamai_contract.contract.id}"
    group = "${data.akamai_group.group.id}"
    name	= "test-wheep-co-uk"
}

resource "akamai_edge_hostname" "test-wheep-co-uk" {
    product  = "prd_Site_Accel"
    contract = "${data.akamai_contract.contract.id}"
    group = "${data.akamai_group.group.id}"
    edge_hostname = "tf2.wheep.co.uk.edgesuite.net"
}

resource "akamai_property" "test-wheep-co-uk" {
  name        = "tfact.wheep.co.uk"
  cp_code     = "${akamai_cp_code.test-wheep-co-uk.id}"
  contact     = ["icass@akamai.com"]
  contract = "${data.akamai_contract.contract.id}"
  group = "${data.akamai_group.group.id}"
  product     = "prd_Site_Accel"
  rule_format = "v2018-02-27"

  hostnames    = {
	"tfact.wheep.co.uk" = "${akamai_edge_hostname.test-wheep-co-uk.edge_hostname}",
	"testact.wheep.co.uk" = "${akamai_edge_hostname.test-wheep-co-uk.edge_hostname}"
  }

  rules       = "${data.template_file.property_json.rendered}"
  is_secure = true

}

