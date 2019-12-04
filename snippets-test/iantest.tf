provider "akamai" {
  edgerc = "/home/icass/.edgerc"
  papi_section = "papi"
}

variable "tdenabled" {
	default = false
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

resource "template_dir" "rules" {
	source_dir = "${path.module}/rules"
	destination_dir = "${path.module}/rendered"
	vars = {
		snippets = "${path.module}/rules/snippets"
	}
}

data "local_file" "rules" {
   filename = "${template_dir.rules.destination_dir}/rules.json"
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
  name        = "tfsnippets.wheep.co.uk"
  cp_code     = "${akamai_cp_code.test-wheep-co-uk.id}"
  contact     = ["icass@akamai.com"]
  contract = "${data.akamai_contract.contract.id}"
  group = "${data.akamai_group.group.id}"
  product     = "prd_Site_Accel"
  rule_format = "v2018-02-27"

  hostnames    = {
	"tfsnippets.wheep.co.uk" = "${akamai_edge_hostname.test-wheep-co-uk.edge_hostname}",
	"testsnippets.wheep.co.uk" = "${akamai_edge_hostname.test-wheep-co-uk.edge_hostname}"
  }
  rules = "${data.local_file.rules.content}"
  is_secure = true

}

