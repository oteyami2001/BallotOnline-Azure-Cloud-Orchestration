# BallotOnline Demo Website

A static, four-page BallotOnline website (Home, About Us, Services,
Contact Us) used to demonstrate the hosting architectures in this
repository.

**Live demo:** https://oteyami2001.github.io/BallotOnline-Azure-Cloud-Orchestration/

## About this version

The proof of concept was built with a static site supplied as course
material. That material is copyrighted and cannot be redistributed, so
this folder contains an **original recreation**: the same page structure
and purpose, with new text, a new stylesheet and new graphics. BallotOnline
is a fictional company.

## Files

| File | Purpose |
|---|---|
| `index.html`, `about-us.html`, `services.html`, `contact-us.html` | Site pages |
| `assets/css/style.css` | Shared, responsive stylesheet |
| `assets/img/logo.svg` | Logo and favicon |

No JavaScript, build step or external resources are needed.

## Where it runs

| Environment | How the site is served |
|---|---|
| Azure VM / VM Scale Set (IaaS) | Nginx serves the files from `/data/www/BallotOnline` (see [`nginx.conf`](../infrastructure/nginx/nginx.conf)) |
| Azure App Service (PaaS) | Deployed with `git push`; the PoC renamed `index.html` to `index.php` for the PHP runtime |
| GitHub Pages | Published automatically by [`pages.yml`](../.github/workflows/pages.yml) whenever `website/` changes on `main` |
| Local | Open `index.html` in a browser, or run `python3 -m http.server -d website 8080` |

## Deploying to an Azure VM

```bash
sudo mkdir -p /data/www/BallotOnline
sudo cp -r website/* /data/www/BallotOnline/
sudo nginx -t && sudo systemctl reload nginx
```
