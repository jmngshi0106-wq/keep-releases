# Keep vX.Y.Z — Launch Spine (Install → Verify → Demo → PASS)

Keep is a **secure-by-default, RLS-first multi-tenant layer** for Supabase/Postgres.  
This release gives you a self-serve proof loop where **pgTAP proves** tenant isolation (Alice/Bob) and **Eve sees nothing**.

> This repo is a **public release mirror**. The source repository is private.

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

## 2) Verify the vX.Y.Z release tarball (sha256)

### macOS (darwin-arm64)

```bash
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/vX.Y.Z/keep-X.Y.Z-darwin-arm64.tar.gz
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/vX.Y.Z/keep-X.Y.Z-darwin-arm64.tar.gz.sha256
shasum -a 256 -c keep-X.Y.Z-darwin-arm64.tar.gz.sha256
```

### Linux (x86_64)

```bash
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/vX.Y.Z/keep-X.Y.Z-linux-x86_64.tar.gz
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/vX.Y.Z/keep-X.Y.Z-linux-x86_64.tar.gz.sha256
sha256sum -c keep-X.Y.Z-linux-x86_64.tar.gz.sha256
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

## PASS criteria checklist (stranger-friendly)

* [ ] **Install**: run the install block; `keep version` exits successfully.
* [ ] **Verify** (your platform): run the sha256 block; the check command exits **0**.
* [ ] **Demo**: run the one-command demo block.
* [ ] **PASS**: output includes: `✓ Test run complete.`

---

## Docs (public)

* Quickstart: [https://github.com/jmngshi0106-wq/keep-releases/blob/main/docs/quickstart.md](https://github.com/jmngshi0106-wq/keep-releases/blob/main/docs/quickstart.md)
* What Keep guarantees: [https://github.com/jmngshi0106-wq/keep-releases/blob/main/docs/guarantees.md](https://github.com/jmngshi0106-wq/keep-releases/blob/main/docs/guarantees.md)
* How Keep fails: [https://github.com/jmngshi0106-wq/keep-releases/blob/main/docs/how-keep-fails.md](https://github.com/jmngshi0106-wq/keep-releases/blob/main/docs/how-keep-fails.md)
