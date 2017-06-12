function(values)

  local core = import "kube/core.libsonnet";
  local kubeUtil = import "kube/util.libsonnet";

  local container = core.v1.container;
  local deployment = kubeUtil.app.v1beta1.deployment;

 {
    local nginxContainer =
      container.Default("nginx", values.image) +
      container.NamedPort("http", 80),

    "deployment.yaml": deployment.FromContainer("nginx-deployment", 2, nginxContainer),
  }