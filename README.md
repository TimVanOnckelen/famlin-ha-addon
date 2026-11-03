# Famlin Home Assistant add-on

[Famlin](https://famlin.app) is a private, self-hosted family updates app:
posts, photos, stories, comments and milestones, shared only with the people
you invite. This repository lets you run it as a **Home Assistant add-on**. It
bundles its own PostgreSQL database, so there is nothing else to set up.

[![Add repository to my Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FTimVanOnckelen%2Ffamlin-ha-addon)

Or add it manually: in Home Assistant go to **Settings, Add-ons, Add-on store**,
open the three-dot menu, choose **Repositories** and add
`https://github.com/TimVanOnckelen/famlin-ha-addon`. Then install **Famlin**.

Full instructions, remote access and backups:
https://famlin.app/docs/install-home-assistant

## Add-ons

- **Famlin** (`famlin/`): the Famlin server with a bundled database. Data,
  photos and secrets live in the add-on's `/data`, so Home Assistant backups
  include everything.

## Maintainers

- Layout: `repository.yaml` (repository metadata) and `famlin/` (the add-on:
  `config.yaml`, `Dockerfile`, `rootfs/run.sh`, docs).
- The add-on builds `FROM ghcr.io/timvanonckelen/famlin:<version>`, adding
  PostgreSQL 16. CI (`.github/workflows/build.yml`) lints, builds both
  architectures natively, smoke-tests the amd64 image, and on `main` pushes
  `ghcr.io/timvanonckelen/famlin-ha-addon-{amd64,aarch64}`.
- **Pre-built images (not enabled yet):** `config.yaml` has a commented-out
  `image:` line. Adding it makes Home Assistant pull instead of build, which
  breaks installs until the images exist. After the first green build on
  `main`, make the two ghcr packages public (package settings, change
  visibility) and uncomment the `image:` line in `famlin/config.yaml`.
- **New Famlin releases are followed automatically.** The *Update Famlin*
  workflow (`.github/workflows/update.yml`) runs every 6 hours (and on demand:
  Actions tab, *Run workflow*, optionally with a version; a
  `repository_dispatch` of type `famlin-release` with payload
  `{"version": "x.y.z"}` is an optional fast path). It looks up the latest
  Famlin release, waits until the `ghcr.io/timvanonckelen/famlin:<version>`
  image exists (otherwise it quietly retries on the next run), and only ever
  moves forward.
  - **Normal releases:** the bump (`config.yaml`, `Dockerfile`, changelog) is
    committed to a temporary branch `update/famlin-<version>`, the *Build*
    workflow is run on it (lint, native amd64/aarch64 build, smoke test) and
    publishes the add-on images, and only if that succeeds `main` is
    fast-forwarded to it. The images therefore exist before the version on
    `main` changes. Nothing needs a token: workflow runs started by the
    default `GITHUB_TOKEN` cannot trigger other workflows, so everything is
    chained inside the one run.
  - **Breaking releases** (release notes contain "BREAKING CHANGES", or the
    major version changes) are not applied automatically: a pull request
    `update/famlin-<version>` is opened for review, after the same build ran
    on its branch without pushing images. Checks do not start by themselves on
    that PR (same token limitation); the build already ran in the update run.
    Merging runs the normal *Build* on `main`, which publishes the images.
    The job summary of each run says what happened ("already up to date",
    "image not published yet", "updated to x", "breaking: PR opened").
- **One-time repository settings** (Settings, Actions, General): *Workflow
  permissions* set to **Read and write permissions**, and **Allow GitHub
  Actions to create and approve pull requests** enabled. If `main` has branch
  protection, the Actions bot must be allowed to push to it. After the first
  push of the images, make the two ghcr packages public (see above).
