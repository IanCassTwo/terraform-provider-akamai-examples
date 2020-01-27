module "test-wheep-co-uk" {
	source = "./environments/test.wheep.co.uk"
	env = var.env
}

module "test2-wheep-co-uk" {
	source = "./environments/test2.wheep.co.uk"
	env = var.env
}
