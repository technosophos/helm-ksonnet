#!/bin/bash

set -eu

usage() {
cat << EOF
This plugin provides integration with the ksonnet project.

It provides KSonnet integration with Helm, generating Helm
templates from jsonnet source.

Available Commands:
  show    Show the generated Kubernetes manifests.
  build   Build the JSONNET files into a Kubernetes manifests, but don't package it.
  package Generated a packaged Helm chart.

Typical usage:

   $ helm create mychart
   $ mkdir -p mychart/ksonnet
   $ edit mychart/ksonnet/main.jsonnet
   $ helm package mychart
   $ helm install ./mychart-0.1.0.tgz 

EOF
}

show() {
  jsonnet --jpath $HELM_PLUGIN_DIR/ksonnet-lib $1/ksonnet/main.jsonnet
}

build() {
  jsonnet --jpath $HELM_PLUGIN_DIR/ksonnet-lib -m $1/templates $1/ksonnet/main.jsonnet
}

package() {
  build $1
  helm package 
}

if [[ $# < 1 ]]; then
  echo "===> ERROR: Subcommand required."
  usage
  exit 1
elif [[ $# < 2 ]]; then
  echo "===> ERROR: Missing chart path. Use '.' for the present directory."
  usage
  exit 1
fi

case "${1:-"help"}" in
  "push")
    push $2
    ;;
  "show")
    show $2
    ;;
  "build")
    build $2
    ;;
  "help")
    usage
    ;;
  *)
    echo $1
    usage
    exit 1
    ;;
esac
