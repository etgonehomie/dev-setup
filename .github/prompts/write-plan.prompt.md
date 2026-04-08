---
name: write-plan
description: Convert spec to an actionable implementation plan in docs/plans/<feature>.plan.md.
model: claude-opus-4.6
---

Spec path:
${input:spec:docs/specs/<feature>.spec.md}

Plan path:
${input:plan:docs/plans/<feature>.plan.md}

Create an implementation plan with:
- Steps (ordered)
- Files to change (anticipated)
- Checkpoints (where to run pytest)
- Risks + mitigations
- Acceptance Criteria -> Verification mapping