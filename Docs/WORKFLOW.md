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
1. .cursorrules: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/.cursorrules
2. Docs/ARCHITECTURE.md: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/Docs/ARCHITECTURE.md
3. Docs/STATUS.md: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/Docs/STATUS.md
4. Docs/ROADMAP.md: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/Docs/ROADMAP.md

Act as my Architect.
Goal: Produce the next ONE task spec (smallest valuable increment) based on ROADMAP "Next Up".

WORKFLOW REQUIREMENT:
At the end of the Cursor Spec, add a section "Commit checkpoints".
- Define 1–3 checkpoints where the app should compile/run and I should commit.
- Provide the exact commit messages (semantic where possible).
- If the task includes file moves/renames, require an immediate checkpoint commit after the move.

SCOPE RULES:
- Prefer changes that touch ≤ 3 files total.
- Avoid refactors/re-architecture unless required for compilation.

CRITICAL OUTPUT REQUIREMENTS:
- Output ONLY a single markdown code block titled "Cursor Spec". No text before or after.
- Do NOT write implementation code (snippets allowed only as BEGIN_SWIFT/END_SWIFT plain text).
- Include "Target Files" with exact paths.
- Include "⚠️ Cursor Actions" listing exactly which files I must @-attach in Cursor.
- If more files are required than those listed, STOP and ask me to attach them—do not guess.
- Include the exact ROADMAP item you selected (copy the bullet text).

Spec sections:
1) ⚠️ Cursor Actions (the @-mentions)
2) Selected ROADMAP item
3) Goal / user-visible behavior
4) Target Files (exact paths)
5) Step-by-step logic (pseudo-code)
6) Acceptance criteria
7) Verification steps (simulator steps)
8) BEGIN_SWIFT … END_SWIFT (optional)

---

## 4. Finishing the Session up

### Step 1: Generate a Single Markdown "Daily Bundle" (NO truncation)
This generates ONE file you can paste into the Architect chat.

### Step 2: End-of-session prompt for the Architect
*Paste this at the end of the chat session with the Architect (Gemini/ChatGPT).*

```text
I have finished the implementation for today.

You must follow this output contract exactly.

SOURCE OF TRUTH:
Use ONLY the pasted DAILY_BUNDLE.md below. Ignore chat history.

TASK:
Update these files based on evidence in the bundle:
1) Docs/STATUS.md
2) Docs/ROADMAP.md
3) Docs/ARCHITECTURE.md ONLY if needed; otherwise output "ARCHITECTURE: no change".

HARD RULES:
- Do NOT invent issues or claims.
- Keep changes minimal and consistent with the current docs shown in the bundle.
- Do not edit any other file.

OUTPUT CONTRACT (DROP-IN READY FILES):
1) Output the COMPLETE contents of Docs/STATUS.md inside ONE fenced markdown block.
   - The first line inside the block must be: <!-- FILE: Docs/STATUS.md -->
2) Output the COMPLETE contents of Docs/ROADMAP.md inside ONE fenced markdown block.
   - The first line inside the block must be: <!-- FILE: Docs/ROADMAP.md -->
3) For Docs/ARCHITECTURE.md:
   - If changes are needed, output the COMPLETE contents inside ONE fenced markdown block with:
     <!-- FILE: Docs/ARCHITECTURE.md -->
   - Otherwise output exactly: ARCHITECTURE: no change
4) Then output exactly two lines (no other text):
COMMIT: <type(scope): summary>
TITLE: <short title>

DAILY_BUNDLE.md:
[PASTE .local/DAILY_BUNDLE.md HERE]
