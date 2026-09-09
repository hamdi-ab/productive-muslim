---
name: flutter-pr-auto-stamper
description: Auto-approve low-risk PRs for this Flutter app based on deterministic safety checks. Use when a PR is ready for review and you want to reduce human review burden. Checks: no merge conflicts, no requested changes, blast radius deny-list, diff size threshold, and a lightweight LLM gate. Fails closed — never requests changes or merges; only approves or escalates.
aliases: [auto-stamper, pr-approval, auto-approve, stamper]
sources: [chat, code]
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Wed, 09 Sep 2026 14:54:00 GMT
---

# PR Auto-Stamper for Productive Muslim

This skill auto-approves low-risk PRs to reduce review fatigue. It applies deterministic gates first, then a lightweight LLM check. It never merges, never requests changes, and never loosens its own gates.

## Core Rules

1. Fail closed. If any gate cannot be checked or returns uncertain, escalate to human.
2. Never request changes on GitHub. Only approve or escalate with a 1–2 sentence reason.
3. Never auto-merge. Approval is a stamp; merge requires human action.
4. Only run on PRs with the `ready-for-review` label. Skip drafts and WIP.
5. All thresholds are hardcoded. Do not relax them dynamically.

## Preflight

```bash
gh pr view "$PR_REF" --json mergeStateStatus,reviewDecision,headRefName,baseRefName,title,body,files,additions,deletions,changedFiles,isDraft,labels
```

Abort if:
- `isDraft` is true
- `mergeStateStatus` is not `CLEAN` or `BEHIND`
- `reviewDecision` is `CHANGES_REQUESTED`

## Gate 1: Blast Radius Deny-List

Scan PR title, body, and changed file paths for any of these keywords. If found, escalate immediately.

### Deny-List Keywords

| Category | Keywords |
|----------|----------|
| Auth & security | `auth`, `login`, `token`, `secret`, `credential`, `api_key`, `encrypt`, `biometric` |
| Payments & billing | `payment`, `billing`, `subscription`, `purchase`, `iap`, `revenue`, `transaction` |
| Permissions | `permission`, `runtime_permission`, `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `ACCESS_FINE_LOCATION` |
| Adhan & scheduling | `adhan`, `notification`, `alarm`, `schedule`, `boot_completed`, `flutter_local_notifications` |
| Prayer times | `prayer`, `adhan_dart`, `timezone`, `calculation_method`, `coordinates` |
| Database migrations | `migration`, `schemaVersion`, `addColumn`, `createTable` |
| Data deletion | `delete`, `deactivate`, `hard_delete`, `wipe`, `clear_data` |
| External APIs | `http`, `api`, `endpoint`, `firebase`, `supabase`, `backend`, `sync` |

If any deny-list keyword appears in a changed file path or in the PR description, escalate with:
> "PR touches [category] area — requires human review."

## Gate 2: Diff Size

```bash
additions=$(gh pr view "$PR_REF" --json additions --jq '.additions')
deletions=$(gh pr view "$PR_REF" --json deletions --jq '.deletions')
changed_files=$(gh pr view "$PR_REF" --json changedFiles --jq '.changedFiles')
```

Approve only if:
- `additions + deletions <= 300`
- `changed_files <= 15`

Otherwise escalate with:
> "PR exceeds size threshold ([additions] additions, [deletions] deletions, [changed_files] files) — requires human review."

## Gate 3: LLM Safety Check

Run a lightweight prompt against the PR diff to catch obvious regressions.

```bash
diff=$(gh pr diff "$PR_REF")
```

Prompt:
```
You are reviewing a Flutter PR for the Productive Muslim app. 
The diff is below. Answer with exactly one word: SAFE or ESCALATE.

Rules:
- SAFE: UI tweaks, widget refactors, test additions, string changes, ARB updates, comment-only changes
- ESCALATE: any change to Bloc logic, database schema, migration code, notification scheduling, 
  permission handling, auth flow, payment code, or anything that could crash on launch

Diff:
---
$diff
---
```

If the response is `ESCALATE`, escalate with:
> "LLM gate flagged potential risk in the diff — requires human review."

If the response is anything other than `SAFE` or `ESCALATE`, escalate with:
> "LLM gate returned uncertain result — requires human review."

## Approval

If all three gates pass:

```bash
gh pr review "$PR_REF" --approve --body "Auto-approved by stamper. Gates passed: blast radius clear, diff under threshold ([additions]/[deletions] lines, [changed_files] files), LLM safety check SAFE."
```

Post only the approval comment. Do not merge.

## Escalation

If any gate fails, do NOT approve. Do NOT request changes. Post a comment explaining which gate failed and why:

```bash
gh pr comment "$PR_REF" --body "Escalated to human review. Reason: [reason]."
```

## Escalation Reasons (exact strings)

| Gate failed | Reason string |
|-------------|---------------|
| Draft/WIP | "PR is draft or has requested changes." |
| Blast radius | "PR touches [category] area — requires human review." |
| Diff size | "PR exceeds size threshold ([additions] additions, [deletions] deletions, [changed_files] files) — requires human review." |
| LLM gate | "LLM gate flagged potential risk in the diff — requires human review." |
| LLM uncertain | "LLM gate returned uncertain result — requires human review." |
| Network/API error | "Stamper could not verify PR state — requires human review." |

## What This Skill Does Not Cover

- Merging PRs — human only
- Requesting changes on PRs — human only
- Complex semantic review — use `pr-review-swarm` for that
- Flaky test reruns — use `babysit-prs` for that
- PR description or title quality — human discretion
