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

  components   = ["argo-tunnel"]
  render_dir   = "${local.render_dir}"
  config       = "${local.config_path}"
  manifest_dir = "${local.manifests_dir}"
}

module "kubernetes" {
  source = "../kubernetes"

  manifest_dirs = "${compact(concat(module.config.dirs, var.certs))}"
  kubeconfig    = "${var.kubeconfig}"
  do_destroy    = "${var.do_destroy}"
  last_resource = "${join(",", module.config.manifest_state)}"
}
