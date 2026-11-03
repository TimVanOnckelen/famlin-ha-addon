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
- **Releasing a new Famlin version:** run the *Bump version* workflow (Actions
  tab, enter the version) or let it be triggered with a `repository_dispatch`
  event of type `famlin-release` and payload `{"version": "x.y.z"}`. It updates
  `config.yaml`, the `Dockerfile` and the changelog and opens a PR; merge it
  once the Famlin image for that version is published. The Famlin repository
  can send that event automatically if it has an `HA_ADDON_DISPATCH_TOKEN`
  secret (a PAT with write access to this repo); this is optional.
- Opening PRs created by the bump workflow may need *Settings, Actions,
  General, Allow GitHub Actions to create and approve pull requests* enabled.
