# enter the wired

the source for navi's website — hub, docs, manual, news, and more.

## structure

```
index.html      the landing page (stable-era hero, download links, roadmap section)
roadmap.html    where navi is headed: mika → 1.2.1 → eiri
news.html       navi news, newest first
manual/         the built-in manual, web edition (mirrors wired/manual in xvoidsx/navi)
assets/         images and media for the landing page
```

## how it works

plain static html. no build step, no framework, no bundler — push and serve.

- `index.html` is the full landing page (styles are inline).
- `roadmap.html` and `news.html` are standalone pages in the same visual language.
- `manual/` must stay **simple, semantic html** — it's the same source that ships
  inside navi at `/usr/share/navi/wired/manual`, and it has to render clean in
  terminal browsers (elinks/lynx). any visual effects are progressive enhancement
  only: css the terminal ignores, never structure it needs.

## updating

- **news**: add a new `<article class="post">` to the top of `news.html`.
- **manual**: edit the pages in `xvoidsx/navi`'s `wired/manual/` first (that's the
  canonical copy), then copy them over here so the two stay in sync.
- **roadmap**: edit `roadmap.html` directly.

## deployment

Raven takes it live from here onto xvoidsx's own infra when it's ready.
