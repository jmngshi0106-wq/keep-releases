# Keep v0.1.14 — Launch Spine (Install → Verify → Demo → PASS)

This file is a **release-notes template**.

**Rule:** The canonical blocks (**Install / Verify / Demo**) in a Release **must be copied verbatim** from `docs/quickstart.md`.
If they differ, the Release Gate CI will fail.

---

## Prerequisites

* Supabase CLI installed (`supabase`)
* Docker running

---

## 1) Install (global, official)

Keep’s official installer URL is the **GitHub Release asset** (not `raw/main`):

```
curl -fsSL -L https://github.com/jmngshi0106-wq/keep-releases/releases/latest/download/install.sh | sudo bash
keep version
```
2) Verify the v0.1.14 release tarball (sha256)
macOS (darwin-arm64)
```
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/v0.1.14/keep-0.1.14-darwin-arm64.tar.gz
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/v0.1.14/keep-0.1.14-darwin-arm64.tar.gz.sha256
shasum -a 256 -c keep-0.1.14-darwin-arm64.tar.gz.sha256
```
Linux (x86_64)
```
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/v0.1.14/keep-0.1.14-linux-x86_64.tar.gz
curl -fsSL -LO https://github.com/jmngshi0106-wq/keep-releases/releases/download/v0.1.14/keep-0.1.14-linux-x86_64.tar.gz.sha256
sha256sum -c keep-0.1.14-linux-x86_64.tar.gz.sha256
```
3) Demo (one copy/paste command)

This creates a fresh temp workspace, starts Supabase local, and runs the proof loop.

bash -lc 'set -euo pipefail; tmp="$(mktemp -d)"; cd "$tmp"; mkdir keep-project && cd keep-project; supabase init; supabase start; keep init; keep seed; keep test'

On success, you should see:
✓ Test run complete.

PASS criteria checklist (stranger-friendly)

 Install: run the install block; keep version exits successfully.

 Verify (your platform): run the sha256 block; the check command exits 0.

 Demo: run the one-command demo block.

 PASS: output includes: ✓ Test run complete.

Docs (public)

Quickstart: https://github.com/jmngshi0106-wq/keep-releases/blob/main/docs/quickstart.md

What Keep guarantees: https://github.com/jmngshi0106-wq/keep-releases/blob/main/docs/guarantees.md

How Keep fails: https://github.com/jmngshi0106-wq/keep-releases/blob/main/docs/how-keep-fails.md
