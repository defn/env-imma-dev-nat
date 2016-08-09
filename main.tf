variable "az_count"     { default = 2 }

provider "aws" { }

resource "null_resource" "cidrs" {
  triggers = {
    nat    = "${data.terraform_remote_state.env.vpc_net16}.0.64/28 ${data.terraform_remote_state.env.vpc_net16}.0.80/28"
  }
}

module "nat" {
  source = "../app-nat"

  bucket_remote_state = "${var.bucket_remote_state}"
  context_org = "${var.context_org}"
  context_env = "${var.context_env}"

  cidr_blocks = "${split(" ",null_resource.cidrs.triggers.nat)}"

  az_count = "${var.az_count}"
  nat_count = "${var.az_count}"

  app_name = "nat"
}

output "nat_ids" {
  value = [ "${module.nat.nat_ids}" ]
}

output "nat_eips" {
  value = [ "${module.nat.nat_eips}" ]
}
