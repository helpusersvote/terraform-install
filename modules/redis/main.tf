// defaults requiring interpolation
locals {
  render_dir    = "${var.render_dir=="" ? local.default_render_dir : var.render_dir}"
  config_path   = "${var.config_path=="" ? local.default_config_path : var.config_path}"
  manifests_dir = "${var.manifests_dir=="" ? local.default_manifests_dir : var.manifests_dir}"

  default_render_dir    = "${path.module}/dist/manifests"
  default_config_path   = "${path.module}/manifests/config.yaml"
  default_manifests_dir = "${path.module}/manifests"
}

module "config" {
  source = "../config"

  components   = ["redis"]
  render_dir   = "${local.render_dir}"
  config       = "${local.config_path}"
  manifest_dir = "${local.manifests_dir}"

  vars = {
    image_repo = "${var.image_repo}"
    image_tag  = "${var.image_tag}"
    size       = "${var.disk_size}"
    disk_label = "${var.disk_label}"
  }
}

module "kubernetes" {
  source = "../kubernetes"

  manifest_dirs = "${module.config.dirs}"
  kubeconfig    = "${var.kubeconfig}"
  do_destroy    = "${var.do_destroy}"
  last_resource = "${join(",", module.config.manifest_state)}"
}
