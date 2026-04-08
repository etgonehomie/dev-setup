---
name: debug
description: This finds the ROOT CAUSE of a problem by recursively asking "why" until we reach the underlying issue. Use when user wants to debug an issue, find the root cause, or mentions "debug" or "root cause" or "RCA".
model: claude-opus-4.6
---

# Process 
## 1. Explore the codebase

Use the Agent tool with subagent_type=Explore to navigate the codebase naturally. Do NOT follow rigid heuristics — explore organically and note where you find potential clues:

- Debug this issue by recursively asking "why" until we reach the root cause. 
- For each answer, ask "why" again to dig deeper. 
- Continue this process until we can no longer ask "why" or we reach a fundamental issue that cannot be further explained.
- Do this in the style of a detective investigating a case, following every lead and clue until we uncover the truth.
- Be relentless in asking "why" and don't stop until we have a clear understanding of the root cause of the problem.


The friction you encounter IS the signal.

Be sure to check existing git worktrees to see what rearchitecture is already happening and avoid proposing work that's already in progress.

### 2. Present RCA

Share the final root cause and explanation, show
- **Chain of "why"**: Show the sequence of "why" questions and answers that led to the root cause.
- **Evidence**: For each step in the chain, show the evidence or clues that supported the answer.
- **Root cause**: Clearly state the final root cause that we uncovered through this
- **Next steps**: Propose actionable next steps to address the root cause and prevent similar issues in the future.

