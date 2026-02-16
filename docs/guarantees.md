# What Keep Guarantees

Keep is infrastructure. It guarantees **certain mechanical properties** and explicitly refuses to guarantee everything else.

This page is an index of guarantees and trust boundaries. Each section points to the normative source document.

---

## 1) Supply-chain boundary (install / promotion)

**Keep guarantees:**

- The official install path is a **GitHub Release asset** installer (not `raw/main`).
- Installation verifies checksums and writes an installation **receipt**.
- Unsafe overwrite is refused by default.

Normative doc: `docs/promotion-doctrine.md`

---

## 2) Determinism boundary (CI witness)

**Keep guarantees:**

- CI is a witness: it checks determinism and correct refusal behavior.
- The CI gate runs against **source** and against a compiled **artifact** and fails if behavior diverges.

Normative doc: `docs/ci-gate.md`

---

## 3) RLS boundary (shared schema, row isolation)

**Keep guarantees (mechanical):**

- RLS is enabled on canonical tables.
- Helper functions exist and are callable.
- Policies exist (not that they are correct).
- Tests can run under real RLS constraints.

**Keep does not guarantee:**

- Business correctness of policies.
- Completeness of access rules.
- Absence of overly-permissive policies.
- Safety of custom helpers.
- Semantic correctness of roles.

Normative doc: `docs/rls-cheatsheet.md`

---

## 4) Refusal boundary (command risk doctrine)

**Keep guarantees:**

- Refusal is proportional to command risk.
- Diagnostic commands remain usable even when contracts are broken.
- Mutating / authority-sensitive commands refuse on unclear authority.

Normative doc: `docs/command-risk.md`

---

## 5) Upgrade boundary (project-local contracts)

**Keep guarantees:**

- Projects are not auto-upgraded.
- When project contracts are missing or incompatible, guarded commands refuse.
- Upgrades are explicit, versioned, and reviewable.

Normative doc: `docs/upgrade.md`
