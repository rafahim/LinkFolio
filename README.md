# LinkFolio

LinkFolio is a free, self-hostable link-in-bio page built with HTML, CSS, vanilla JavaScript, and `config.json`. It has no build step, no required package manager, no ads, and no third-party analytics. It can be opened as a local file or served as a static site.

## Quick deploy

These links open each host's deployment flow. For an automated repository import, first push this folder to your own Git repository.

[![Deploy to Netlify](https://www.netlify.com/img/deploy/button.svg)](https://app.netlify.com/drop)

[![Deploy to Vercel](https://vercel.com/button)](https://vercel.com/new)

[![Deploy with GitHub Pages](https://img.shields.io/badge/Deploy-GitHub%20Pages-222?logo=github)](https://pages.github.com/)

## Features

- Responsive, mobile-first profile with avatar, name, bilingual bio, tags, links, share tools, and color mode toggle.
- Auto-detected icons for YouTube, GitHub, Twitter/X, Instagram, Facebook, LinkedIn, email, WhatsApp, phone, and custom URLs.
- Offline QR generation and SVG download. It does not call an external QR service.
- Optional YouTube embed, loaded from `youtube-nocookie.com` only after the visitor clicks to load it.
- Newsletter signup handoff using the visitor's email application. This is not a mailing list service.
- English and Bengali UI labels.
- Admin page with link CRUD, drag-reordering, profile editor, appearance controls, SEO fields, profile management, preview, import/export, and local analytics.
- Multiple profiles with `?user=profile-id` routing.
- SEO metadata, canonical URL, Open Graph, Twitter Card, JSON-LD, `robots.txt`, `sitemap.xml`, manifest, security contact, favicon, and OG image.
- Static deploy configuration for Netlify, Vercel, and Docker/Nginx.

## Run locally

1. Extract the project ZIP, if you downloaded it.
2. Open `index.html` directly in a modern browser to view the bundled sample profile.
3. Open `admin.html` to edit links, profile details, theme, or SEO fields.
4. Use **Export config** to download your edited configuration as `config.json`.
5. Replace the project's `config.json` with the exported file to publish your changes.
6. For reliable loading of `config.json` and shared browser storage, serve the folder over HTTP instead of opening a `file://` URL.
7. With Python installed, run `python -m http.server 8080` from this directory.
8. Visit `http://localhost:8080/` for the public page and `http://localhost:8080/admin.html` for the editor.
9. To view a different profile, add `?user=profile-id` and create that profile in the admin first.
10. Before deploying, review `config.json`, SEO files, and the limitations below.

## Self-host guide

### Static server

Copy the project folder to the document root of any static web host. No build command is required. Preserve the `data/` and `.well-known/` folders. If the project is hosted below a subpath, update the canonical URLs and sitemap entries for that path before deployment.

### Docker

Run `docker compose up -d` from this directory and open `http://localhost:8080`. The container mounts the project read-only into Nginx.

### Netlify

Import the repository or use Netlify Drop. The included `netlify.toml` sets the project root as the publish directory. No build command is needed.

### Vercel

Import the repository in Vercel. The included `vercel.json` configures static headers and leaves the files at the root. No build command is needed.

### GitHub Pages

Push this folder to a repository, open **Settings → Pages**, select the branch and root folder, then save. GitHub Pages serves the static files directly. Confirm your canonical URL matches the deployed location.

## Admin and persistence model

The admin page is a browser-side editor, not a protected server application. It stores edits in `localStorage` when the browser allows it and offers JSON export/import. Static HTML and JavaScript cannot rewrite `config.json` on the host. To publish changes, export `config.json`, replace the file in your repository, and redeploy. If the browser blocks `localStorage` or `fetch` for `file://` URLs, use the bundled sample profile or start a local HTTP server.

The analytics dashboard records link clicks locally in the same browser. Events contain a profile ID, link ID, and timestamp only. There is no server endpoint, cross-visitor analytics, fingerprinting, cookie, ad network, or third-party analytics. `data/analytics.json` is a sample export shape; static browser JavaScript cannot append events to that file. Export local analytics from the admin if you need an archive.

The admin is intentionally not an authentication boundary. Do not expose private profile data in `config.json`, and do not treat hidden or disabled UI as authorization. Anyone who can edit the deployed site's source can change its public configuration.

## `config.json` schema

The root configuration has these fields:

| Field | Type | Purpose |
| --- | --- | --- |
| `defaultProfile` | string | Profile key used when no valid `?user=` parameter is present. |
| `site` | object | SEO title, canonical URL, author, keywords, and description. |
| `theme` | object | `defaultMode` (`dark` or `light`), `accent`, `accentSecondary`, and `font`. |
| `profiles` | object | Profiles keyed by URL-safe profile IDs. |

Each profile supports `id`, `name`, `handle`, `avatar`, `location`, `bio`, `tags`, `email`, `experience`, `youtubeVideoId`, `newsletter`, and `links`. Text fields such as `bio`, `location`, and newsletter title/description can be strings or bilingual objects such as `{"en":"Web Developer","bn":"ওয়েব ডেভেলপার"}`. Link entries support `id`, `title`, `titleBn`, `url`, `description`, `descriptionBn`, and `enabled`. For example:

```json
{
  "defaultProfile": "ra-fahim",
  "theme": {
    "defaultMode": "dark",
    "accent": "#9a7bff",
    "accentSecondary": "#5ae0ca",
    "font": "Inter"
  },
  "profiles": {
    "ra-fahim": {
      "id": "ra-fahim",
      "name": "RA Fahim",
      "bio": {
        "en": "Web Developer & Creator",
        "bn": "ওয়েব ডেভেলপার ও ক্রিয়েটর"
      },
      "email": "dev@rafahim.com",
      "links": [
        {
          "id": "website",
          "title": "Personal Website",
          "url": "https://rafahim.com",
          "description": "Projects, notes, and more",
          "enabled": true
        }
      ]
    }
  }
}
```

Use `?user=ra-fahim` to select that profile. Add a separate entry to `profiles`, then open `?user=your-profile-id`. The URL parameter matches the object key exactly.

## Link icon detection

Icons are inferred from the link URL and title. Recognized services include YouTube, GitHub, Twitter/X, Instagram, Facebook, LinkedIn, email, WhatsApp, and phone links. Other URLs use a generic link icon. Valid destinations include `https://`, `mailto:`, `tel:`, and WhatsApp URLs such as `https://wa.me/15551234567`.

## SEO checklist

- Keep `site.canonical`, the canonical links in both HTML pages, Open Graph URLs, and `sitemap.xml` aligned with the published URL.
- Keep the exact requested page title and keywords aligned in the HTML metadata and `config.json`.
- Keep `og-image.svg` reachable at the URL specified in the social tags.
- Check `robots.txt` and the sitemap after publishing on a subpath or custom domain.
- Keep the public profile links current and confirm JSON-LD represents only accurate facts.
- Admin HTML contains `noindex,nofollow`; `robots.txt` also disallows it. This is crawler guidance, not access control.
- Do not put private tokens or secret values into `config.json`; it is public client-side data.

## LinkFolio vs Linktree

| Capability | LinkFolio | Linktree hosted service |
| --- | --- | --- |
| Hosting | Self-host on static hosting you control | Hosted by Linktree |
| Price for the core page | Free source project; hosting depends on your provider | Free tier and paid plans; terms may change |
| Build tooling | None | Managed service |
| Data ownership | Public configuration and static files remain in your repository | Profile data lives in Linktree's service |
| Customization | Edit HTML, CSS, JavaScript, and JSON | Features depend on the selected plan |
| Analytics | Local browser click counts only; export manually | Hosted analytics features depend on the selected plan |
| Multiple profiles | `?user=profile-id` configuration | Depends on Linktree's current product features |
| Ads and third parties | No ads or third-party analytics included; optional YouTube loads on click | Service and plan features may vary |
| Subscriptions | Email-app handoff; no built-in mailing list | Integrations/features depend on plan and availability |

LinkFolio is intended for users who want source-level control and are comfortable publishing static files. It does not provide server-side authentication, globally aggregated analytics, a mailing-list backend, or automatic write access to hosted files.

## Accessibility and privacy

The UI has keyboard focus styles, semantic headings, form labels, and reduced-motion support. Click counts stay in local storage and are not transmitted. The optional YouTube embed makes a network request only after an explicit click. A remotely hosted avatar URL also makes a request when used; for an entirely self-contained deployment, store an avatar in your own site and use a local relative path.

## Author

**RA Fahim** — Web Developer & Creator, full-stack, 1 year of experience, based in Dhaka, Bangladesh.

- Website: https://rafahim.com
- GitHub: https://github.com/rafahim
- Email: dev@rafahim.com
- Twitter/X: https://twitter.com/rafahimn
- LinkedIn: https://linkedin.com/in/rafahimn

## License

MIT. See `LICENSE`.
