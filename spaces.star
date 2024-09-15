"""

"""

macos_x86_64 = {
    "url": "https://static.rust-lang.org/rustup/dist/x86_64-apple-darwin/rustup-init",
    "sha256": "f547d77c32d50d82b8228899b936bf2b3c72ce0a70fb3b364e7fba8891eba781",
    "add_prefix": "sysroot/bin",
    "link": "Hard",
}

checkout.add_platform_archive(
    rule = {"name": "rustup-init"},
    platforms = {
        "macos_x86_64": macos_x86_64,
        "macos_aarch64": macos_x86_64,
    },
)

# more binaries https://forge.rust-lang.org/infra/other-installation-methods.html

store_path = info.store_path()
cargo_path = "{}/cargo/bin".format(store_path)
rustup_home = "{}/rustup".format(store_path)
cargo_home = "{}/cargo".format(store_path)

checkout.update_env(
    rule = {"name": "rust_env"},
    env = {
        "vars": {"RUSTUP_HOME": rustup_home, "CARGO_HOME": cargo_home},
        "paths": [cargo_path],
    },
)

# only want to run this rule once
run.add_exec(
    rule = {"name": "rustup-init-permissions"},
    exec = {
        "command": "chmod",
        "args": ["755", "sysroot/bin/rustup-init"],
    },
)

run.add_exec(
    rule = {"name": "rustup-init", "deps": ["rustup-init-permissions"]},
    exec = {
        "command": "sysroot/bin/rustup-init",
        "args": ["--profile=default", "--no-modify-path", "-y"],
    },
)

checkout.update_asset(
    rule = {"name": "vscode_settings"},
    asset = {
        "destination": ".vscode/settings.json",
        "format": "json",
        "value": {
            "rust-analyzer.cargo.buildScripts.invocationStrategy": "once",
            "rust-analyzer.cargo.buildScripts.invocationLocation": "root",
            "rust-analyzer.cargo.buildScripts.overrideCommand": [
                "cargo",
                "check",
                "--quiet",
                "--message-format=json",
                "--all-targets",
                "--keep-going",
            ],
            "rust-analyzer.cargo.targetDir": "target-rust-analyzer",
            "rust-analyzer.check.noDefaultFeatures": True,
            "rust-analyzer.cargo.noDefaultFeatures": True,
            "rust-analyzer.showUnlinkedFileNotification": False,
            "rust-analyzer.imports.granularity.enforce": True,
            "rust-analyzer.imports.granularity.group": "module",
            "rust-analyzer.cargo.buildScripts.enable": True,
            "rust-analyzer.procMacro.attributes.enable": False,
            "rust-analyzer.cargo.extraEnv": {"CARGO_HOME": cargo_home, "RUSTUP_HOME": rustup_home},
        },
    },
)
