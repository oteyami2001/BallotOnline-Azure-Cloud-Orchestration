# 12 — Repository Validation

## Purpose

This repository uses GitHub Actions
([`validate.yml`](../.github/workflows/validate.yml)) to validate the
portfolio artifacts on every push to `main` and every pull request.

> The workflow validates **this repository**. It is not the deployment
> mechanism used in the Azure proof of concept, which used App Service
> local Git deployment ([stage 06](06-continuous-deployment.md)).

---

## Validation Pipeline

```text
Developer
    |
    v
Git push / pull request
    |
    v
GitHub Actions
    |
    +--> Checkout
    +--> Validate JSON
    +--> Validate shell scripts (bash -n + ShellCheck)
    +--> Scan for private-key headers
    +--> Check Markdown links
    +--> Verify required documentation
    |
    v
Validation result (pass / fail)
```

---

## Checks

| Check | What it does | Catches |
|---|---|---|
| **JSON** | Parses every tracked `.json` file (ARM templates and parameters) | Malformed templates before anyone tries to deploy them |
| **Shell** | Runs `bash -n` and [ShellCheck](https://www.shellcheck.net/) on every `.sh` file | Syntax errors, unquoted variables, common Bash bugs |
| **Credential safety** | Searches tracked files for private-key headers | Accidentally committed SSH or TLS private keys |
| **Markdown links** | Confirms every relative link in the docs points to a real file | Broken links after files are renamed or moved |
| **Portfolio structure** | Confirms key architecture, security, troubleshooting and ADR documents exist | Accidental deletion of core documentation |

The credential check is a basic safeguard, not a replacement for
dedicated secret scanning such as GitHub secret scanning.

Running the same checks locally:

```bash
git ls-files '*.json' | xargs -n1 python3 -m json.tool > /dev/null
git ls-files '*.sh' | xargs shellcheck
```

---

## CI/CD Evolution

The original proof of concept demonstrated:

```text
Local Git --> Azure App Service
```

This portfolio repository adds:

```text
GitHub --> GitHub Actions --> Automated validation
```

A production implementation could extend the pipeline to deploy:

```text
GitHub
   |
   v
Build --> Test --> Security scan --> Azure login (OIDC) --> Deploy
                                                             |
                                                             v
                                                    Azure App Service
```

Production deployments should authenticate with workload identity
federation (OpenID Connect) or another approved mechanism, never with
cloud credentials stored in the repository.
