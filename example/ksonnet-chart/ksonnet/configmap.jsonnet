local v1 = (import "kube/core.libsonnet").v1;

configMapTest1:V
    v1.configMap.Default("namespace1", "configMap1", {datum1: "value1"}),
