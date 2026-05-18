---
on:
  workflow_dispatch:
    inputs:
      run_id:
        description: "The workflow run ID that failed"
        required: true
  skip-if-match: 'is:issue is:open "nix build failure in nightly update" in:title'

engine: gemini
tools:
  github:
    toolsets: [default, actions]
secrets:
  GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

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
---

## Fix Nix Build Failure (Gemini)

Investigate the failed "Nightly Update" workflow run (run ID:
`${{ github.event.inputs.run_id }}`).

1. Read the workflow run logs for run ID `${{ github.event.inputs.run_id }}`
   using the GitHub MCP tools.
2. Identify the build step that failed and extract the relevant error output.
3. If a clear and safe fix is identified (e.g., removing a temporary debugging assertion):
   - Propose a fix by creating a Pull Request with the changes.
   - Title the PR "fix: nix build failure in nightly update (gemini)".
   - Include a description of the fix and the relevant build log snippet.
   - Do NOT auto-merge the PR.
4. If no clear fix is identified, or to report the failure if a PR isn't appropriate:
   - Create a GitHub issue titled "fix: nix build failure in nightly update (gemini)".
   - Include the relevant build log output in a collapsible `<details>` section.
   - A note to investigate and fix the build error.

**CRITICAL**: Minimize redundant tool calls. Provide a single, comprehensive and high-quality response. Do not emit multiple versions of the same safe-output tool call.
