---
name: herdr-subagents
description: "Delegate implementation to Herdr-managed Pi workers while the parent plans and reviews. Use for any task requiring writes to code or implementation artifacts—fixes, refactors, tests, configuration, documentation, and revisions—even without a subagent request; also use when asked to delegate, parallelize implementation, or obtain an independent review. Explanation-only or planning-only tasks need no worker; an explicitly assigned implementation worker implements directly."
compatibility: "Requires Pi, a Herdr session (HERDR_ENV=1), Herdr CLI, and access to an authenticated model provider."
---

# Herdr subagents

## Decide roles

The parent keeps its current/default model for investigation, planning, validation, and review. Delegate all implementation writing (including tests, config, implementation documentation, and follow-up fixes) to workers; even a small edit gets one worker. The parent may inspect files and changes and run non-writing validation, but must not implement corrections itself. Explanation-only or planning-only requests do not require a worker. A user may explicitly override this policy for a task. An agent explicitly assigned as an implementation worker implements directly and must not recursively delegate, despite loading this skill.

## Prepare and assign

1. Verify `HERDR_ENV=1`; if absent, stop and ask the user to run inside Herdr or explicitly authorize another approach. Do not inspect or control a focused Herdr session from outside it. Load `herdr --skill` unless already loaded; treat that skill as the source of truth for CLI mechanics and safety. Consult installed help for syntax; never run bare `herdr` for discovery. Address agents by caller context, explicit pane ID, or unique name, never the focused pane.
2. Inspect relevant repository instructions and scope; define acceptance criteria and validation. Workers do not inherit the parent's conversation. Default to Pi with the user's installed skills/extensions/provider configuration and **gpt-6-sol** via the current selector `vercel-ai-gateway/openai/gpt-6-sol`. Check `pi --list-models` before launching; if the provider changes, resolve the exact `gpt-6-sol` entry there. Do not substitute another variant, parent model, or provider on failure. A user-requested model override applies only to its specified scope. Do not force reasoning level unless requested or required. Report actual model/auth errors and ask how to proceed.
3. Start a named Pi worker in a sibling pane in the current tab/working directory, following Herdr geometry guidance and using `--no-focus`. Pass Pi arguments after Herdr's `--`; get new pane IDs from JSON, not guesses. Prefer a fresh worker for unrelated work; reuse a ready worker for revisions to the same assignment. Do not take over user agents or unrelated panes. No new worktree, workspace, tab, or working directory unless requested.
4. Give each worker a bounded assignment: goal, context, acceptance criteria, allowed write paths and exclusions, relevant instructions/skills, validation commands and environment limits, and expected report (changed paths, tests/results, concerns). Include: **"You are the implementation worker. Implement directly; do not spawn subagents. The parent owns planning and review."** Forbid commits, pushes, destructive operations, and out-of-scope edits unless authorized. If a broader scope or design decision is needed, instruct the worker to stop and report.

## Coordinate, verify, revise

- Start with one worker. Parallelize only independent tasks with non-overlapping file ownership. Workers share a checkout: prevent overlapping edits, shared formatters, conflicting version-control actions, mutating validations, and port contention. Follow repository/version-control rules and preserve unrelated work. Do not answer approval dialogs on the user's behalf or steer a busy worker unintentionally.
- Submit with `herdr agent prompt ... --wait` and a bounded timeout. The parent may investigate while a worker runs, then use `herdr agent wait`. On timeout or stalled submission, inspect state/output before retrying; it may already be running.
- Lifecycle status (`idle`/`done`) is not proof of success. Read actual output with `herdr agent read ... --source recent-unwrapped`; inspect errors, blockers, and validation results. Follow Herdr transcript guidance if output is missing: read terminal output first; if the alternate screen prevents recovering the full response, request a temporary Markdown report and read it. Do not require a report file in the initial prompt.
- Inspect actual changes and check scope, acceptance criteria, instructions, and test evidence. Run additional non-writing validation if needed; have the worker run commands that modify implementation files. Delegate corrections to the worker and review again. Report outcomes and limitations accurately. Keep workers available while reviewing and revising. After the final report is captured and accepted and no further revisions are needed, gracefully exit Pi, confirm the agent has exited and the shell is back at its prompt, then close the pane the parent created. Honor an explicit request to keep a worker open. Never close unrelated/user panes or stop the Herdr server.
- If delegation is unavailable, report the blocker and ask before parent implementation. Never silently fall back to parent writing or another worker model.

## Example scenarios (walkthrough checks)

| Request / context | Expected action |
| --- | --- |
| "Fix the failing parser test" (no mention of agents) | Parent investigates; worker edits and tests; parent reviews. |
| "Explain why the parser fails; don't change files" | Parent explains; no implementation worker needed. |
| Worker assigned a parser fix and this skill loads | Worker implements directly; no recursive delegation. |
| "Use model X for this migration" | Assign that model for this migration only; later tasks retain `gpt-6-sol`. |
| `HERDR_ENV` missing or requested model unavailable | Report actual blocker/error and ask; no silent fallback. |
| "Parallelize independent UI and API changes" | Separate workers only if file ownership and validation are non-conflicting. |

## Discovery

Expose this directory in a skill discovery location such as `~/.agents/skills/herdr-subagents/`. Skills load on demand; installation alone does not guarantee activation or enforce delegation. For more reliable activation, recommend a parent-harness global rule to load this skill for implementation, keep the parent on planning/review, default workers to `gpt-6-sol`, and exempt explicitly assigned implementation workers from recursive delegation. Do not assume such a rule exists.

## References

- [Agent Skills specification](https://agentskills.io/specification)
- [Anthropic skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
