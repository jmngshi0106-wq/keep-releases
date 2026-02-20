#!/usr/bin/env python3
import json
import os
import re
import sys
import urllib.request
import urllib.error

def die(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)

def info(msg: str) -> None:
    print(msg)

def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def normalize(s: str) -> str:
    s = s.replace("\r\n", "\n").replace("\r", "\n")
    s = "\n".join(line.rstrip() for line in s.split("\n"))
    return s

def extract_section(md: str, start_re: str, end_re: str) -> str:
    ms = re.search(start_re, md, flags=re.MULTILINE)
    if not ms:
        die(f"quickstart parse failed: missing section start: {start_re}")
    tail = md[ms.end():]
    me = re.search(end_re, tail, flags=re.MULTILINE)
    if not me:
        die(f"quickstart parse failed: missing section end: {end_re}")
    return tail[:me.start()]

def fenced_blocks(md_fragment: str) -> list[str]:
    return re.findall(r"```[^\n]*\n.*?\n```", md_fragment, flags=re.DOTALL)

def github_get_json(url: str, token: str) -> dict:
    req = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "User-Agent": "keep-release-gate",
        },
        method="GET",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.loads(r.read().decode("utf-8", errors="replace"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        die(f"GitHub API error {e.code} for {url}: {body[:400]}")

def main() -> None:
    token = (os.environ.get("GITHUB_TOKEN") or "").strip()
    if not token:
        die("GITHUB_TOKEN is missing")

    repo = (os.environ.get("GITHUB_REPOSITORY") or "").strip()
    if not repo:
        die("GITHUB_REPOSITORY is missing")

    event_path = (os.environ.get("GITHUB_EVENT_PATH") or "").strip()
    if not event_path:
        die("GITHUB_EVENT_PATH is missing")

    event = json.loads(read_text(event_path))
    release = event.get("release") or {}
    tag = (release.get("tag_name") or "").strip()
    if not tag:
        die("Cannot determine release tag_name from event payload")

    version = tag[1:] if tag.startswith("v") else tag

    api = f"https://api.github.com/repos/{repo}/releases/tags/{tag}"
    rel = github_get_json(api, token)
    body = rel.get("body") or ""
    assets = rel.get("assets") or []

    info(f"Release gate target: repo={repo} tag={tag} version={version}")
    info(f"Release URL: {rel.get('html_url')}")
    info(f"Assets count: {len(assets)}")

    required_assets = [
        "install.sh",
        "install.sh.sha256",
        f"keep-{version}-darwin-arm64.tar.gz",
        f"keep-{version}-darwin-arm64.tar.gz.sha256",
        f"keep-{version}-linux-x86_64.tar.gz",
        f"keep-{version}-linux-x86_64.tar.gz.sha256",
    ]
    present = {a.get("name", "") for a in assets}
    missing = [name for name in required_assets if name not in present]
    if missing:
        die("Missing required release assets:\n  - " + "\n  - ".join(missing))

    if not body.strip():
        die("Release notes body is empty")

    qs_path = os.path.join("docs", "quickstart.md")
    if not os.path.exists(qs_path):
        die(f"Missing canonical source file: {qs_path}")

    quickstart = normalize(read_text(qs_path))
    body_n = normalize(body)

    install_section = extract_section(
        quickstart,
        r"^## 1\)\s+Install\b.*$",
        r"^## 2\)\s+Verify\b.*$",
    )
    verify_section = extract_section(
        quickstart,
        r"^## 2\)\s+Verify\b.*$",
        r"^## 3\)\s+Demo\b.*$",
    )
    demo_section = extract_section(
        quickstart,
        r"^## 3\)\s+Demo\b.*$",
        r"^##\s+|^\Z",
    )

    install_blocks = fenced_blocks(install_section)
    verify_blocks = fenced_blocks(verify_section)
    demo_blocks = fenced_blocks(demo_section)

    if len(install_blocks) < 1:
        die("quickstart parse failed: no Install fenced code block found")
    if len(verify_blocks) < 2:
        die("quickstart parse failed: expected 2 Verify fenced code blocks (mac + linux)")
    if len(demo_blocks) < 1:
        die("quickstart parse failed: no Demo fenced code block found")

    canonical_blocks = [
        normalize(install_blocks[0]),
        normalize(verify_blocks[0]),
        normalize(verify_blocks[1]),
        normalize(demo_blocks[0]),
    ]

    missing_blocks = [b for b in canonical_blocks if b not in body_n]
    if missing_blocks:
        die(
            "Release notes missing required canonical block(s) copied verbatim from docs/quickstart.md.\n"
            "Missing blocks (verbatim expected):\n\n"
            + "\n\n---\n\n".join(missing_blocks)
        )

    expected_verify_strings = [
        f"/releases/download/{tag}/keep-{version}-darwin-arm64.tar.gz",
        f"/releases/download/{tag}/keep-{version}-darwin-arm64.tar.gz.sha256",
        f"/releases/download/{tag}/keep-{version}-linux-x86_64.tar.gz",
        f"/releases/download/{tag}/keep-{version}-linux-x86_64.tar.gz.sha256",
    ]
    for s in expected_verify_strings:
        if s not in body_n:
            die(f"Release notes Verify section does not reference expected tag/version string: {s}")

    info("PASS: release gate satisfied (assets present + notes contain canonical Install/Verify/Demo blocks).")

if __name__ == "__main__":
    main()
