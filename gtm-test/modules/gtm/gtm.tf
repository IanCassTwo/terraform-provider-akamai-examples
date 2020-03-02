provider "akamai" {
  gtm_section = "papi"
}

resource "akamai_gtm_domain" "iancass_co_uk_akadns_net" {
    contract = var.contractid
    group = var.groupid
    comment =  "Domain import"
    name = "iancass.co.uk.akadns.net"
    type = "weighted"
    email_notification_list = ["icass@akamai.com"]
    default_timeout_penalty = 25
    load_imbalance_percentage = 10
    default_error_penalty = 75
    cname_coalescing_enabled = false
    load_feedback = false
    end_user_mapping_enabled = false
}


resource "akamai_gtm_datacenter" "Frankfurt" {
    domain = akamai_gtm_domain.iancass_co_uk_akadns_net.name
    city = "Frankfurt am Main"
    cloud_server_host_header_override = false
    cloud_server_targeting = false
    country = "DE"
    latitude = 50.11088
    longitude = 8.67949
    nickname = "Frankfurt"
    state_or_province = "Hessen"
    depends_on = [
        akamai_gtm_domain.iancass_co_uk_akadns_net
    ]
}

resource "akamai_gtm_datacenter" "Dublin" {
    domain = akamai_gtm_domain.iancass_co_uk_akadns_net.name
    city = "Dublin"
    cloud_server_host_header_override = false
    cloud_server_targeting = false
    country = "IE"
    latitude = 53.3441
    longitude = -6.26749
    nickname = "Dublin"
    state_or_province = "County Dublin"
    depends_on = [
        akamai_gtm_domain.iancass_co_uk_akadns_net,
        akamai_gtm_datacenter.Frankfurt
    ]
}

resource "akamai_gtm_property" "fra-microapp" {

    for_each = toset(var.deployments)

    domain = akamai_gtm_domain.iancass_co_uk_akadns_net.name
    name = "${var.environment}fra-${var.microservice}-${each.key}"
    type = "failover"
    ipv6 = false
    score_aggregation_type = "worst"
    stickiness_bonus_percentage = 0
    stickiness_bonus_constant = 0
    use_computed_targets = false
    balance_by_download_score = false
    dynamic_ttl = 30
    handout_limit = 8
    handout_mode = "normal"
    failover_delay = 0
    failback_delay = 0
    ghost_demand_reporting = false
    comments = ""
    traffic_target {
        datacenter_id = akamai_gtm_datacenter.Frankfurt.datacenter_id
        enabled = true
        weight = 1
        servers = ["${cloudflare_record.fra[each.key].hostname}"]
    }
    traffic_target {
        datacenter_id = akamai_gtm_datacenter.Dublin.datacenter_id
        enabled = true
        weight = 0
        servers = ["${cloudflare_record.dub[each.key].hostname}"]
    }
    liveness_test {
        name  = "Liveness test - /en/health/health-do-not-touch"
        peer_certificate_verification = true
        test_interval = 60
        test_object  = "/en/health/health-do-not-touch"
	http_header {
		name = "Host"
		value = "www.wheep.co.uk"
	}
        http_error3xx = true
        http_error4xx = true
        http_error5xx = true
        disabled = false
        test_object_protocol  = "HTTPS"
        test_object_port = 443
        disable_nonstandard_port_warning = false
        test_timeout = 25
        answers_required = false
        recursion_requested = false
    }
    depends_on = [
        akamai_gtm_domain.iancass_co_uk_akadns_net,
        akamai_gtm_datacenter.Dublin
    ]
}

resource "akamai_gtm_property" "dub-microapp" {

    for_each = toset(var.deployments)

    domain = akamai_gtm_domain.iancass_co_uk_akadns_net.name
    name = "${var.environment}dub-${var.microservice}-${each.key}"
    type = "failover"
    ipv6 = false
    score_aggregation_type = "worst"
    stickiness_bonus_percentage = 0
    stickiness_bonus_constant = 0
    use_computed_targets = false
    balance_by_download_score = false
    dynamic_ttl = 30
    handout_limit = 8
    handout_mode = "normal"
    failover_delay = 0
    failback_delay = 0
    ghost_demand_reporting = false
    traffic_target {
        datacenter_id = akamai_gtm_datacenter.Dublin.datacenter_id
        enabled = true
        weight = 1
        servers = ["${cloudflare_record.dub[each.key].hostname}"]
    }
    traffic_target {
        datacenter_id = akamai_gtm_datacenter.Frankfurt.datacenter_id
        enabled = true
        weight = 0
        servers = ["${cloudflare_record.fra[each.key].hostname}"]
    }
    liveness_test {
        name  = "Liveness test - /en/health/health-do-not-touch"
        peer_certificate_verification = true
        test_interval = 60
        test_object  = "/en/health/health-do-not-touch"
        http_header {
                name = "Host"
                value = "www.wheep.co.uk"
        }
        http_error3xx = true
        http_error4xx = true
        http_error5xx = true
        disabled = false
        test_object_protocol  = "HTTPS"
        test_object_port = 443
        disable_nonstandard_port_warning = false
        test_timeout = 25
        answers_required = false
        recursion_requested = false
    }
    depends_on = [
        akamai_gtm_domain.iancass_co_uk_akadns_net,
        akamai_gtm_datacenter.Dublin
    ]
}

resource "akamai_gtm_property" "weighted-microapp" {

    for_each = toset(var.deployments)

    domain = akamai_gtm_domain.iancass_co_uk_akadns_net.name
    name = "${var.environment}weighted-${var.microservice}-${each.key}"
    type = "weighted-round-robin"
    ipv6 = false
    score_aggregation_type = "worst"
    stickiness_bonus_percentage = 0
    stickiness_bonus_constant = 0
    use_computed_targets = false
    balance_by_download_score = false
    dynamic_ttl = 30
    handout_limit = 8
    handout_mode = "normal"
    failover_delay = 0
    failback_delay = 0
    ghost_demand_reporting = false
    traffic_target {
        datacenter_id = akamai_gtm_datacenter.Frankfurt.datacenter_id
        enabled = true
        weight = 50
        servers = []
        handout_cname = "${akamai_gtm_property.fra-microapp[each.key].name}.${akamai_gtm_domain.iancass_co_uk_akadns_net.name}"
    }
    traffic_target {
        datacenter_id = akamai_gtm_datacenter.Dublin.datacenter_id
        enabled = true
        weight = 50
        servers = []
        handout_cname = "${akamai_gtm_property.dub-microapp[each.key].name}.${akamai_gtm_domain.iancass_co_uk_akadns_net.name}"
    }
    depends_on = [
	akamai_gtm_property.fra-microapp,
	akamai_gtm_property.dub-microapp,
        akamai_gtm_domain.iancass_co_uk_akadns_net,
        akamai_gtm_datacenter.Frankfurt,
        akamai_gtm_datacenter.Dublin
    ]
}

