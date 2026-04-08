---
name: brainstorm
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me" or "brainstorm".
model: claude-opus-4.6
---
Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.

If a question can be answered by exploring the codebase, explore the codebase instead.

Be sure to continue asking questions until there are no outstanding questions or ambiguities in the spec.

There should be no open questions or ambiguities left at the end of this process.

Follow the "Structured Reasoning Protocol" in `.github/copilot-instructions.md`.

