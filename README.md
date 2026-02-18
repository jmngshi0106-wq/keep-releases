# Keep

Keep is a **secure-by-default, RLS-first multi-tenant layer** for Supabase/Postgres; this repo is a **public release mirror** (the source repository is private).

**Start here:** run the **Install → Verify → Demo → PASS** loop below (the step blocks are copied verbatim from `docs/quickstart.md`).

**Trust links (public):**

* What Keep Guarantees: [docs/guarantees.md](docs/guarantees.md)
* How Keep Fails: [docs/how-keep-fails.md](docs/how-keep-fails.md)

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
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/v0.1.14/keep-0.1.14-darwin-arm64.tar.gz
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/v0.1.14/keep-0.1.14-darwin-arm64.tar.gz.sha256
shasum -a 256 -c keep-0.1.14-darwin-arm64.tar.gz.sha256
```

### Linux (x86_64)

```bash
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/v0.1.14/keep-0.1.14-linux-x86_64.tar.gz
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/v0.1.14/keep-0.1.14-linux-x86_64.tar.gz.sha256
sha256sum -c keep-0.1.14-linux-x86_64.tar.gz.sha256
```

---

## 3) Demo (one copy/paste command)

This creates a fresh temp workspace, starts Supabase local, and runs the proof loop.

```bash
bash -lc 'set -euo pipefail; tmp="$(mktemp -d)"; cd "$tmp"; mkdir keep-project && cd keep-project; supabase init; supabase start; keep init; keep seed; keep test'
```

On success, you should see:
`✓ Test run complete.`

---

## More docs

* Guarantees: `docs/guarantees.md`
* How Keep fails: `docs/how-keep-fails.md`

## 2) Verbatim-consistency confirmation (README vs public quickstart)

* The **Install** block matches `docs/quickstart.md` lines 17–24 (and the same block appears in the v0.1.14 release notes lines 15–22).
* The **Verify** blocks match `docs/quickstart.md` lines 28–44 (and the same blocks appear in the v0.1.14 release notes lines 26–42).
* The **Demo + PASS expectation** match `docs/quickstart.md` lines 48–57 (and the same block appears in the v0.1.14 release notes lines 46–56).

## 3) PASS criteria checklist (stranger-friendly, from README alone)

* [ ] **Install**: run the install block; `keep version` exits successfully.
* [ ] **Verify** (your platform): run the sha256 block; the check command exits **0**.
* [ ] **Demo**: run the one-command demo block.
* [ ] **PASS**: output includes: `✓ Test run complete.`

## 4) Drift detected + smallest fix

* Drift in current README vs `docs/quickstart.md` was present in **Prerequisites bullet style** and the **docs section format/links**.
* Smallest fix (README-only, applied above): copy the Prerequisites + Install/Verify/Demo/PASS + More docs blocks **verbatim** from `docs/quickstart.md`, and keep any extra “repo-homepage selling” text **above** the canonical blocks.

