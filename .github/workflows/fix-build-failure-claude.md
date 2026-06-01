---
on:
  bots:
    - "github-actions[bot]"
  workflow_dispatch:
    inputs:
      run_id:
        description: "The workflow run ID that failed"
        required: true
      pr_id:
        description: "the pull request ID, if it exists"
        required: false
        default: none
      pr_branch:
        description: "the pull request branch, if it exists"
        required: false
  skip-if-match: 'is:issue is:open "nix build failure in nightly update" in:title'

engine: claude
tools:
  github:
    toolsets: [default, actions]
secrets:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
checkout:
  ref: ${{ github.event.inputs.pr_branch || github.ref }}

permissions:
  contents: read
  actions: read
  issues: read
  pull-requests: read

safe-outputs:
  create-issue:
    assignees: [jtliang24]
    close-older-issues: true
    github-token: ${{ secrets.COPILOT_ASSIGN_PAT || secrets.GITHUB_TOKEN }}
  create-pull-request:
    github-token: ${{ secrets.COPILOT_ASSIGN_PAT || secrets.GITHUB_TOKEN }}
  update-pull-request:
    target: ${{ github.event.inputs.pr_id }}
    github-token: ${{ secrets.COPILOT_ASSIGN_PAT || secrets.GITHUB_TOKEN }}
  push-to-pull-request-branch:
    target: ${{ github.event.inputs.pr_id }}
    github-token: ${{ secrets.COPILOT_ASSIGN_PAT || secrets.GITHUB_TOKEN }}
  threat-detection: false
---

## Fix Nix Build Failure (Claude)

Investigate the failed "Nightly Update" workflow run (run ID:
`${{ github.event.inputs.run_id }}`).

1. Read the workflow run logs for run ID `${{ github.event.inputs.run_id }}`
2. Identify the build step that failed and extract the relevant error output.
3. Review the code relating to the error.
4. If a clear and safe fix is identified:
   - If a Pull Request (`${{ github.event.inputs.pr_id }}`) is given, update
     that Pull Request by applying the fix. Otherwise, create a new pull request
     titled "fix: nix build failure in nightly update" with the fix.
   - Do NOT create a new Pull Request if there is already a Pull Request given.
   - Include a description of the fix and the relevant build log snippet.
   - Do NOT auto-merge the PR.
5. If no clear fix is identified, or to report the failure if a PR isn't
   appropriate:
   - Create a GitHub issue titled "fix: nix build failure in nightly update
     (Claude)".
   - Include the relevant build log output in a collapsible `<details>` section.
   - A note to investigate and fix the build error.

**CRITICAL**: Minimize redundant tool calls. Provide a single, comprehensive and
high-quality response. Do not emit multiple versions of the same safe-output
tool call.
