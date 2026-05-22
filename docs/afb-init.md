# `afb_init` — bootstrap AgentFrameworkBootstrap into a project

`afb_init` vendors framework assets into a **downstream repository**: `.agents/`, shared skills, `agents.yml` (additive merge), optional Spec Kit scaffolding, Cursor rules/skills, root AI entry points, and canonical project memory.

It is a **native Bash** script — no PowerShell, no runtime package.

## Requirements

- **Bash** (the script targets `bash`, available by default on macOS/Linux and via **Git Bash** or **WSL** on Windows).
- Standard POSIX tools: `awk`, `grep`, `sed`, `cp`, `mkdir`.
- For the download flow ([`afb_bootstrap.sh`](../scripts/afb_bootstrap.sh)): **`curl`** (or `wget`) and **`unzip`**, plus network access.
- A checkout of this framework repo (or a release tarball) on disk — **or** use [`afb_bootstrap.sh`](../scripts/afb_bootstrap.sh) (below), which downloads tagged release zips from GitHub so you do not need a prior clone.

## Download release ZIP + run (`afb_bootstrap.sh`)

Use **[`scripts/afb_bootstrap.sh`](../scripts/afb_bootstrap.sh)** when you want a **single command** that:

1. Downloads `https://github.com/<org>/<repo>/archive/refs/tags/<FrameworkTag>.zip` (default org/repo: `arioch666` / `AgentFrameworkBootstrap`).
2. Optionally downloads each **pack** tag zip the same way (`pack-kotlin-v*`, `pack-python-v*`, …).
3. Unpacks into a **temp directory**, then runs **`scripts/afb_init.sh`** from the unpacked **framework** tree with `--source-repo` set to that tree and `--pack-source` for each unpacked pack.

Example (framework + Kotlin pack into current directory):

```bash
./scripts/afb_bootstrap.sh \
  --framework-tag framework-v0.1.1 \
  --pack-tag pack-kotlin-v0.1.1 \
  --target .
```

Preview without downloading:

```bash
./scripts/afb_bootstrap.sh --framework-tag framework-v0.1.1 --dry-run
```

**Distribution:** A single saved copy of `afb_bootstrap.sh` is enough for the **download + init** path: the framework zip from GitHub already contains `scripts/afb_init.sh`, `scripts/lib/afb_merge_agents.sh`, `.agents/`, `.specify/`, etc. You can still run it from a full clone if you prefer.

**Flags:** `--skip-cleanup` leaves the temp unzip folder for debugging. `--allow-dirty-git` skips the abort when the target repo has uncommitted changes. `--skip-spec-kit`, `--skip-cursor`, `--skip-agents-md`, `--no-canonical-memory` are passed through to `afb_init.sh`.

## Making the command available in your project

This framework is **not** published as an npm/PyPI/Maven dependency. For bootstrap you only need **any** pinned checkout or archive of this repo on disk long enough to run `scripts/afb_init.sh` against your project root.

### Recommended: One-time copy + commit

Most downstream teams should treat `afb_init` as a **single setup step** (local machine, teammate laptop, or CI job), then **own the vendored files forever**:

1. Pick a **pinned trunk tag** (and optional pack tag) from [releases.md](releases.md).
2. Obtain the framework **once** — e.g. `git clone` at that tag, download the GitHub **tag zip**, or use a short-lived temp directory.
3. Run `afb_init.sh` with `--target` set to your **application repo root** (and `--pack-source` for each pack checkout if needed).
4. **Commit** everything `afb_init` wrote into that repo: `.agents/`, `agents.yml`, `ai/memory/memory.md`, `.specify/` (if created), optional `.cursor/`, and the AI entry points (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`).
5. After that, **day-to-day work** is only in your repo: edit agents, skills, and `agents.yml` there. **Do not** rerun `afb_init` unless you **choose** to refresh from upstream (new framework tag), re-merge registry entries, or recreate the layout.

You **do not** need a permanent submodule or a build step that re-downloads the framework on every compile. Optional `package.json` / Gradle helpers below are for **convenience on first run or rare upgrades**—keep them **manual** (do not hook them into every `build` / `npm run build` unless you explicitly want that).

### Optional: Git submodule (ongoing link to upstream)

Use a submodule **only** if you want a **persistent pointer** to this repository for frequent updates. Flow: add submodule, pin tag under `vendor/AgentFrameworkBootstrap`, run `afb_init`, **then either** keep the submodule for updates **or** remove it after vendoring if you prefer a pure copy + commit workflow.

```bash
git submodule add https://github.com/<org>/AgentFrameworkBootstrap.git vendor/AgentFrameworkBootstrap
cd vendor/AgentFrameworkBootstrap
git fetch --tags origin
git checkout framework-v0.1.0
cd ../..
git add .gitmodules vendor/AgentFrameworkBootstrap
git commit -m "Add AgentFrameworkBootstrap submodule pinned to framework-v0.1.0"
```

Optional language pack: add a second submodule (for example `vendor/AgentFrameworkBootstrap-python`) checked out at `pack-python-v*`, and pass it with `--pack-source` (see templates below).

### Optional: scripts-only vendor folder

If you want a **repeatable** local command without a submodule, you may vendor **only** `scripts/` + `scripts/lib/` into your repo (e.g. `tools/afb/scripts/`) and pass `--source-repo` pointing at a **full** separate checkout or unpacked archive when you run `afb_init`. For Spec Kit bootstrap, `--source-repo` must still resolve to a tree that contains `.specify/`.

### npm / pnpm / Yarn (optional script alias)

If your project already has a `package.json`, you can add **manual** scripts that invoke `afb_init` (first run or rare upgrades). Paths often point at a **temporary clone** or a **vendored `scripts/`** tree—not a requirement to keep the full framework in the repo after you have committed the outputs.

```json
{
  "scripts": {
    "afb_init": "bash ./vendor/AgentFrameworkBootstrap/scripts/afb_init.sh --target .",
    "afb_init:dry": "bash ./vendor/AgentFrameworkBootstrap/scripts/afb_init.sh --target . --dry-run",
    "afb_init:validate": "bash ./vendor/AgentFrameworkBootstrap/scripts/afb_init.sh --target . --validate-only"
  }
}
```

On Windows, run these from **Git Bash** or **WSL** (the scripts are Bash).

### Gradle (Kotlin DSL or Groovy)

There is **no** `implementation("…:agent-framework-bootstrap:…")` artifact on Maven Central. Gradle can still expose a **manual** task that runs `afb_init.sh` **once** (or on demand) using a **temporary** unpacked archive or a local path—**do not** attach that task to every `build` unless you intend to re-vendor on every compile.

#### Option A — `Exec` against a path (clone, submodule, or unpacked zip)

Point `commandLine` at wherever `scripts/afb_init.sh` lives for this run (example uses a submodule path; swap for `layout.buildDirectory/...` after unpacking a tag zip).

**Kotlin DSL** (`build.gradle.kts` or `buildSrc/...`):

```kotlin
tasks.register<Exec>("afbInit") {
    group = "agent framework"
    description = "Vendor AgentFrameworkBootstrap into this repository (see docs/afb-init.md)"
    workingDir = rootDir
    val script = rootDir.resolve("vendor/AgentFrameworkBootstrap/scripts/afb_init.sh")
    commandLine(
        "bash", script.absolutePath,
        "--target", rootDir.absolutePath
        // Optional: , "--pack-source", rootDir.resolve("vendor/AgentFrameworkBootstrap-python").absolutePath
    )
    isIgnoreExitValue = false
}
```

**Groovy** (`build.gradle`):

```groovy
tasks.register('afbInit', Exec) {
    group = 'agent framework'
    description = 'Vendor AgentFrameworkBootstrap into this repository (see docs/afb-init.md)'
    workingDir rootDir
    def script = file('vendor/AgentFrameworkBootstrap/scripts/afb_init.sh')
    commandLine 'bash', script.absolutePath, '--target', rootDir.absolutePath
}
```

Use `./gradlew afbInit` **manually** when bootstrapping or upgrading—not as an implicit dependency of `build`. On Windows agents, ensure `bash` is available (Git Bash or WSL) on `PATH`.

#### Option B — Pinned GitHub archive + Gradle (good for one-time / no submodule)

Use this when you want **one-time copy + commit** without leaving a submodule in the tree: a **manual** task chain downloads the **tag archive** from GitHub (same pin as [releases.md](releases.md)), unpacks under `build/`, runs `afb_init.sh` from that tree with `--source-repo` set to the unpacked root, then you **commit** the vendored files in your app repo and remove or ignore `build/afb` as usual.

Pin the revision in `gradle.properties` (not a Maven coordinate):

```properties
afb.github.repo=your-org/AgentFrameworkBootstrap
afb.framework.tag=framework-v0.1.0
```

GitHub serves archives at:

`https://github.com/<owner>/<repo>/archive/refs/tags/<tag>.zip`

The zip contains one top-level directory named `<repo>-<tag>` with `/` in `<tag>` turned into `-` (for example `AgentFrameworkBootstrap-framework-v0.1.0`).

**Kotlin DSL** — download with the JDK only, unpack with `zipTree`, then `afbInitFromArchive`:

```kotlin
import java.net.URI
import java.nio.file.Files
import java.nio.file.StandardCopyOption

val afbGithubRepo = providers.gradleProperty("afb.github.repo").orElse("your-org/AgentFrameworkBootstrap")
val afbFrameworkTag = providers.gradleProperty("afb.framework.tag").orElse("framework-v0.1.0")

val afbDownloadFramework = tasks.register("afbDownloadFramework") {
    group = "agent framework"
    description = "Download pinned AgentFrameworkBootstrap tag archive from GitHub"
    doLast {
        val repo = afbGithubRepo.get()
        val tag = afbFrameworkTag.get()
        val zip = layout.buildDirectory.dir("afb").get().asFile.resolve("trunk.zip")
        zip.parentFile.mkdirs()
        val url = "https://github.com/$repo/archive/refs/tags/$tag.zip"
        URI.create(url).toURL().openStream().use { input ->
            Files.copy(input, zip.toPath(), StandardCopyOption.REPLACE_EXISTING)
        }
    }
}

val afbUnpackFramework = tasks.register<Copy>("afbUnpackFramework") {
    group = "agent framework"
    description = "Unpack AgentFrameworkBootstrap archive under build/"
    dependsOn(afbDownloadFramework)
    val zip = layout.buildDirectory.dir("afb").get().asFile.resolve("trunk.zip")
    from(zipTree(zip))
    into(layout.buildDirectory.dir("afb/checkout"))
}

tasks.register<Exec>("afbInitFromArchive") {
    group = "agent framework"
    description = "Run afb_init.sh from the downloaded archive (see docs/afb-init.md)"
    dependsOn(afbUnpackFramework)
    workingDir = rootDir
    doFirst {
        val repo = afbGithubRepo.get()
        val tag = afbFrameworkTag.get()
        val repoName = repo.substringAfterLast('/')
        val extractedRoot = layout.buildDirectory.dir("afb/checkout").get().asFile
            .resolve("${repoName}-${tag.replace('/', '-')}")
        val script = extractedRoot.resolve("scripts/afb_init.sh")
        check(script.isFile) {
            "Expected $script — check afb.github.repo / afb.framework.tag (GitHub top folder is $repoName-${tag.replace('/', '-')})."
        }
        executable = "bash"
        args = listOf(
            script.absolutePath,
            "--target", rootDir.absolutePath,
            "--source-repo", extractedRoot.absolutePath
        )
    }
}
```

Run `./gradlew afbInitFromArchive`. If you prefer not to use `java.net.URI` / `URL` in builds, swap the download `doLast` for a plugin such as [`de.undercouch.download`](https://github.com/michel-kraemer/gradle-download-task) or your org’s standard HTTP task.

#### Why not `implementation(...)`?

Gradle’s `implementation` / `api` configurations resolve **JVM bytecode** (or Kotlin multiplatform metadata). This framework ships **markdown + YAML + Bash**; the build “dependency” is really a **pinned source tree** plus a **task** that runs `afb_init`.

### Command template (Bash / macOS / Linux / Git Bash / WSL)

Replace placeholders with absolute or repo-relative paths. `--source-repo` defaults to the parent of `scripts/` inside the framework checkout, so you can omit it when the script you invoke lives inside that checkout.

```bash
bash "<PATH_TO_FRAMEWORK>/scripts/afb_init.sh" \
  --target "<DOWNSTREAM_PROJECT_ROOT>" \
  --source-repo "<PATH_TO_FRAMEWORK_TRUNK>" \
  --pack-source "<PATH_TO_PACK_CHECKOUT_1>" \
  --pack-source "<PATH_TO_PACK_CHECKOUT_2>"
```

**Minimal** (bootstrap current directory; framework at `./vendor/AgentFrameworkBootstrap`):

```bash
bash "./vendor/AgentFrameworkBootstrap/scripts/afb_init.sh" --target .
```

**With packs** (trunk submodule + Python pack submodule):

```bash
bash "./vendor/AgentFrameworkBootstrap/scripts/afb_init.sh" \
  --target . \
  --pack-source "./vendor/AgentFrameworkBootstrap-python"
```

## Entry points

| File | Use |
|------|-----|
| [scripts/afb_init.sh](../scripts/afb_init.sh) | Primary implementation (native Bash) |
| [scripts/afb_init](../scripts/afb_init) | POSIX launcher (execs `afb_init.sh`) |
| [scripts/lib/afb_merge_agents.sh](../scripts/lib/afb_merge_agents.sh) | Additive `agents.yml` merge helpers |
| [scripts/afb_bootstrap.sh](../scripts/afb_bootstrap.sh) | Download tagged GitHub zips + run `afb_init` |

## Usage

From a clone of **AgentFrameworkBootstrap**:

```bash
# Bootstrap current directory (downstream project root)
./scripts/afb_init.sh

# Explicit target + optional language pack checkouts (merge order: trunk, then each pack)
./scripts/afb_init.sh --target /work/my-app --pack-source /vendor/afb-python

# Preview only
./scripts/afb_init.sh --target /work/my-app --dry-run

# Validate an existing project (agents.yml vs .agents folders, canonical memory file, AI context pointers)
./scripts/afb_init.sh --validate-only --target /work/my-app
```

### Parameters

| Parameter | Meaning |
|-----------|---------|
| `--target` | Destination project root (default: current directory; also accepted as a positional argument). Created if missing (unless `--validate-only`). |
| `--source-repo` | Path to framework trunk checkout (default: parent of `scripts/`). |
| `--pack-source` | Extra repo roots (e.g. `python` / `kotlin` branch checkouts) merged **after** trunk. Repeatable. |
| `--dry-run` | Log actions without writing files. Post-run validation is skipped (nothing to verify yet). |
| `--skip-spec-kit` | Do not copy `.specify/` scaffold when absent; do not validate when present. |
| `--skip-cursor` | Do not merge-copy `.cursor/`. |
| `--skip-agents-md` | Do not copy root AI entry points when missing (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`). |
| `--no-canonical-memory` | Skip `ai/memory/memory.md` and per-agent delegated memory stubs. |
| `--validate-only` | Run checks and exit (`0` = OK, `2` = issues). |

## What gets installed

1. **Agents & skills** — Merge-copy `.agents/` (including `.agents/.skills/`).
2. **`agents.yml`** — If missing, copied from trunk; if present, **additive merge** (new agent blocks + missing `delegation_matrix.orchestration.can_delegate_to` entries). Implemented in [scripts/lib/afb_merge_agents.sh](../scripts/lib/afb_merge_agents.sh) (no YAML package dependency).
3. **AI entry points** — Copies `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and `.github/copilot-instructions.md` when missing (unless `--skip-agents-md`) so any assistant can auto-discover the framework.
4. **Spec Kit** — If `.specify/` **does not exist**, copies `templates/`, `scripts/`, `workflows/`, `integrations/`, `integration.json`, `init-options.json`, and `memory/constitution.md`. Does **not** copy example initiatives under `.specify/specs/*`. If `.specify/` **already exists**, scaffolding is **skipped**; a short validation warning lists common missing files.
5. **Cursor** — Merge-copy `.cursor/` (rules + skills) unless `--skip-cursor`.
6. **Canonical memory** — Ensures [`ai/memory/memory.md`](../ai/memory/memory.md) exists and rewrites each `.agents/<agent>/.memory/memory.md` to a **delegated** stub pointing at the canonical file (unless `--no-canonical-memory`).

## Validation (`--validate-only`)

Reports:

- Missing `agents.yml`
- Duplicate `agents[].id` entries
- `.agents/*` directories not referenced by a `path: .agents/<name>` line
- Missing `ai/memory/memory.md`
- Existing `CLAUDE.md`, `GEMINI.md`, or Cursor rule files that omit a pointer to `ai/memory/memory.md`

## Packs and pins

Use pinned tags per [releases.md](releases.md). Typical flow:

1. Clone or unpack trunk at `framework-v*`.
2. Optionally clone pack branches at `pack-*-v*`.
3. Run `afb_init` with `--pack-source` for each pack checkout.

## Limitations

- `agents.yml` merge assumes the **standard layout** of this framework (especially `delegation_matrix.orchestration` followed by `planning:`). Custom downstream YAML may need manual merge.
- Migrating **legacy** ad-hoc agent definitions into `.agents/<id>/` is **manual**; `afb_init` does not infer agent IDs from arbitrary files.
- Residual legacy naming in this repo is tracked in [framework-legacy-references.md](framework-legacy-references.md).
