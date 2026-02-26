# Keep

Keep is a **secure-by-default, RLS-first multi-tenant layer** for Supabase/Postgres; this repo is a **public release mirror** (the source repository is private).

Start here: run the Install → Verify → Demo steps below (they match `docs/quickstart.md`), then confirm PASS with the checklist.

**Pricing / Purchase (License + 12-month updates):** [docs/pricing.md](docs/pricing.md)

**Commercial terms (authoritative):** [docs/commercial-contract.md](docs/commercial-contract.md)

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

## 4) See what Keep installed (Studio + Editor)

If you only trust what you can see, here’s the “show me the artifact” step.

### A) Supabase Studio (local)

Open Studio:
- http://127.0.0.1:54323

Then:
- Go to **Table Editor** → confirm the Keep tables exist (e.g. `organizations`, `organization_members`, `projects`).
- Confirm **RLS is enabled** on those tables and policies exist (default-deny + explicit allow rules).

### B) Your editor (Cursor / VS Code)

Open the folder where you ran `keep init` and inspect what Keep scaffolded:
- `db/migrations/` (schema + RLS + helpers)
- `db/tests/` (pgTAP proof)
- `db/seeds/` (deterministic seed)

---

## PASS criteria checklist (stranger-friendly)

* [ ] **Install**: run the install block; `keep version` exits successfully.
* [ ] **Verify** (your platform): run the sha256 block; the check command exits **0**.
* [ ] **Demo**: run the one-command demo block.
* [ ] **PASS**: output includes: `✓ Test run complete.`

---

## More docs

* Guarantees: `docs/guarantees.md`
* How Keep fails: `docs/how-keep-fails.md`
