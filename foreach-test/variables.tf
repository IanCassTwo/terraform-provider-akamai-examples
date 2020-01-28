variable "tdenabled" {
	type = string
}

variable "env" {
        default = "staging"
}

variable "username" {
	default = "test"
}

variable "password" {
	default = "test"
}

variable "hostnames" {
	type = map(object({
		username = string
		password = string
	}))
}
