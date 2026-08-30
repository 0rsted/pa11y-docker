# Pa11y Dashboard container

This is an independent courtesy project. It was created with the assistance
of machine-learning software to make Pa11y Dashboard easier to set up and use
for people who want to build accessible websites.

Pa11y Dashboard itself is created and maintained by the Pa11y developers and
contributors. All rights in the Pa11y Dashboard application and its upstream
source remain with their respective copyright holders. No infringement of
copyright, trademarks, or other rights is intended.

This repository builds the official `pa11y/pa11y-dashboard` release as a small
non-root `linux/amd64` image and publishes it to GHCR:

`ghcr.io/<github-owner>/pa11y-dashboard`

MongoDB is intentionally a separate container. Start the stack with:

```sh
docker compose up -d
```

Set a strong MongoDB password before production use. The default Compose
configuration is suitable for local use; supply `MONGO_IMAGE` to use a
different MongoDB image.

The scheduled `refresh-versions` workflow runs daily at 00:00 UTC. It resolves
the newest Pa11y Dashboard release, then reads that release’s supported Node.js
engine range and MongoDB major from upstream. It selects the newest stable
Node.js LTS inside that range and pins the newest patch digest of the supported
MongoDB major. When any value changes it commits `versions.env`, which triggers
`publish.yml`. The published image is AMD64-only by design.

To publish from a fork, enable GitHub Actions and ensure the repository allows
the workflow's `GITHUB_TOKEN` to write packages. To publish to Docker Hub, add
the repository variable `DOCKERHUB_USERNAME` and the repository secret
`DOCKERHUB_TOKEN` (a Docker Hub access token with permission to push to the
`pa11y-dashboard` repository).

## Licensing and attribution

This repository does not replace or relicense Pa11y Dashboard. The Dockerfile
clones the selected upstream release and retains its upstream files, including
the GPL-3.0 license and copyright notices, inside the resulting image.

The relevant upstream components are:

- **Pa11y Dashboard** — GNU GPL v3.0. See the [upstream repository](https://github.com/pa11y/pa11y-dashboard), its [license](https://github.com/pa11y/pa11y-dashboard/blob/main/LICENSE), and the preserved [LICENSE](./LICENSE) file.
- **Node.js** — MIT-licensed, including the notices and third-party license information in the [Node.js license file](https://github.com/nodejs/node/blob/main/LICENSE). This project uses the official [Node Docker image](https://github.com/nodejs/docker-node).
- **MongoDB Community Server** — the Compose file uses the official MongoDB Community image. MongoDB versions released after 16 October 2018 are licensed under the [Server Side Public License (SSPL) v1.0](https://www.mongodb.com/legal/licensing/community-edition). MongoDB is a separate container and is not copied into the Pa11y Dashboard image.
- **JavaScript dependencies and Chromium** — these are obtained by the upstream Pa11y Dashboard installation process. Their individual license and notice files remain in `node_modules` and the Puppeteer installation in the image; users redistributing the image should preserve applicable notices and comply with each dependency's terms.

The image is distributed as a convenience wrapper around the upstream
software. This documentation is not legal advice; organizations redistributing
the image should perform their own license and trademark review.
