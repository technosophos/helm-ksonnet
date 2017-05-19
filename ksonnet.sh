#!/bin/bash

set -eu

usage() {
cat << EOF
This plugin provides integration with the ksonnet project.

It provides KSonnet integration with Helm, generating Helm
templates from jsonnet source.

Available Commands:
  show    Show the generated Kubernetes manifests.

EOF
}

push() {
  echo "Packaging $1"
  cp "${1}" "./docs/${1}"
  if [ -e ${1}.prov ]; then
    cp "${1}.prov" "./docs/${1}.prov"
  fi
  helm repo index ./docs
  git add docs/$1 ./docs/index.yaml
  git commit -m "Auto-commit $1"
  git push origin master
  echo "Successfully pushed $1 to GitHub"
}

show() {
  jsonnet --jpath $HELM_PLUGIN_DIR/ksonnet-lib $1
}

if [[ $# < 2 ]]; then
  usage
  exit 1
fi

case "${1:-"help"}" in
  "push")
    push $2
    ;;
  "help")
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac
