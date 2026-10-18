---
name: codexctl
description: Start, inspect, steer, and stop Codex sessions through the local codexctl CLI, or run its built-in code review. Use when the user asks to delegate work to Codex or manage codexctl threads.
---

# codexctl

Operate local Codex app-server sessions with `codexctl`. Commands return one JSON object; failures return `error` and exit 1. Consult subcommand `--help` for options and `codexctl models` for model IDs and supported efforts.

## Prepare and start

- Preserve the user's model, effort, tier, cwd, sandbox, and configuration choices. Omit unspecified flags to use CLI defaults. `start` and `review` default to `danger-full-access` with approvals `never`; never widen an explicitly requested sandbox to work around a failure.
- Set `--cwd` to the intended repository. Put the user's constraints verbatim at the top of the prompt. Delegation grants no additional authorization for edits, commits, pushes, or remote actions.
- Only modify threads the user identified or that you started for this task. Resolve ambiguous targets with `list`.

Use a quoted heredoc for substantial prompts:

```sh
codexctl start - --cwd /path/to/repo --name scoped-fix <<'PROMPT'
Constraints: Only edit the requested files. Do not commit, push, or modify remote state.
Task: Implement the requested fix and run the relevant checks. Report changed files and validation results.
PROMPT
```

Save the returned `threadId`. `start` returns immediately; `--wait SECONDS` waits for a compact result. Use background execution for long waits to keep the supervising conversation responsive.

## Supervise and collect results

| Intent | Command | Behavior |
| --- | --- | --- |
| Locate sessions | `codexctl list --limit 10` | Returns IDs, names, cwd, and status. |
| Read saved progress | `codexctl status THREAD_ID` | May omit in-progress items. |
| Wait for completion | `codexctl wait THREAD_ID --seconds 60` | Returns the last result immediately if idle. |
| See live progress | `codexctl watch THREAD_ID --seconds 30` | Collects events into one response, not a continuous stream. |
| Read latest reply | `codexctl result THREAD_ID` | Does not prove the turn ended. |
| Guide active work | `codexctl steer THREAD_ID "Focus on the failing check"` | Requires an active turn. |
| Start a follow-up | `codexctl queue THREAD_ID "Run the remaining checks" --wait 60` | Waits for the previous turn, then starts the next; does not wait for the new turn to finish. |

Use `wait` for completion; do not poll with `watch`. Reserve `watch` for mid-course attention or requested live progress.

- If `finished` is false, ordinary turns keep running. Wait again on the same thread. Check `turnStatus` and errors before claiming success; finished turns can fail or be interrupted.
- After a queue timeout or ambiguous submission failure, inspect the thread or list sessions before retrying to avoid duplicate work.
- A `serverRequest` means the daemon needs a client response that `codexctl` cannot supply. Report the blockage; waiting will not resolve it.

Report the thread ID, outcome, validation, and remaining work.

## Built-in review

```sh
codexctl review --cwd /path/to/repo --base main --wait 3600
```

The default target is uncommitted changes. Choose at most one of `--base BRANCH`, `--commit SHA`, or `--instructions TEXT`. Review uses tier `default` (standard speed) unless explicitly overridden; `--tier priority` selects Fast mode.

Keep the review client alive using background execution for long reviews. Unlike ordinary turns, reviews are interrupted when the client disconnects, including when `--wait` expires. A timed-out review is not continuing in the background. Completed review text is in `review`.

## Stop sessions

- `stop THREAD_ID` interrupts the turn; its commands may keep running.
- `stop THREAD_ID --kill-processes` ends daemon-managed processes and keeps the thread usable.
- `archive THREAD_ID` archives the thread and ends daemon-managed processes; it is not harmless history cleanup.

Only stop processes within the requested scope. Detached or remote jobs may survive.

For connection failures, custom configuration, or permission persistence across turns and clients, read [configuration and troubleshooting](references/configuration.md).
