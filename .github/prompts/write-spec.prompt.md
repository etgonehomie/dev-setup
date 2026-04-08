---
name: write-spec
description: Write a detailed spec doc to docs/specs/<feature>.spec.md.
model: claude-opus-4.6
---

Read:
- `docs/_knowledge/index.md`
- any relevant knowledge files under `docs/_knowledge/**`

Spec file path:
${input:path:docs/specs/<feature>.spec.md}

Write the spec with sections:
- Summary
- Goals / Non-goals
- Requirements
- Acceptance Criteria
- Design (high-level)
- Edge cases
- Test Plan (pytest)
- Rollout / Backout (if relevant)
- Open questions (resolved)

There should be no open questions or ambiguities left at the end of this process. If there are, then continue asking questions until they are resolved, providing your recommendations.

At the end, tell me to run `/write-plan`.