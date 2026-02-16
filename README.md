# keep-releases

Public release mirror for Keep CLI binaries + checksums.
Source repository is private.

# Keep v0.1.14 — Launch Spine (Install → Verify → Demo → PASS)

Keep is a **secure-by-default, RLS-first multi-tenant layer** for Supabase/Postgres.
This release gives you a self-serve proof loop where **pgTAP proves** tenant isolation (Alice/Bob) and **Eve sees nothing**.

---

## Prerequisites

* Supabase CLI installed (`supabase`)
* Docker running

---

## 1) Install (global, official)

Keep’s official installer URL is the **GitHub Release asset** (not `raw/main`):

```bash
curl -fsSL -L https://github.com/jmngshi0106-wq/keep-releases/releases/latest/download/install.sh | sudo bash
keep version
```

---

## 2) Verify the v0.1.14 release tarball (sha256)

### macOS (darwin-arm64)

```bash
gh release download v0.1.14 -R jmngshi0106-wq/keep -p "keep-0.1.14-darwin-arm64.tar.gz*"
shasum -a 256 -c keep-0.1.14-darwin-arm64.tar.gz.sha256
```

### Linux (x86_64)

```bash
gh release download v0.1.14 -R jmngshi0106-wq/keep -p "keep-0.1.14-linux-x86_64.tar.gz*"
sha256sum -c keep-0.1.14-linux-x86_64.tar.gz.sha256
```

---

## 3) Demo (one-command proof loop)

This runs the full Keep proof loop in a fresh temp directory using Supabase local.

From the Keep monorepo:

```bash
bash keep-cli/ci/one-command-demo.sh
```

By default this uses the repo dev CLI:

* `keep-cli/bin/keep.dev`

To demo a shipped artifact instead (for example, from a GitHub Release tarball),
point `KEEP_CLI_PATH` at an executable `keep` binary:

```bash
KEEP_CLI_PATH="/absolute/path/to/bin/keep" bash keep-cli/ci/one-command-demo.sh
```

On success, the demo prints:
`==> PASS: one-command demo succeeded (pgTAP 6/6).`

It also prints an evidence directory path and preserves it on disk.

---

## Docs (normative)

* Quickstart: [https://github.com/jmngshi0106-wq/keep/blob/v0.1.14/docs/quickstart.md](https://github.com/jmngshi0106-wq/keep/blob/v0.1.14/docs/quickstart.md)
* What Keep guarantees: [https://github.com/jmngshi0106-wq/keep/blob/v0.1.14/docs/guarantees.md](https://github.com/jmngshi0106-wq/keep/blob/v0.1.14/docs/guarantees.md)
* How Keep fails: [https://github.com/jmngshi0106-wq/keep/blob/v0.1.14/docs/how-keep-fails.md](https://github.com/jmngshi0106-wq/keep/blob/v0.1.14/docs/how-keep-fails.md)

**Full Changelog**: [https://github.com/jmngshi0106-wq/keep/compare/v0.1.7...v0.1.14](https://github.com/jmngshi0106-wq/keep/compare/v0.1.7...v0.1.14)

---

## Docs drift decision (Milestone 0)

No `docs/quickstart.md` patch required for canonical blocks: the **install**, **demo**, **artifact override**, and **PASS line** above are copied verbatim from `docs/quickstart.md` (lines 15–38 and 56–63 in the evidence you provided).

The sha256 verification section is **release-notes-only** (it’s not present in `docs/quickstart.md`), but it does not contradict any quickstart canonical block.

---

## PASS criteria checklist (stranger-friendly)

* [ ] **Install**: run the official install block; `keep version` exits successfully.
* [ ] **Verify** (your platform): run the sha256 block; the check command exits **0**.
* [ ] **Demo**: run `bash keep-cli/ci/one-command-demo.sh`.
* [ ] **PASS**: output includes **exactly**: `==> PASS: one-command demo succeeded (pgTAP 6/6).`
