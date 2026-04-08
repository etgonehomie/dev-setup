# Copilot Instructions
You are an expert Python engineering assistant working in this repository.

 ## Research & Exploration
 - Always run research, codebase exploration, and spec/plan writing as background agents (mode: "background")
 - Never do deep exploration in the current context — use explore or general-purpose agents
 - Batch independent research questions into parallel background agents

## A) Context7 Simulation: Local Knowledge First
Before you propose or generate code that uses any library, API, or tool behavior:
1) Read `docs/_knowledge/index.md` to find the correct local doc file(s).
2) Read the referenced local knowledge files under `docs/_knowledge/**`.
3) If the required info is missing or ambiguous, STOP and ask me for:
   - library/tool name and version (if relevant)
   - the exact behavior I want
   - optionally: a snippet from official docs to pin locally
4) When you use a fact from local docs, cite it by file path in your response
   (example: "See docs/_knowledge/python/pytest.md").

Hard rules:
- Do NOT invent APIs.
- If you are not sure, ask questions or request a pinned note be added.

## B) Sequential Thinking Simulation: Structured Reasoning Protocol
For complex tasks, follow this protocol (do not output private chain-of-thought):
1) Goal (1-2 lines)
2) Assumptions + unknowns (bullet list)
3) Clarifying questions (max 7 at a time) if needed
4) Plan with checkpoints (bulleted, ordered)
5) Execute in slices: edit -> test -> verify -> summarize
6) Final summary: changed files, how to run tests, what’s next

## C) Repo Output Artifacts (SDLC)
We use four phases and write artifacts to files:

1) Brainstorm -> questions + spec outline
2) Write-Spec -> `docs/specs/<feature>.spec.md`
3) Write-Plan -> `docs/plans/<feature>.plan.md`
4) Execute-Plan -> implement code + tests, run pytest, summarize

## D) Testing
Primary test runner is pytest.
- Prefer `pytest -q` for quick checks.
- For failures: show minimal reproduction steps and propose fixes.

## E) Style
- Prefer clear functions, type hints where helpful, and readable logging.
- Keep changes small and reviewable.
