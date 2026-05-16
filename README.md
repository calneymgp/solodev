# solodev

> Three Claude Code skills for solo developers who want **planning > vibes** without the enterprise ceremony.

```
ideia bruta
   ↓
/dev-brainstorm   →  .plans/<feature>/BRIEF.md
   ↓                  (problema, goals, non-goals, decisões, edge cases)
/dev-plan         →  .plans/<feature>/PLAN.md
   ↓                  (tasks atômicas, must-haves, reset protocol)
[reset context if you want — PLAN.md is self-sufficient]
   ↓
/dev-coding       →  executes task-by-task + SUMMARY.md
                      (TDD where it pays off, HITL checkpoints, diagnose loop)
```

---

## Why this exists

AI coding assistants are powerful but unpredictable when requirements live only in chat history. Most solutions go too far the other direction — **enterprise-grade frameworks with phases, sprints, epics, OKRs, sub-rituals** — designed for teams of 20, not for one person shipping fast.

**solodev** is the lean middle: just enough structure to keep the AI honest, nothing more.

- **No phases, no sprints, no epics.** Tasks and subtasks.
- **No code in the plan.** Decisions, contracts, verifiable acceptance criteria.
- **Vertical slices.** Each task cuts through ALL layers (schema → API → UI → test), not "all the models first".
- **Reset-friendly.** A new Claude Code session reading only the `PLAN.md` + your project's `CLAUDE.md` can resume work without context loss.
- **Anti-vibe.** Every acceptance criterion is grep/build/test verifiable. No "works correctly" allowed.
- **Karpathy minimum.** Don't invent abstractions for hypothetical futures. Don't refactor adjacent code. Surgery, not reform.

## The three skills

### `/dev-brainstorm`

Structured grilling **before** you plan. One question at a time, always with a recommendation inline. Explores the codebase silently to answer what code can answer (so you're not babysitting). Builds a one-page `BRIEF.md` live as decisions crystallize.

**Use when:** you have a raw idea and want to stress-test it before committing to a plan.

### `/dev-plan`

Transforms the `BRIEF.md` (or a finished discussion) into an atomic `PLAN.md`. Vertical slice tasks. Each task has: `type`, `slice`, `depends_on`, `read_first`, `files_modified`, `action`, `acceptance` (verifiable), `must_pass`. Plus a Must-Haves block (truths, artifacts, key links) that gets verified at the end. **No code in the plan.**

**Use when:** the BRIEF is closed and you want a reset-friendly execution document.

### `/dev-coding`

Executes the `PLAN.md` task-by-task. Reads `read_first` before touching anything. Runs `must_pass` and verifies every acceptance criterion. Supports TDD (vertical tracer bullets, never horizontal slicing), HITL checkpoints (`checkpoint:decision`, `checkpoint:human-verify`), and a disciplined diagnose loop when bugs appear. Runs Must-Haves at the end — if anything fails, creates fix-tasks instead of declaring done.

**Use when:** you have a `PLAN.md` and want to execute it without losing discipline.

---

## Install

### Global (recommended for solo devs — use from any project)

```bash
git clone https://github.com/calneymgp/solodev.git
cd solodev && ./install.sh
```

Then in any Claude Code session: `/dev-brainstorm`, `/dev-plan`, `/dev-coding`.

### Per-project

```bash
git clone https://github.com/calneymgp/solodev.git
cd solodev && ./install.sh --project
```

### Verify

In Claude Code, type `/` and you should see the three skills listed in autocomplete.

---

## Suggested workflow

```bash
# 1. New feature idea — stress-test it
> /dev-brainstorm

# Claude asks one question at a time, each with a recommendation.
# As you decide, BRIEF.md is written/updated live at .plans/<feature>/BRIEF.md
# When the BRIEF is closed:

# 2. Build the atomic plan
> /dev-plan

# Claude reads BRIEF + your project's CLAUDE.md + codebase, then writes PLAN.md
# with tasks, vertical slices, must-haves, reset protocol.

# 3. (Optional) Reset context
# /clear or new session — PLAN.md is self-sufficient.

# 4. Execute task-by-task
> /dev-coding

# Reads PLAN.md, picks next pending task, reads its read_first files,
# applies action, verifies acceptance, marks [x], moves on.
```

---

## File outputs

```
.plans/<feature-slug>/
├── BRIEF.md          # output of /dev-brainstorm — optional
├── PLAN.md           # output of /dev-plan — source of truth for /dev-coding
├── DISCOVERY.md      # optional, when library/API research was needed
└── SUMMARY.md        # output of /dev-coding when feature is done — optional
```

---

## Origin & credits

These three skills are a **synthesis** of the best ideas from four leading dev-discipline frameworks for AI coding assistants. None of them fit a solo dev as-is — too heavy, too prescriptive, or too narrow. solodev cherry-picks what compounds and drops what doesn't.

### Inspired by

- **[Matt Pocock — skills](https://github.com/mattpocock/skills)** — `grill-with-docs` taught the "one question at a time, with recommendation, explore codebase first" pattern. `tdd` taught the vertical-tracer-bullets-not-horizontal-slicing discipline. `diagnose` taught the "build the feedback loop first, that IS the skill" mindset. `to-prd` and `to-issues` showed how to break work into independently-grabbable vertical slices.

- **[OpenSpec (Fission-AI)](https://github.com/Fission-AI/OpenSpec)** — the `proposal.md` (Why → What Changes → Impact) → `tasks.md` (atomic checklist) → archive lifecycle. "Agree before you build" anti-vibe philosophy.

- **[get-shit-done (gsd-build)](https://github.com/gsd-build/get-shit-done)** — per-task frontmatter (`type`, `slice`, `depends_on`, `files_modified`, `read_first`, `must_pass`), `checkpoint:decision` / `checkpoint:human-verify` patterns, Must-Haves (truths/artifacts/key_links) for goal-backward verification. solodev keeps the spirit, drops the enterprise weight (no phases/waves/SUMMARY chaining).

- **[design.md (Google Labs)](https://github.com/google-labs-code/design.md)** — separate concern, not pulled in directly. Mentioned for completeness; useful for UI-token-heavy projects.

- **[everything-claude-code (affaan-m)](https://github.com/affaan-m/everything-claude-code)** — the comprehensive catalog that helped identify which patterns actually compound (search-first, verification-loop) vs. which are language-bound or framework-bound.

### Karpathy's anti-LLM rules in our DNA

- **Think before coding** — surface ambiguity, never assume in silence
- **Surgical changes** — touch only what was asked, don't refactor adjacent
- **Goal-driven** — convert vague tasks to verifiable criteria before starting
- **No speculative engineering** — minimum code that solves the actual problem

---

## What this is NOT

- **Not a framework.** No CLI, no daemon, no state machine, no version pinning. Just three markdown files Claude reads.
- **Not a methodology.** Use it where it helps, ignore where it doesn't. Skip `/dev-brainstorm` if the BRIEF is already clear in your head. Skip Must-Haves on a 30-line script.
- **Not for teams.** If you have 10 PMs and 30 engineers, you want the full GSD or OpenSpec. solodev is the lean version for one person.
- **Not anti-AI.** It's pro-AI. The whole point is making AI coding agents reliable for solo devs by removing the "vibe" failure mode.

---

## Anti-patterns these skills enforce

- ❌ Asking 10 questions at once
- ❌ Asking questions the codebase answers
- ❌ Accepting vague terms ("the thing", "the system", "an account")
- ❌ Putting code snippets in the plan (they go stale fast)
- ❌ Horizontal task slicing ("all models first")
- ❌ Vague acceptance ("works correctly", "user can use it")
- ❌ Reflexive dependency chaining (`task-03 depends_on: [02]` just because it's later)
- ❌ Marking done without verifying
- ❌ Refactoring while RED
- ❌ Mocking internal collaborators in tests
- ❌ Skipping `read_first` ("I know what's there")
- ❌ Inventing phases/sprints/epics when tasks + subtasks suffice

---

## Contributing

Open an issue if a pattern bites you in real solo-dev usage. Improvements should make the skills **shorter** and **sharper**, not longer.

PRs welcome if they reduce ceremony without sacrificing discipline.

---

## License

MIT — see [LICENSE](LICENSE).

If you fork/adapt: keep the credits section. The four upstream projects deserve the visibility.
