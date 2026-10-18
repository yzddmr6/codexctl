# Configuration and troubleshooting

## Connection failures

The CLI requires Python 3.9+ and a running Codex app-server daemon. Report connection errors; `codex app-server daemon start` starts the daemon when needed for the requested work. `CODEXCTL_SOCK` overrides the default socket.

## Overrides and permission persistence

Repeated `-c KEY=VALUE` options support dotted keys. Values are parsed as JSON, falling back to strings.

`codexctl` stores overrides, sandbox, approval policy, and reviewer in `~/.local/state/codexctl/threads.json`. It reapplies overrides when reloading idle threads and pins sandbox, approval policy, and reviewer on every turn it starts.

`queue` preserves recorded permissions, including older threads; untracked threads receive the full-access defaults. `queue --sandbox`, `--ask-for-approval`, and `--approvals-reviewer` update the corresponding saved settings. Preserve the user's choices and authorized scope. Use `status` to inspect pinned settings and `lastTurnPermissions`.

Other clients do not reapply this state. Use a Codex profile or `config.toml` for settings that must persist across clients, only when changing those settings is in scope.

## Process cleanup

`stop --kill-processes` archives and unarchives the thread to terminate daemon-managed processes while keeping the thread usable. It does not establish that detached or remote jobs have ended.
