# Helm ksonnet Plugin

This is an _EXPERIMENTAL_ plugin for supporting ksonnet/Jsonnet for Helm charts.

The [ksonnet library](https://github.com/ksonnet/ksonnet-lib) is highly experimental,
therefore this plugin is also experimental. Do not use it for production systems.

## Installation

Prerequisites:

- You must install the `jsonnet` CLI. On macOS, the easiest way is `brew install jsonnet`.
- You must have [Helm](http://helm.sh) >=2.4.1 installed and configured (`brew install helm`)

Install the Helm plugin

```console
$ helm plugin install https://github.com/technosophos/helm-ksonnet.git
```

Or clone this repo (or otherwise get it on your filesystem) and do:

```console
$ cd helm-ksonnet
$ helm plugin install $(pwd)
```

Note that this repository uses a Git submodule to track the upstream `ksonnet-lib`.

## Usage

The `helm ksonnet` plugin provides tools for building a Helm chart from jsonnet templates. It provides access to the `ksonnet` library.

To get started, read the built-in help text:

```
$ helm help ksonnet
```

### Writing ksonnet Charts

Get started by creating a standard chart:

```console
$ helm create mychart
```

Inside of your chart, you will need to creat a `ksonnet/` directory, which will be the home for your jsonnet files.

```console
$ mkdir -p mychart/ksonnet
```

ksonnet files are places into that directory, and the `helm ksonnet` plugin takes care of translating those into the canonical Helm Chart structure.

> Note: the JSonnet source is sent to Tiller for storage purposes, but is not executed by Tiller.

Next, create a `main.jsonnet` file. Helm ksonnet treats `main.jsonnet` as a special top-level file. _Your chart will not work if you do not have one_. And this file must be located inside of the `ksonnet/` subdirectory.

```console
$ touch mychart/ksonnet/main.jsonnet
```

Now edit the `main.jsonnet` file. Here's an example to begin with:

```jsonnet
local core = import "kube/core.libsonnet";
local kubeUtil = import "kube/util.libsonnet";

local container = core.v1.container;
local deployment = kubeUtil.app.v1beta1.deployment;

{
  local nginxContainer =
    container.Default("nginx", "nginx:1.7.9") +
    container.NamedPort("http", 80),

  "deployment.yaml": deployment.FromContainer("nginx-deployment", 2, nginxContainer),
}
```

The above will generate a Kubernetes Deployment running two `nginx` pods.

#### References

- [Jsonnet tutorial](http://jsonnet.org/docs/tutorial.html)
- [Jsonnet Specification](http://jsonnet.org/language/spec.html)
- [ksonnet tutorial](https://github.com/ksonnet/ksonnet-lib/blob/master/docs/TUTORIAL.md)

### Testing Your Chart

To test that your chart is working correctly, use the `helm ksonnet show` command.

```console
$ helm ksonnet show ./mychart/
{
   "deployment.yaml": {
      "apiVersion": "extensions/v1beta1",
      "kind": "Deployment",
      "metadata": {
         "annotations": { },
         "labels": { },
         "name": "nginx-deployment"
      },
      "spec": {
         "replicas": 2,
# ...
```

The `jsonnet` language generates JSON files (which is a subset of YAML).

### Packaging and Installing Your Chart

There are two different ways to can prepare your chart for installation.

The first is to create a chart _package_, and then install it:

```console
$ helm ksonnet package ./mychart
Successfully packaged chart and saved it to: ./mychart-0.1.0.tgz
```

At this point, you can now easily install this package using the regular Helm commands:

```console
$ helm install ./mychart-0.1.0.tgz
```

> TIP: You can also use `helm install --dry-run --debug ./mychart-0.1.0.tgz` to run a test install.

The second way is to build the Kubernetes manifests but not package the chart:

```console
$ helm ksonnet build ./mychart
./mychart/templates/deployment.yaml
```

This tells us that it has built the manifest, but has not packaged it. We can still use Helm to install it, though:

```console
$ helm install ./mychart
```

## Known Limitations

Using `helm install`'s `--set` and `-f` flags will write values into `values.yaml`, but there is no mechanism for reading those values into the jsonnet templates. So they will effectively be ignored.