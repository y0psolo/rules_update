"""Defines a rule for  updating WORKSPACE http_* rules."""

update_version = rule(
    implementation = _update_version_impl,
    attrs = {
        "yaml_files": attr.label_list(),
        "bazel": attr.label(
            allow_single_file = True,
        ),
        "_update_tpl": attr.label(
            default = Label(":update.tpl"),
            allow_single_file = True,
        ),
        "_update_version_exec": attr.label(
            default = select({
                "@bazel_tools//src/conditions:linux_aarch64": Label("@update_version_linux_arm64//file"),
                "@bazel_tools//src/conditions:linux_x86_64": Label("@update_version_linux_amd64//file"),
                "@bazel_tools//src/conditions:windows": Label("@update_version_windows_amd64//file"),
                "@bazel_tools//src/conditions:darwin_x86_64": Label("@update_version_darwin_amd64//file"),
                "@bazel_tools//src/conditions:darwin_aarch64": Label("@update_version_darwin_arm64//file"),
            }),
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
    },
)

def _update_http_impl(ctx):
    script = ctx.actions.declare_file(ctx.label.name + ".sh")
    yaml = ctx.actions.declare_file(ctx.label.name + ".yaml")
    ctx.actions.expand_template(
        template = ctx.file._update_tpl,
        output = script,
        substitutions = {
            "{update_binaries}": ctx.executable._update_version_exec.path,
            "{yaml}": yaml.path,
            "{bazel}": bazel.path,
        },
        is_executable = True,
    )
    ctx.actions.run_shell(
        inputs = yaml_files,
        outputs = [yaml],
        progress_message = "Concatenate %s yaml files" % len(yaml_files),
        command = "cat %s > %s" % (" ".join(yaml_files), yaml.path),
    )
    sh_binaries(
        name = ctx.label.name + "_sh_binaries",
        srcs = [script],
        data = [bazel, yaml],
    )
