# Create a simple webapp
provider "kubernetes" {
  config_path = "~/.kube/config"

  config_context = "docker-desktop"
}

module "simple_webapp" {
    source = "./modules/services/k8s-app"

    name = "simple-webapp"
    image = "training/webapp"
    replicas = 2
    container_port = 5000

    ## Provider replaces world in he hello world string
    environment_variables = {
      PROVIDER = "Neil"
    }
}