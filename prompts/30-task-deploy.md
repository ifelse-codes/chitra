# Session 30 — task: host the docs site on chitra.iifelse.com (Cloudflare Pages)

Founder direction (in-chat, S30): host the website — the `chitra-docs`
catalog app — on `chitra.iifelse.com`. Zone `iifelse.com` lives in
Cloudflare; do it with the Cloudflare CLI (`wrangler`, already authed).

## Numbered requirements

1. **Pages project via CLI.** A Cloudflare Pages project named `chitra`
   (production branch `main`, direct-upload like `antra`/`kreeda` —
   no Git integration), created with `wrangler`.
2. **Deploy the built docs site.** Production build of
   `@workspace/chitra-docs` (`PORT=5174 BASE_PATH=/`) deployed from
   `artifacts/chitra-docs/dist/public` with `wrangler pages deploy`.
3. **Custom domain live.** `chitra.iifelse.com` attached to the project
   as a custom domain, DNS `CNAME chitra → <project>.pages.dev`
   (proxied) resolving to the Cloudflare edge, domain status `active`
   with verification `active`.
4. **SPA deep links work.** Client-side routes (`/chart/:id`, `/install`,
   …) load on direct visit — a `public/_redirects` SPA fallback
   (`/* /index.html 200`) shipped inside the deployed `dist/`.
5. **Gates.** `scripts/verify-session-30.sh` green (redirects in
   public + dist, docs build, Pages project present);
   `scripts/demo-session-30.sh` green (project, domain, deploy dir).
6. **Proven live in a real browser.** The custom domain renders the docs
   home in an external browser; the `*.pages.dev` URL loads as control.
