#!/usr/bin/env bash

set -e
set -u
set -o pipefail

readonly ROOT_DIR="$(cd "$(dirname "${0}")" && pwd)"
readonly ARTIFACTS_DIR="${ROOT_DIR}/dist"
readonly version=${1}

function main() {
  cat << EOF > "${ROOT_DIR}/docs/workspace.adoc"
[source, python]
----
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules-update",
    sha256 = "$(sha256sum ${ARTIFACTS_DIR}/rules_update.tar.gz | cut -d " " -f 1 )",
    urls = ["https://github.com/y0psolo/rules_update/releases/download/$version/rules_update.tar.gz"],
)

# Load update tools
load("@rules-update//:repositories.bzl", "update_dependencies")
update_dependencies()
----
EOF
}

main "${@:-}"