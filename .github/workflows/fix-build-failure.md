---
on:
  workflow_dispatch:
    inputs:
      run_id:
        description: "The workflow run ID that failed"
        required: true
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

Investigate the failed "Nightly Update" workflow run (run ID: `${{ github.event.inputs.run_id }}`).

1. Download the logs for workflow run ID `${{ github.event.inputs.run_id }}`
2. Identify the build step that failed and extract the relevant error output
3. Create a GitHub issue titled "fix: nix build failure in nightly update" with:
   - A description stating that the nightly update workflow encountered a build failure
   - The relevant build log output in a collapsible `<details>` section
   - A note to investigate and fix the build error, and not to auto-merge the fix
