module "property" {
	source = "../../modules/property"
	username = "test"
	password = "test"
	hostname = basename(path.module)
	env = var.env
}
