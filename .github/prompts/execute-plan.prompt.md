---
name: execute-plan
description: Execute the plan, implement changes, and run pytest.
model: claude-sonnet-4.6
---

Plan path:
${input:plan:docs/plans/<feature>.plan.md}

Rules:
- Execute in small slices
- After each slice, run: `pytest -q`
- If any library usage is uncertain, consult `docs/_knowledge/**` first
- Summarize: changed files + test results + next steps