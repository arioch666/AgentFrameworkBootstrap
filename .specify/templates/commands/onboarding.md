# Command: speckit-onboarding

**Purpose:** Guided, hands-on tutorial for first-time Spec Kit users. Works with any AI assistant (not tied to a single editor).

**Canonical path:** `.specify/templates/commands/onboarding.md`

---

## User Input

```text
$ARGUMENTS
```

Optional: a short slug for the lab branch (e.g. `my-lab`). If empty, use today's date as `YYYYMMDD`.

---

## Rules (read first)

1. **Disposable lab only** — All work for this tutorial uses FeatureId `099-speckit-onboarding-lab` and branch `onboarding/speckit-lab-<slug-or-date>`.
2. **Never merge the lab branch into `develop`** (or your main trunk). The lab exists only to practice Spec Kit.
3. **Sandbox paths only** — During implement, change **only** files under `.specify/specs/099-speckit-onboarding-lab/` (especially `sandbox/`). Do not edit `src/`, `agents.yml`, root `README.md`, or production agents.
4. **Mandatory cleanup** — The last phase **must** delete the lab initiative folder and drop the lab branch.
5. **Stop gates** — Do not advance to the next phase until the current phase is complete (or the user explicitly skips an optional step).

---

## Phase 0 — Pre-flight (git + lab branch)

1. Confirm the repository root contains `.specify/` (Spec Kit is initialized). If missing, tell the user to run framework bootstrap (`docs/afb-init.md`) or copy `.specify/` from AgentFrameworkBootstrap before continuing.

2. Check git status at the repo root:
   - If there are uncommitted changes on the current branch, **warn** and ask the user to commit, stash, or confirm they want to proceed.
   - Recommend starting from an updated trunk: `git checkout develop` (or the project's main integration branch) and `git pull` when a remote exists.

3. Create and checkout the lab branch (run shell commands when the environment allows):
   - Slug = first word from `$ARGUMENTS` if provided, else `YYYYMMDD` (local date).
   - Branch name: `onboarding/speckit-lab-<slug>`
   - Example: `git checkout -b onboarding/speckit-lab-20260505`

4. Tell the user:
   - "You are on a **practice branch**. Nothing from this tutorial should be merged to `develop`."
   - "At the end we will delete `.specify/specs/099-speckit-onboarding-lab/` and remove this branch."

**Stop gate:** Lab branch exists (or user confirms branch creation manually).

---

## Phase 1 — Orient (teach, no writes yet)

Explain in plain language:

| Topic | Pointer |
|-------|---------|
| Lifecycle | `spec.md` → `plan.md` → `tasks.md` → implement (tracked execution) |
| Governance | `.specify/memory/constitution.md` |
| FeatureId format | `NNN-kebab-case-short-name` — see `docs/conventions.md` |
| Example initiative | `.specify/specs/002-spec-kit-docs-example/` |
| Full walkthrough | `docs/examples/spec-kit-workflow-example.md` |
| Framework context | `AGENTS.md` (agents + Spec Kit together) |

**Stop gate:** User confirms they understand the four artifact types (spec, plan, tasks, implement).

---

## Phase 2 — Read-only review

1. Skim `.specify/memory/constitution.md` (summarize 3–5 bullets for the user).
2. Open `.specify/specs/002-spec-kit-docs-example/spec.md` and point out: user stories, requirements, acceptance flavor.
3. State that the lab will create **`099-speckit-onboarding-lab`** — a training slot, not a product feature.

**Stop gate:** User has opened or acknowledged the reference spec.

---

## Phase 3 — Hands-on: `speckit-specify`

Run the **speckit-specify** command (or equivalent: follow `.specify/templates/commands/specify.md` / project skill `speckit-specify`) with this **exact lab brief**:

```text
FeatureId: 099-speckit-onboarding-lab

Create a Spec Kit training initiative. All deliverables are meta-documentation only under:
.specify/specs/099-speckit-onboarding-lab/sandbox/

Goals:
- learning-notes.md — what each Spec Kit phase means (spec, plan, tasks, implement)
- checklist.md — checkbox list the learner completed during this tutorial

Do not require changes outside .specify/specs/099-speckit-onboarding-lab/.
```

**Important:** Ensure `spec.md` is created at `.specify/specs/099-speckit-onboarding-lab/spec.md` (create the directory if the specify flow uses a different convention, normalize to this path).

**Stop gate:** `spec.md` exists under `099-speckit-onboarding-lab`.

---

## Phase 4 — Optional: `speckit-clarify`

Offer once:

- Run **speckit-clarify** for `099-speckit-onboarding-lab` if anything in `spec.md` is marked NEEDS CLARIFICATION.
- If nothing needs clarification, say so and continue.

**Stop gate:** User accepts skip or clarify completes.

---

## Phase 5 — Hands-on: `speckit-plan`

Run **speckit-plan** for the same initiative (`099-speckit-onboarding-lab`).

Verify `plan.md` exists at `.specify/specs/099-speckit-onboarding-lab/plan.md` and only plans work under the lab tree (sandbox files + spec artifacts).

**Stop gate:** `plan.md` exists.

---

## Phase 6 — Hands-on: `speckit-tasks`

Run **speckit-tasks** for `099-speckit-onboarding-lab`.

Verify `tasks.md` exists. **Scan tasks:** every file path mentioned must stay under `.specify/specs/099-speckit-onboarding-lab/`. If any task points elsewhere, **edit tasks.md** to restrict to sandbox paths before implement.

**Stop gate:** `tasks.md` exists and paths are lab-scoped.

---

## Phase 7 — Hands-on: `speckit-implement`

Run **speckit-implement** for `099-speckit-onboarding-lab`.

Create or update only:

- `.specify/specs/099-speckit-onboarding-lab/sandbox/learning-notes.md`
- `.specify/specs/099-speckit-onboarding-lab/sandbox/checklist.md`

**Stop gate:** Sandbox files exist; no edits outside the lab tree.

---

## Phase 8 — Optional: `speckit-analyze`

Offer **speckit-analyze** across `spec.md`, `plan.md`, and `tasks.md` for the lab initiative. Summarize one consistency finding for the learner.

**Stop gate:** User skips or analyze completes.

---

## Phase 9 — Mandatory cleanup (do not skip)

1. Delete the lab initiative directory:
   - Remove `.specify/specs/099-speckit-onboarding-lab/` entirely (`git rm -r` if tracked, else delete folder).

2. On the lab branch, optional commit:
   - `git commit -am "chore(onboarding): remove speckit lab artifacts"` (only if there are staged changes worth recording).

3. Return to trunk and delete lab branch (when shell is available):
   - `git checkout develop` (or project's main integration branch)
   - `git branch -D onboarding/speckit-lab-<slug>`

4. Verify:
   - `git status` shows **no** remaining `099-speckit-onboarding-lab` paths.
   - Tell the user: **Do not open a PR from the lab branch. Do not merge lab work into `develop`.**

**Abort recovery (if user stops early):**

- `git checkout develop`
- `git branch -D onboarding/speckit-lab-*` (matching branch)
- Manually delete `.specify/specs/099-speckit-onboarding-lab/` if it still exists

**Stop gate:** Lab folder gone; user is on trunk (or informed how to get there).

---

## Phase 10 — What's next

Tell the user:

1. Pick a real `FeatureId` (e.g. `003-my-feature`) on a **normal** feature branch.
2. Run `speckit-specify` → `speckit-plan` → `speckit-tasks` → `speckit-implement` for real work.
3. For framework/docs onboarding (agents, vendoring), see `.agents/onboarding/agent.md` and `docs/README.md`.
4. For bootstrapping agents into another repo, see `docs/afb-init.md`.

---

## Completion checklist (assistant)

- [ ] Lab branch created; user warned not to merge it
- [ ] `099-speckit-onboarding-lab` spec/plan/tasks/sandbox completed
- [ ] No files modified outside `.specify/specs/099-speckit-onboarding-lab/`
- [ ] Lab directory deleted
- [ ] Lab branch deleted (or user instructed)
- [ ] User pointed to real FeatureId workflow
