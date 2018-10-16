// external allows custom commands to be run to examine manifest and cluster state.
provider "external" {
  version = "~> 1.0"
}

// template manifests before creation within the cluster.
provider "template" {
  version = "~> 1.0"
}

// docker allows looking up digests for images
provider "docker" {
  version = "~> 1.0"
}

locals {
  output_dirs = "${formatlist("%s/%s", var.render_dir, var.components)}"
}

// ConfigMap describing deployment configuration
data "external" "config" {
  count = "${length(var.components)}"

  program = [
    "${path.module}/scripts/configmap.sh",
    "${var.config}",
    "${element(var.components, count.index)}",
    "${var.git_dir}",
  ]
}

data "null_data_source" "component" {
  count = "${length(var.components)}"

  inputs = {
    repo  = "${lookup(merge(data.external.config.*.result[count.index], var.vars), "image_repo", "")}"
    image = "${lookup(merge(data.external.config.*.result[count.index], var.vars), "image_repo", "")}:${lookup(merge(data.external.config.*.result[count.index], var.vars), "image_tag", lookup(data.external.config.*.result[count.index], "git_sha", ""))}"
  }
}

data "docker_registry_image" "digest" {
  count = "${length(var.components)}"

  name = "${lookup(data.null_data_source.component.*.outputs[count.index], "repo")==""? "alpine" : lookup(data.null_data_source.component.*.outputs[count.index], "image")}"
}

// Template files with variables from ConfigMap
resource "template_dir" "kube_manifests" {
  count = "${length(var.components)}"

  source_dir      = "${var.manifest_dir}/${element(var.components, count.index)}"
  destination_dir = "${element(local.output_dirs, count.index)}"

  vars = "${merge(data.external.config.*.result[count.index], map("image_digest", format("%s@%s", lookup(data.null_data_source.component.*.outputs[count.index], "repo"), data.docker_registry_image.digest.*.sha256_digest[count.index])), var.vars)}"
}
