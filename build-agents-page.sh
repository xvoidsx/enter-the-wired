#!/usr/bin/env bash
# build-agents-page.sh — render the navi repo's AGENTS.md into agents.html.
#
# The repo file is the source of truth; this page is a mirror. Re-run this
# script after every AGENTS.md change and push the result.
set -euo pipefail

SRC_URL="https://raw.githubusercontent.com/xvoidsx/navi/main/AGENTS.md"
OUT="$(cd "$(dirname "$0")" && pwd)/agents.html"

# persistent python deps (markdown) — site builds need them across VM restarts
export PYTHONPATH="$(cd "$(dirname "$0")/../.pydeps" && pwd):${PYTHONPATH:-}"

python3 - "$SRC_URL" "$OUT" <<'PYEOF'
import sys, urllib.request, html as htmllib
import markdown

src_url, out = sys.argv[1], sys.argv[2]
with urllib.request.urlopen(src_url) as r:
    text = r.read().decode("utf-8")

# Drop the markdown's own h1 — the page template supplies the header.
lines = text.split("\n")
if lines and lines[0].startswith("# "):
    lines = lines[1:]
body = markdown.markdown("\n".join(lines).strip(),
                         extensions=["fenced_code", "tables"])

page = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="icon" href="assets/favicon.svg" type="image/svg+xml">
<meta name="description" content="How navi gets built — the project's shared handbook for agents and humans, rendered from AGENTS.md.">
<title>agents — navi</title>
<style>
  :root {
    --bg: #060309;
    --panel: #0d0710;
    --pink: #ff10f0;
    --green: #39ff14;
    --cyan: #00e5ff;
    --paper: #f2e9f4;
    --muted: #9a8fa0;
    --line: rgba(255,16,240,.22);
  }
  * { box-sizing: border-box; }
  body {
    margin: 0; background: var(--bg); color: var(--paper);
    font: 16px/1.65 system-ui, -apple-system, "Segoe UI", sans-serif;
    -webkit-font-smoothing: antialiased;
  }
  a { color: var(--pink); }
  a:visited { color: var(--green); }
  .wrap { max-width: 760px; margin: 0 auto; padding: 48px 24px 80px; }
  .kicker { color: var(--green); font-size: 12px; letter-spacing: .28em; margin: 0 0 12px; }
  h1 { font-size: clamp(40px, 7vw, 72px); line-height: .95; margin: 0 0 8px; letter-spacing: -.02em; }
  h1 span { color: var(--pink); }
  .lede { color: var(--muted); max-width: 600px; margin: 0 0 16px; }
  .srcnote { font-size: 13px; color: var(--muted); margin: 0 0 48px; padding: 12px 18px;
             border: 1px dashed var(--line); border-radius: 10px; background: rgba(255,16,240,.04); }
  .doc h2 { color: var(--pink); font-size: clamp(22px, 3.4vw, 30px); letter-spacing: -.01em;
            margin: 48px 0 16px; padding-top: 32px; border-top: 1px solid var(--line); }
  .doc h2:first-child { margin-top: 0; padding-top: 0; border-top: 0; }
  .doc p, .doc li { color: var(--muted); font-size: 15px; }
  .doc p strong, .doc li strong { color: var(--paper); font-weight: 600; }
  .doc p { margin: 0 0 14px; }
  .doc ul { padding-left: 20px; margin: 0 0 16px; }
  .doc li { margin: 8px 0; }
  .doc li ul { margin: 8px 0 0; }
  .doc blockquote { margin: 0 0 24px; padding: 16px 20px; border-left: 3px solid var(--pink);
                    background: var(--panel); border-radius: 0 10px 10px 0; }
  .doc blockquote p { color: var(--paper); margin: 0; font-size: 15px; }
  .doc blockquote strong { color: var(--pink); }
  .doc code { color: var(--pink); font-size: .88em; background: rgba(255,16,240,.08);
              padding: 1px 6px; border-radius: 5px; }
  .doc pre { background: #0a050d; border: 1px solid var(--line); border-radius: 10px;
             padding: 18px 20px; overflow-x: auto; margin: 0 0 18px; }
  .doc pre code { color: var(--green); background: none; padding: 0; font-size: 13px; }
  nav.top { margin: 0 0 48px; font-size: 14px; }
  nav.top a { margin-right: 18px; text-decoration: none; }
  nav.top a:hover { text-decoration: underline; }
  nav.top .active {
    color: var(--pink);
    border: 1px solid var(--line);
    border-radius: 999px;
    padding: 3px 12px;
    margin-right: 18px;
    background: rgba(255,16,240,.08);
    text-shadow: 0 0 10px rgba(255,16,240,.9), 0 0 28px rgba(255,16,240,.45);
    box-shadow: 0 0 12px rgba(255,16,240,.25), inset 0 0 8px rgba(255,16,240,.12);
    white-space: nowrap;
  }
  footer .active {
    color: var(--pink);
    border: 1px solid var(--line);
    border-radius: 999px;
    padding: 3px 12px;
    background: rgba(255,16,240,.08);
    text-shadow: 0 0 10px rgba(255,16,240,.9), 0 0 28px rgba(255,16,240,.45);
    box-shadow: 0 0 12px rgba(255,16,240,.25), inset 0 0 8px rgba(255,16,240,.12);
    white-space: nowrap;
  }
  footer { margin-top: 64px; padding-top: 24px; border-top: 1px solid var(--line);
           color: var(--muted); font-size: 13px; display: flex; gap: 18px; flex-wrap: wrap; }
  footer a { text-decoration: none; }
  footer a:hover { text-decoration: underline; }
  @media (max-width: 560px) { .wrap { padding: 32px 18px 64px; } }
</style>
</head>
<body>
<div class="wrap">
  <nav class="top" aria-label="Site">
    <a href="index.html">&larr; navi</a>
    <a href="news.html">news</a>
    <a href="roadmap.html">roadmap</a>
    <a href="manual/manual.html">manual</a>
    <a href="sponsors.html">sponsors</a>
    <a href="labs.html">labs</a>
    <a href="community.html">community</a>
    <span class="active" aria-current="page">agents</span>
  </nav>

  <p class="kicker">NAVI // AGENTS.MD</p>
  <h1>how we build <span>navi.</span></h1>
  <p class="lede">The project's shared brain — conventions, release process, and hard-won rules — written for agents and humans alike. Read it and hit the ground running.</p>
  <p class="srcnote">Mirrored from <a href="https://github.com/xvoidsx/navi/blob/main/AGENTS.md">AGENTS.md</a> in the navi repo. The repo copy is the source of truth.</p>

  <div class="doc">
""" + body + """
  </div>

  <footer>
    <span>navi / wired / nightshadeNeon</span>
    <a href="index.html">home</a>
    <a href="news.html">news</a>
    <a href="roadmap.html">roadmap</a>
    <a href="manual/manual.html">manual</a>
    <a href="sponsors.html">sponsors</a>
    <a href="labs.html">labs</a>
    <a href="community.html">community</a>
    <span class="active" aria-current="page">agents</span>
    <span>built with care by <a href="https://github.com/xvoidsx">xvoidsx</a></span>
  </footer>
</div>
</body>
</html>
"""

with open(out, "w") as f:
    f.write(page)
print("wrote", out)
PYEOF
