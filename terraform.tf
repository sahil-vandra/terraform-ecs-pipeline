terraform {
  cloud {
    organization = "sahilvandra"

    workspaces {
      name = "sahil-terraform-ecs-pipeline"
    }
  }
}