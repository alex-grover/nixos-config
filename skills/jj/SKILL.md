---
name: jj
description: "Use this skill whenever a task involves version control: inspecting changes or history, recording or amending work, switching or rebasing, resolving conflicts, managing branches or bookmarks, cloning, fetching or pulling, pushing, or undoing operations. Trigger even when the user uses Git terminology or the repository is colocated with Git; perform every operation with jj and follow the undescribed-working-copy and squash workflow."
---

# Jujutsu

Use `jj` exclusively for version control. **Never invoke the `git` executable**, even for read-only operations or in a colocated repository. Commands such as `jj git fetch` are Jujutsu commands and are allowed.

## Mental model

- The working copy is a real commit named `@`; its parent is `@-`.
- `jj` snapshots file changes automatically. There is no staging area and normally no `add` step; new non-ignored files are tracked automatically.
- Change IDs remain stable when commits are rewritten.
- Bookmarks are movable names comparable to Git branches, but work does not require one.
- Most mistakes are recoverable from the operation log with `jj undo`.

Always inspect the repository before acting:

```sh
jj status
jj log -r '::@'
jj diff
```

## Required working-copy workflow

Maintain this invariant: edit files only in an undescribed working commit (`@`). Never use `jj edit` or edit files while `@` has a description.

Start a new change from the desired base. Skip this command if `@` is already an empty undescribed commit on that base:

```sh
jj new 'trunk()'
```

Edit and review the undescribed `@`, then finish it:

```sh
jj status
jj diff
# run relevant tests
jj commit -m "concise change description"
```

`jj commit` is allowed: it is effectively `jj describe` followed by `jj new`, so it leaves a fresh empty, undescribed `@` above the completed change.

To update an existing described change without editing it directly, create an undescribed child, make and review the edits, then squash them into the parent:

```sh
jj new <target-change>
# edit, test, and review
jj squash
```

For more work on the current parent, edit the fresh undescribed `@` and squash again. Use `jj squash -i` to move only selected hunks. Change only the parent's description with `jj describe @- -m "new description"`.

Before every squash, verify with `jj status` that `@-` is the intended destination. Never squash blindly.

## Common commands

| Need | Use |
|---|---|
| Status | `jj status` |
| Current diff | `jj diff` |
| Show a change | `jj show <rev>` |
| History | `jj log` or `jj log -r '::@'` |
| Finish the current undescribed change | `jj commit -m "description"` |
| Discard current path changes | `jj restore <paths>` |
| Discard all current changes | `jj restore` |
| Abandon a change | `jj abandon <rev>` |
| Undo/redo the last jj operation | `jj undo` / `jj redo` |
| List operation history | `jj op log` |
| Switch to a base with a fresh undescribed change | `jj new <rev>` |
| Move a stack onto a new base | `jj rebase -b @ -o <base>` |
| List bookmarks | `jj bookmark list` |
| Create or advance a bookmark | `jj bookmark set <name> -r @-` |
| Create a repository | `jj git init --no-colocate [path]` |
| Add jj to an existing Git repository | `jj git init --colocate .` |
| Clone | `jj git clone --no-colocate <url> [path]` |
| Fetch | `jj git fetch` |
| Push one bookmark | `jj git push --bookmark <name>` |

Prefer rebasing onto the target branch over creating merge commits. Create merge commits only when explicitly requested.

There is no pull command. Update work with:

```sh
jj git fetch
jj rebase -b @ -o 'trunk()'
```

Before pushing the completed parent:

```sh
jj bookmark set <name> -r @-
jj git push --bookmark <name>
```

## Conflicts

Rebases complete even when they produce conflicts. Resolve a conflicted described change through an undescribed child, then squash the resolution:

```sh
jj new <conflicted-change>
jj resolve                 # or edit conflict markers
jj diff
jj squash
```

## References

- [Jujutsu overview and tutorial](https://docs.jj-vcs.dev/latest/tutorial/)
- [Git command equivalents](https://docs.jj-vcs.dev/latest/git-command-table/)
- [Working-copy model](https://docs.jj-vcs.dev/latest/working-copy/)
