---
on:
  workflow_run:
    workflows: ["Nightly Update"]
    types: [completed]
    branches:
      - main
  skip-if-match: 'is:issue is:open "nix build failure in nightly update" in:title'

permissions:
  contents: read
  actions: read

safe-outputs:
  create-issue:
    assignees: [copilot]
    close-older-issues: true
    github-token: ${{ secrets.COPILOT_ASSIGN_PAT }}
---

## Fix Nix Build Failure

Check the "Nightly Update" workflow run that triggered this workflow.

1. Get the workflow run details and check if it completed with a failure conclusion
2. If the run succeeded, do nothing (no issue needed)
3. If the run failed, download the build step logs
4. Create a GitHub issue titled "fix: nix build failure in nightly update" with:
   - A description stating that the nightly update workflow encountered a build failure
   - The relevant build log output in a collapsible `<details>` section
   - A note to investigate and fix the build error, and not to auto-merge the fix
