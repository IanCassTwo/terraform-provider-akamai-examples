module "property" {
	source = "../../modules/property"
	username = "test2"
	password = "test2"
	hostname = basename(path.module)
	env = var.env
}
