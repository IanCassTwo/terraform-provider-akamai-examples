variable "contractid" {
  default = ""
}
variable "groupid" {
  default = ""
}

variable "microservice" {
}

variable "environment" {
}

variable "deployments" {
	type = list(string)
	default = ["green", "blue"]
}
