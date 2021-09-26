"""Defines a rule for  updating WORKSPACE http_* rules."""

def _update_impl(ctx):
    script = ctx.actions.declare_file(ctx.label.name + ".sh")
    yaml = ctx.actions.declare_file(ctx.label.name + ".yaml")
    ctx.actions.run_shell(
        inputs = ctx.files.yaml_files,
        outputs = [yaml],
        progress_message = "Concatenate %s yaml files" % len(ctx.attr.yaml_files),
        command = "cat %s > %s" % (" ".join([f.path for f in ctx.files.yaml_files]), yaml.path),
    )
    ctx.actions.expand_template(
        template = ctx.file._update_tpl,
        output = script,
        substitutions = {
            "{update_binaries}": ctx.executable.update_exec.path,
            "{yaml}": yaml.short_path,
            "{bazel}": ctx.file.bazel_file.short_path,
        },
        is_executable = True,
    )
    return [DefaultInfo(
        executable = script,
        runfiles = ctx.runfiles(files = [yaml, ctx.executable.update_exec, ctx.file.bazel_file]),
    )]

_update = rule(
    implementation = _update_impl,
    executable = True,
    attrs = {
        "yaml_files": attr.label_list(
            allow_files = True,
        ),
        "update_exec": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
        "bazel_file": attr.label(
            default = Label("//:WORKSPACE"),
            allow_single_file = True,
        ),
        "_update_tpl": attr.label(
            default = Label("//:update.tpl"),
            allow_single_file = True,
        ),
    },
)

def update_http(**kwargs):
    update_http_exec = select({
        "@bazel_tools//src/conditions:linux_aarch64": Label("@update_http_linux_arm64//file"),
        "@bazel_tools//src/conditions:linux_x86_64": Label("@update_http_linux_amd64//file"),
        "@bazel_tools//src/conditions:windows": Label("@update_http_windows_amd64//file"),
        "@bazel_tools//src/conditions:darwin_x86_64": Label("@update_http_darwin_amd64//file"),
        "@bazel_tools//src/conditions:darwin_arm64": Label("@update_http_darwin_arm64//file"),
    })
    _update(update_exec = update_http_exec, **kwargs)

def update_version(**kwargs):
    update_version_exec = select({
        "@bazel_tools//src/conditions:linux_aarch64": Label("@update_version_linux_arm64//file"),
        "@bazel_tools//src/conditions:linux_x86_64": Label("@update_version_linux_amd64//file"),
        "@bazel_tools//src/conditions:windows": Label("@update_version_windows_amd64//file"),
        "@bazel_tools//src/conditions:darwin_x86_64": Label("@update_version_darwin_amd64//file"),
        "@bazel_tools//src/conditions:darwin_arm64": Label("@update_version_darwin_arm64//file"),
    })
    _update(update_exec = update_version_exec, **kwargs)