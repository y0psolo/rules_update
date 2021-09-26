#!/usr/bin/env bash

set -e
set -u
set -o pipefail

readonly ROOT_DIR="$(cd "$(dirname "${0}")" && pwd)"
readonly ARTIFACTS_DIR="${ROOT_DIR}/dist"
readonly version=${1}

function main() {
  cat << EOF > "${ROOT_DIR}/rules/repositories.bzl"
# WARNING!!!
# DO NOT MODIFY THIS FILE DIRECTLY.
# TO GENERATE THIS RUN: ./release.sh
"""
Provides functions to pull all external package dependencies of this repository.
"""
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
def update_dependencies():
    """Pull in external Go packages needed by Go binaries in this repo. """
    excludes = native.existing_rules().keys()
    if "update_http_darwin_amd64" not in excludes:
        http_file(
            name = "update_http_darwin_amd64",
            executable = True,
            urls = ["https://github.com/y0psolo/rules_update/releases/download/$version/update_http_darwin_amd64"],
            sha256 = "$(sha256sum ${ARTIFACTS_DIR}/update_http_darwin_amd64 | cut -d " " -f 1 )",
        )
    if "update_http_darwin_arm64" not in excludes:
        http_file(
            name = "update_http_darwin_arm64",
            executable = True,
            urls = ["https://github.com/y0psolo/rules_update/releases/download/$version/update_http_darwin_arm64"],
            sha256 = "$(sha256sum ${ARTIFACTS_DIR}/update_http_darwin_arm64 | cut -d " " -f 1 )",
        )
    if "update_http_linux_amd64" not in excludes:
        http_file(
            name = "update_http_linux_amd64",
            executable = True,
            urls = ["https://github.com/y0psolo/rules_update/releases/download/$version/update_http_linux_amd64"],
            sha256 = "$(sha256sum ${ARTIFACTS_DIR}/update_http_linux_amd64 | cut -d " " -f 1 )",
        )
    if "update_http_linux_arm64" not in excludes:
        http_file(
            name = "update_http_linux_arm64",
            executable = True,
            urls = ["https://github.com/y0psolo/rules_update/releases/download/$version/update_http_linux_arm64"],
            sha256 = "$(sha256sum ${ARTIFACTS_DIR}/update_http_linux_arm64 | cut -d " " -f 1 )",
        )
    if "update_http_windows_amd64" not in excludes:
        http_file(
            name = "update_http_windows_amd64",
            executable = True,
            urls = ["https://github.com/y0psolo/rules_update/releases/download/$version/update_http_windows_amd64.exe"],
            sha256 = "$(sha256sum ${ARTIFACTS_DIR}/update_http_windows_amd64.exe | cut -d " " -f 1 )",
        )
    if "update_version_darwin_amd64" not in excludes:
        http_file(
            name = "update_version_darwin_amd64",
            executable = True,
            urls = ["https://github.com/y0psolo/rules_update/releases/download/$version/update_version_darwin_amd64"],
            sha256 = "$(sha256sum ${ARTIFACTS_DIR}/update_version_darwin_amd64 | cut -d " " -f 1 )",
        )
    if "update_version_darwin_arm64" not in excludes:
        http_file(
            name = "update_version_darwin_arm64",
            executable = True,
            urls = ["https://github.com/y0psolo/rules_update/releases/download/$version/update_version_darwin_arm64"],
            sha256 = "$(sha256sum ${ARTIFACTS_DIR}/update_version_darwin_arm64 | cut -d " " -f 1 )",
        )
    if "update_version_linux_amd64" not in excludes:
        http_file(
            name = "update_version_linux_amd64",
            executable = True,
            urls = ["https://github.com/y0psolo/rules_update/releases/download/$version/update_version_linux_amd64"],
            sha256 = "$(sha256sum ${ARTIFACTS_DIR}/update_version_linux_amd64 | cut -d " " -f 1 )",
        )
    if "update_version_linux_arm64" not in excludes:
        http_file(
            name = "update_version_linux_arm64",
            executable = True,
            urls = ["https://github.com/y0psolo/rules_update/releases/download/$version/update_version_linux_arm64"],
            sha256 = "$(sha256sum ${ARTIFACTS_DIR}/update_version_linux_arm64 | cut -d " " -f 1 )",
        )
    if "update_version_windows_amd64" not in excludes:
        http_file(
            name = "update_version_windows_amd64",
            executable = True,
            urls = ["https://github.com/y0psolo/rules_update/releases/download/$version/update_version_windows_amd64.exe"],
            sha256 = "$(sha256sum ${ARTIFACTS_DIR}/update_version_windows_amd64.exe | cut -d " " -f 1 )",
        )
EOF
}

main "${@:-}"