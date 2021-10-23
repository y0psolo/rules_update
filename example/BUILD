load("@rules-update//:update.bzl", "update_http", "update_version")

update_http(
    name = "update_workspace",
    yaml_files = ["http/nodejs.yaml", "http/tini.yaml"],
    bazel_file = "//:WORKSPACE",
)

update_version(
    name = "update_versions",
    yaml_files = ["version/deno.yaml", "version/azul.yaml", "version/adoptium.yaml"],
    bazel_file = "//:versions.bzl",
)
