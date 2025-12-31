# AI Development Workflow

> **Goal:** Efficiently build the HomeInventory app by leveraging the strengths of different AI tools without losing context.

---

## 1. The "Triad" Roles

We use three distinct systems to build this software. Respecting these roles prevents confusion and "spaghetti code."

| System | Role | Primary Responsibility | When to use? |
| :--- | :--- | :--- | :--- |
| **Gemini / ChatGPT** | **The Architect** | Data Modeling, Complex Logic, Math, Code Review, Debugging Hard Crashes. | "How do I structure this?"<br>"Why is this crashing?"<br>"Review my architecture." |
| **Cursor AI** | **The Builder** | Writing SwiftUI Views, Boilerplate, Refactoring, Syntax fixing. | "Create a view that looks like X."<br>"Add a tap gesture here."<br>"Fix this typo." |
| **GitHub** | **The Truth** | The single source of truth for the codebase. | **Always.** Never debug with the Architect until you have pushed your latest Builder code. |

---

## 2. The Development Loop

### Step 1: Design (The Architect)
**Tool:** Gemini / ChatGPT  
**Action:** Discuss the feature *before* writing code.
- Define the Data Model (Structs, Enums).
- Define the Business Logic (Math, Algorithms).
- **Output:** A plan, logic formulas, or Swift struct definitions.

### Step 2: Implementation (The Builder)
**Tool:** Cursor (IDE)  
**Action:** Implement the plan using the Architect's output.
- Use `Cmd+K` (Edit) or `Cmd+L` (Chat) in Cursor.
- Paste the Architect's logic/specs.
- Ask Cursor to build the UI around that logic.
- **Rule:** Do not ask Cursor to redesign the architecture. Just build it.

### Step 3: Synchronization (The Truth)
**Tool:** Terminal / Xcode  
**Action:** Commit and Push.
- **Rule:** Before asking the Architect for help with a bug, you **must** push your code so the Architect can see the real state of the project.

### Step 4: Review (The Architect)
**Tool:** Gemini / ChatGPT  
**Action:** Validate the work.
- "I pushed the new feature. Please review `FileX.swift` for safety and performance."
- Update `STATUS.md` with the result.

---

## 3. The Master Prompt
*Paste this when starting a **new chat session** with the Architect (Gemini/ChatGPT) to instantly restore context.*

```text
I am working on "HomeInventory" (iOS/SwiftUI/Local-First) at public repo: https://github.com/ycetindil/HomeInventory

Please read these files once to build full context:
1) .cursorrules: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/.cursorrules
2) Docs/ARCHITECTURE.md: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/Docs/ARCHITECTURE.md
3) Docs/STATUS.md: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/Docs/STATUS.md
4) Docs/ROADMAP.md: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/Docs/ROADMAP.md

Act as my Architect.
Goal: Produce the next ONE task spec (smallest valuable increment) based on ROADMAP "Next Up".

========================
WORKFLOW COACHING (CRITICAL)
========================
You must act as a lightweight workflow coach to prevent context loss.

During the session, I will use these triggers:
- "COMMIT: <slice done summary>"
- "DECISION: <decision summary>"

When I write "COMMIT:", you MUST respond with ONLY:
1) "COMMIT NOW" or "NO COMMIT YET" (choose one)
2) ONE suggested commit message in this format: type(scope): summary
3) (Optional, 1 line max) what I should quickly sanity-check in the simulator before committing
No extra commentary.

When I write "DECISION:", you MUST respond with ONLY:
1) One bullet to add under Docs/STATUS.md → "Decisions & Notes (Session Log)" using today's date
2) If the decision changes ROADMAP or ARCHITECTURE, say exactly what to update in ONE sentence
No extra commentary.

While creating the Cursor Spec:
- Break the work into 1–3 "Slices" (A/B/C). Each slice must be runnable/compilable.
- At the end of each slice include a "COMMIT checkpoint" with an exact commit message.
- If any file is moved/renamed, require an immediate COMMIT checkpoint right after the move/rename.

========================
SCOPE RULES
========================
- Prefer changes that touch ≤ 3 files total (excluding new small component files).
- Avoid refactors/re-architecture unless required for compilation.

========================
CRITICAL OUTPUT REQUIREMENTS
========================
- Output ONLY a single markdown code block titled "Cursor Spec". No text before or after.
- Do NOT write implementation code.
  - Snippets are allowed ONLY if wrapped as plain text markers:
    BEGIN_SWIFT
    ...
    END_SWIFT
- Include "Target Files" with exact paths.
- Include "⚠️ Cursor Actions" listing exactly which files I must @-attach in Cursor.
- If more files are required than those listed, STOP and ask me to attach them—do not guess.
- Include the exact ROADMAP item you selected (copy the bullet text).

========================
Cursor Spec format (REQUIRED SECTIONS)
========================
1) ⚠️ Cursor Actions (the @-mentions)
2) Selected ROADMAP item (exact bullet text)
3) Goal / user-visible behavior
4) Target Files (exact paths)
5) Slices (A/B/C)
   - For each slice:
     - Step-by-step logic (pseudo-code)
     - Acceptance criteria (what must be true)
     - Verification steps (simulator steps)
     - COMMIT checkpoint (exact commit message)
6) BEGIN_SWIFT … END_SWIFT (optional; only for standard snippets)

---

## 4. Finishing the Session up

### Step 1: Generate a Single Markdown "Daily Bundle" (NO truncation)
This generates ONE file you can paste into the Architect chat.

### Step 2: End-of-session prompt for the Architect
*Paste this at the end of the chat session with the Architect (Gemini/ChatGPT).*

```text
I have finished the implementation for today.

Inputs:
- DAILY_BUNDLE.md (source of truth: includes docs snapshots + full diffs + commit patches)

Action:
1) Update Docs/STATUS.md (only based on evidence from DAILY_BUNDLE).
2) Update Docs/ROADMAP.md (check off items supported by evidence).
3) Update Docs/ARCHITECTURE.md only if data model/core patterns changed; otherwise output: "No change needed".
4) Generate ONE commit message: type(scope): summary
5) Chat title: one line

EVIDENCE RULE:
- If the Docs snapshots conflict with diffs/patches, trust the diffs/patches.

OUTPUT REQUIREMENTS (STRICT):
- Provide DROP-IN READY FULL CONTENTS for:
  a) Docs/STATUS.md
  b) Docs/ROADMAP.md
  c) Docs/ARCHITECTURE.md (only if changed; else say "No change needed")
- Then output:
  - COMMIT: <one line>
  - TITLE: <one line>
- No extra commentary.
- If you infer any decisions from the diffs/patches that are NOT already recorded in Docs/STATUS.md → Decisions & Notes, output a final section "MISSING DECISIONS" with suggested bullets (do not modify files with them).

DAILY_BUNDLE.md:
[PASTE HERE]