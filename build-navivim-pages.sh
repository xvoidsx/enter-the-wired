#!/usr/bin/env bash
# build-navivim-pages.sh — build the NaviVim section of the site.
#
# Builds three pages:
#   navivim.html          — the product page (hand-written below)
#   navivim-handbook.html — mirror of NaviVim's HANDBOOK.md (repo = source of truth)
#   navivim-agents.html   — mirror of NaviVim's AGENTS.md   (repo = source of truth)
#
# Re-run after every NaviVim doc change and push the result.
set -euo pipefail

cd "$(dirname "$0")"

# persistent python deps (markdown) — site builds need them across VM restarts
export PYTHONPATH="$(cd "$(dirname "$0")/../.pydeps" && pwd):${PYTHONPATH:-}"

NAV_HEAD='  <nav class="top" aria-label="Site">
    <a href="index.html">&larr; navi</a>
    <a href="news.html">news</a>
    <a href="roadmap.html">roadmap</a>
    <a href="manual/manual.html">manual</a>
    <a href="sponsors.html">sponsors</a>
    <a href="labs.html">labs</a>
    <a href="community.html">community</a>
    <a href="agents.html">agents</a>
    <span class="active" aria-current="page">navivim</span>
  </nav>'

NAV_FOOT='  <footer>
    <span>navi / wired / nightshadeNeon</span>
    <a href="index.html">home</a>
    <a href="news.html">news</a>
    <a href="roadmap.html">roadmap</a>
    <a href="manual/manual.html">manual</a>
    <a href="sponsors.html">sponsors</a>
    <a href="labs.html">labs</a>
    <a href="community.html">community</a>
    <a href="agents.html">agents</a>
    <span class="active" aria-current="page">navivim</span>
    <span>built with care by <a href="https://github.com/xvoidsx">xvoidsx</a></span>
  </footer>'

export NAV_HEAD NAV_FOOT

python3 - <<'PYEOF'
import os, urllib.request
import markdown

HEAD = os.environ["NAV_HEAD"]
FOOT = os.environ["NAV_FOOT"]

CSS = """  :root {
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
  .doc table { width: 100%; border-collapse: collapse; margin: 0 0 18px; font-size: 14px; }
  .doc th { text-align: left; color: var(--green); font-weight: 600; font-size: 12px;
            letter-spacing: .12em; text-transform: uppercase; padding: 10px 12px;
            border-bottom: 1px solid var(--line); }
  .doc td { color: var(--muted); padding: 10px 12px; border-bottom: 1px solid rgba(255,16,240,.1);
            vertical-align: top; }
  .doc td code { white-space: nowrap; }
  .doc hr { border: 0; border-top: 1px solid var(--line); margin: 40px 0; }
  .shot { margin: 0 0 48px; border: 1px solid var(--line); border-radius: 12px; overflow: hidden;
          background: var(--panel); }
  .shot img { display: block; width: 100%; height: auto; }
  .shot figcaption { padding: 14px 20px; color: var(--muted); font-size: 13px; }
  .cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
           gap: 12px; margin: 0 0 16px; }
  .card { border: 1px solid var(--line); border-radius: 12px; padding: 20px; background: var(--panel);
          text-decoration: none; display: block; }
  .card:hover { border-color: var(--pink); }
  .card h3 { margin: 0 0 8px; color: var(--paper); font-size: 17px; }
  .card p { margin: 0; color: var(--muted); font-size: 13px; }
  .card .go { color: var(--pink); font-size: 13px; }
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
  @media (max-width: 560px) { .wrap { padding: 32px 18px 64px; } }"""

def page(title, desc, kicker, h1, lede, srcnote, body_html):
    return """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="icon" href="assets/favicon.svg" type="image/svg+xml">
<meta name="description" content="%s">
<title>%s</title>
<style>
%s
</style>
</head>
<body>
<div class="wrap">
%s

  <p class="kicker">%s</p>
  <h1>%s</h1>
  <p class="lede">%s</p>
  <p class="srcnote">%s</p>

  <div class="doc">
%s
  </div>

%s
</div>
</body>
</html>
""" % (desc, title, CSS, HEAD, kicker, h1, lede, srcnote, body_html, FOOT)

def mirror(src_url, out, title, desc, kicker, h1, lede, srcnote, link_fixes=()):
    with urllib.request.urlopen(src_url) as r:
        text = r.read().decode("utf-8")
    lines = text.split("\n")
    if lines and lines[0].startswith("# "):
        lines = lines[1:]
    body = markdown.markdown("\n".join(lines).strip(),
                             extensions=["fenced_code", "tables"])
    for old, new in link_fixes:
        body = body.replace(old, new)
    with open(out, "w") as f:
        f.write(page(title, desc, kicker, h1, lede, srcnote, body))
    print("wrote", out)

REPO = "https://github.com/xvoidsx/navivim"
RAW = "https://raw.githubusercontent.com/xvoidsx/navivim/main"

mirror(RAW + "/HANDBOOK.md", "navivim-handbook.html",
       title="NaviVim handbook — navi",
       desc="The NaviVim user guide: from zero to comfortable in your in-terminal IDE.",
       kicker="NAVI // NAVIVIM HANDBOOK",
       h1="the <span>handbook.</span>",
       lede="Your in-terminal IDE, from zero to comfortable. Close the world. Open the Wired.",
       srcnote='Mirrored from <a href="%s/blob/main/HANDBOOK.md">HANDBOOK.md</a> in the NaviVim repo. The repo copy is the source of truth.' % REPO,
       link_fixes=[("<code>~/AGENTS.md</code>",
                    '<a href="navivim-agents.html">the NaviVim AGENTS.md</a>')])

mirror(RAW + "/AGENTS.md", "navivim-agents.html",
       title="NaviVim for agents — navi",
       desc="The NaviVim contract for contributors and AI agents: layout, keymaps, packaging, rules.",
       kicker="NAVI // NAVIVIM FOR AGENTS",
       h1="the <span>contract.</span>",
       lede="The rules of the road for anyone — human or agent — working on NaviVim itself.",
       srcnote='Mirrored from <a href="%s/blob/main/AGENTS.md">AGENTS.md</a> in the NaviVim repo. The repo copy is the source of truth.' % REPO)

# ---- the product page (hand-written) ----
product = """
<figure class="shot">
  <img src="assets/navivim-dashboard.png" alt="NaviVim dashboard: neon logo, shortcut menu, file explorer">
  <figcaption>The NaviVim dashboard — neon logo, shortcut menu, file explorer. The real thing, running on navi.</figcaption>
</figure>

<h2>What it is</h2>
<p><strong>NaviVim is the in-terminal IDE for Navi Linux</strong> — hand-rolled Neovim, no distro framework. Just <code>lazy.nvim</code> and one file per feature. Its ambition is a premier, best-in-class Neovim experience that feels like a cohesive whole with the system it ships on.</p>
<ul>
  <li><strong>Welcoming, not dumbed down.</strong> Built for newcomers arriving from VSCode <em>and</em> veterans — discoverable over memorizable, with leader-key menus, which-key popups, and a tip of the day.</li>
  <li><strong>Editor-first, tmux-enhanced.</strong> Fully usable standalone; shines inside tmux, and the two navigate as one.</li>
  <li><strong>nightshadeNeon throughout.</strong> Neon pink, phosphor green, cyan on black — the house colorscheme, with transparency that actually works.</li>
</ul>
<p>Leader is <strong>Space</strong> — tapped in sequence, never held. Stuck anywhere? Tap Space and wait half a second: a menu shows every shortcut available from there. You never have to memorize.</p>

<h2>The 30-second tour</h2>
<table>
  <tr><th>Keys</th><th>What</th></tr>
  <tr><td><code>Ctrl+n</code> / <code>Space e</code></td><td>File explorer sidebar</td></tr>
  <tr><td><code>Space ua</code></td><td>Autocomplete on/off</td></tr>
  <tr><td><code>/</code> then <code>Esc</code></td><td>Search in file, clear highlight</td></tr>
  <tr><td><code>Space ff</code> / <code>Space fg</code></td><td>Find files / grep project</td></tr>
  <tr><td><code>Space</code> then wait</td><td>which-key shows everything</td></tr>
</table>

<h2>Install</h2>
<p>On a Debian base today; shipping as navi's default editor from the get-go in <strong>navi 1.5 &ldquo;mika&rdquo; — the NaviVim update</strong>.</p>
<pre><code>git clone https://github.com/xvoidsx/navivim ~/NaviVim
cd ~/NaviVim
./install.sh              # full setup: apt deps, Neovim 0.11+, plugins
./install.sh --no-apt     # skip apt (deps already present)
./install.sh --system     # navi distro installer (as root): system-wide
                          # install, /etc/skel seed, default editor</code></pre>
<p>The script installs Neovim from the upstream release tarball (Debian stable's 0.10 is too old), links the repo to <code>~/.config/nvim</code>, seeds the nightshadeNeon theme, and syncs plugins headlessly. Language servers and formatters install via <code>:Mason</code> on first launch.</p>

<h2>One file per feature</h2>
<p>No framework distro underneath — every plugin is chosen on purpose, each in its own <code>lua/plugins/*.lua</code> file: sidebar, completion, search, LSP, treesitter, UI, git, editing, terminal, theme. The whole config stays readable enough to learn from. Plugin versions are pinned in <code>lazy-lock.json</code> for reproducible builds.</p>

<h2>Docs</h2>
<div class="cards">
  <a class="card" href="navivim-handbook.html">
    <h3>Handbook</h3>
    <p>The user guide — from zero to comfortable.</p>
    <span class="go">Read the handbook &rarr;</span>
  </a>
  <a class="card" href="navivim-agents.html">
    <h3>For agents</h3>
    <p>The contract: layout, keymaps, packaging, rules.</p>
    <span class="go">Read the contract &rarr;</span>
  </a>
  <a class="card" href="https://github.com/xvoidsx/navivim">
    <h3>Repository</h3>
    <p>Source, issues, and the install script.</p>
    <span class="go">xvoidsx/navivim &nearr;</span>
  </a>
</div>
"""

with open("navivim.html", "w") as f:
    f.write(page(
        title="NaviVim — navi",
        desc="NaviVim: the in-terminal IDE for Navi Linux. Hand-rolled Neovim, one file per feature.",
        kicker="NAVI // NAVIVIM",
        h1="the in-terminal <span>IDE.</span>",
        lede="Hand-rolled Neovim — no distro framework, just lazy.nvim and one file per feature. Navi's default editor.",
        srcnote='Free and open source: <a href="%s">xvoidsx/navivim</a>.' % REPO,
        body_html=product))
print("wrote navivim.html")
PYEOF
