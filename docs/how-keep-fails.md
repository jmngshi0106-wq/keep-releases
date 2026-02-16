# How Keep Fails (and What It Means)

Keep fails loudly on purpose.

A failure is either:
- **refusal** (missing / unclear authority), or
- **honest environment truth** (the world isn’t in the required state).

This page is operator-facing: common failure patterns, what they usually mean, and how to confirm safely.

---

## 0) First rule: read the first error

If you see multiple errors, the **first** one is usually the real cause.
Everything after can be noise (especially inside transactions).

---

## 1) Docker is not running

**Symptom**
- You see `Error: Docker is not running.`

**Meaning**
- Supabase local cannot start because Docker is the substrate.

**Confirm**
```bash
docker ps
supabase status
```

**Fix**

* Start Docker Desktop, then re-run the command.

---

## 2) Supabase local not running (init refuses)

**Symptom**

* `keep init` refuses because Supabase is not running.

**Meaning**

* Keep’s bootstrap expects a live DB because init scaffolds and applies migrations.

**Confirm**

```bash
supabase status
```

**Fix**

```bash
supabase start
keep init
```

(See `docs/quickstart.md`.)

---

## 3) Project contract missing: `.keep/keep_version`

**Symptom**

* Guarded commands refuse (migrate/seed/test) because `.keep/keep_version` is missing.

**Meaning**

* The project does not declare compatibility with the CLI version. Keep refuses rather than guessing.

**Confirm**

```bash
ls -la .keep
cat .keep/keep_version
keep version
```

**Fix**

* Follow `docs/upgrade.md` (project-local upgrade steps).

---

## 4) JWT claim missing: `"request.jwt.claim.sub"` is NULL/empty

**Symptom**

* RLS denies everything (often “no rows visible”, inserts fail, or policies behave like you’re “nobody”).

**Meaning**

* Postgres does not know “app users”. Identity flows from the JWT `sub` claim.
* If the claim is missing, helpers resolve NULL and RLS must deny.

**Confirm**
Run this under the role you’re testing with (not superuser):

```sql
SELECT current_setting('request.jwt.claim.sub', true);
```

**Fix**

* Ensure the transaction/session sets the claim correctly for tests.
* Ensure your application/JWT pipeline is actually supplying `sub`.

(See `docs/rls-cheatsheet.md`.)

---

## 5) You tested as a superuser (and got lied to)

**Symptom**

* Everything “works” as `postgres`, but fails in reality.

**Meaning**

* Superusers can bypass RLS. Testing as superuser is testing nothing.

**Confirm**

* Check which DB role you are using.
* In Keep’s proof loop, tests must run as the non-superuser test role (e.g. `keep_tester`).

**Fix**

* Re-run tests through `keep test` (or in pgTAP using the non-superuser role).

(See `docs/rls-cheatsheet.md`.)

---

## 6) Service role pitfalls (RLS bypass risk)

**Symptom**

* You are using a “service role” credential and RLS behavior is surprising.

**Meaning**

* Some privileged roles can bypass RLS depending on how your database and roles are configured.
* Keep cannot guess your role semantics. You must verify what your “service role” actually does in your environment.

**Confirm**

* Identify the DB role used by your service credential.
* Verify whether RLS is being enforced for that role by running the same query path as a normal client role and comparing results.

**Fix**

* Do not rely on privileged credentials for application paths that require RLS enforcement.
* Treat privileged roles as administrative tooling, not user-facing access paths.

---

## 7) JWT issuer mismatch (`issuer` problems)

**Symptom**

* Your app thinks it is authenticated, but the database sees missing/invalid claims (or the token is rejected upstream).

**Meaning**

* If the JWT issuer configuration is wrong, claims may not be what you think they are (or tokens may not be accepted).

**Confirm**

* Inspect the token’s issuer (`iss`) and compare it to your configured expected issuer in your auth pipeline.
* Confirm the database session actually receives a `sub` claim.

**Fix**

* Correct the issuer configuration in your auth provider / application.
* Re-test by confirming `request.jwt.claim.sub` is present.

---

## 8) Treat “fatal refusals” as product failure

**Symptom**

* The CLI reports a fatal refusal / invariant violation / nondeterminism.

**Meaning**

* This indicates broken system truth. User action should not be required to “make it safe”.

**Response**

* Stop. Do not proceed by retrying blindly.
* Capture the exact output and file evidence, and treat it as a bug.

(See `docs/command-risk.md`.)
