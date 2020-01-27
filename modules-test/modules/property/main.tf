provider "akamai" {
 edgerc = "~/.edgerc"
 papi_section = "papi"
}

data "akamai_group" "group" {
 name = "Ian Cass"
}

data "akamai_contract" "contract" {
  group = data.akamai_group.group.name
}

data "template_file" "rules" {
 template = file("${path.module}/rules.json")
}

resource "akamai_cp_code" "test-wheep-co-uk" {
 product  = "prd_Download_Delivery"
 contract = data.akamai_contract.contract.id
 group = data.akamai_group.group.id
 name = var.hostname
}

resource "akamai_edge_hostname" "test-wheep-co-uk-edgesuite-net" {
 product  = "prd_Download_Delivery"
 contract = data.akamai_contract.contract.id
 group = data.akamai_group.group.id
 ipv6 = false
 ipv4 = true
 edge_hostname = "test.wheep.co.uk.edgesuite.net"
}


resource "akamai_property_variables" "vars" {
  variables {
     variable {
        name        = "PMUSER_USERNAME"
        value       = var.username
        description = "Username"
        hidden      = true
        sensitive   = true
     }
     variable {
        name        = "PMUSER_PASSWORD"
        value       = var.password
        description = "Password"
        hidden      = true
        sensitive   = true
     }
  }
}

resource "akamai_property" "test-wheep-co-uk" {
 name = var.hostname
 cp_code = akamai_cp_code.test-wheep-co-uk.id
 contact = [""]
 contract = data.akamai_contract.contract.id
 group = data.akamai_group.group.id
 product = "prd_Download_Delivery"
 rule_format = ""
 hostnames = {
  "${var.hostname}" = akamai_edge_hostname.test-wheep-co-uk-edgesuite-net.edge_hostname
 }
 rules = data.template_file.rules.rendered
 variables   = "${akamai_property_variables.vars.json}"
 is_secure = false
}

resource "akamai_property_activation" "test-wheep-co-uk" {
 property = akamai_property.test-wheep-co-uk.id
 contact = ["noreply@wheep.co.uk"]
 network = upper(var.env)
 activate = var.activate
}
