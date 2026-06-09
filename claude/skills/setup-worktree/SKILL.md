---
name: setup-worktree
description: Set up a new TutorCruncher2 worktree by symlinking local-only files and folders from the main repo
disable-model-invocation: true
allowed-tools: Bash
---

When a new git worktree is created for TutorCruncher2, certain local-only files and folders
(excluded via `.git/info/exclude`) don't get copied over. This skill symlinks them from the
main repo at `~/repos/TutorCruncher2/`.

For each item below, check if it already exists in the current working directory. If it does, skip it. If not, verify the source exists in the main repo and create a symlink.

Items to symlink:

1. **_localsettings.py**
   - Source: `~/repos/TutorCruncher2/TutorCruncher/settings/_localsettings.py`
   - Target: `<cwd>/TutorCruncher/settings/_localsettings.py`

2. **env2 folder**
   - Source: `~/repos/TutorCruncher2/env2`
   - Target: `<cwd>/env2`

After creating symlinks, confirm what was linked and what was skipped.
