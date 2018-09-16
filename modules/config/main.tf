// external allows custom commands to be run to examine manifest and cluster state.
provider "external" {
  version = "~> 1.0"
}

// template manifests before creation within the cluster.
provider "template" {
  version = "~> 1.0"
}

// ConfigMap describing deployment configuration
data "external" "config" {
  count = "${length(var.components)}"

  program = [
    "${path.module}/scripts/configmap.sh",
    "${var.config}",
    "${element(var.components, count.index)}",
  ]
}

// Template files with variables from ConfigMap
resource "template_dir" "kube_manifests" {
  count = "${length(var.components)}"

  source_dir      = "${var.manifest_dir}/${element(var.components, count.index)}"
  destination_dir = "${var.render_dir}/${element(var.components, count.index)}"

  vars = "${merge(data.external.config.*.result[count.index], var.vars)}"
}
