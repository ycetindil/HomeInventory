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
- Paste the Architect's logic/structs.
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
I am working on an iOS app called "HomeInventory". It is a local-first, SwiftUI app using MVVM and JSON persistence (no Core Data).
My public repository is https://github.com/ycetindil/HomeInventory.

Please initialize your context by reading the following 4 files from my repo:

1. `.cursorrules: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/.cursorrules` (Defines our tech stack, constraints, and coding style).
2. `Docs/ARCHITECTURE.md: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/Docs/ARCHITECTURE.md` (Explains the "Why", data models, and domain boundaries).
3. `Docs/STATUS.md: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/Docs/STATUS.md` (Current state of the code and recent changes).
4. `Docs/ROADMAP.md: https://raw.githubusercontent.com/ycetindil/HomeInventory/refs/heads/main/Docs/ROADMAP.md` (Our backlog and immediate next steps).

My Workflow:
1. I will discuss architecture and logic with you here.
2. I will use Cursor to write the actual code based on your plan.
3. I will push changes to GitHub before asking you to review or debug.

Action:
Please read the files above, then summarize the current status of the project and identifying the specific task we are supposed to work on next according to the Roadmap.
Act as my Architect. Define the specs and the interface changes required. I can then take these specific blocks to Cursor to implement them. Do not try to give me the code here.

## 4. Finishing the Session up

Before finishing up for the day please:
1. Give me a title for this chat
2. Updated STATUS.md
3. Updated ROADMAP.md
4. Updated ARCHITECTURE.md
if there is any changes to them. I am attaching their current files here.
5. Give me a commit message for pushing the changes to GitHub