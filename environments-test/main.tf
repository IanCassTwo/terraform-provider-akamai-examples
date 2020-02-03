module "production" {
	source = "./environments/production"
	env = var.env
}

module "staging" {
	source = "./environments/staging"
	env = var.env
}
