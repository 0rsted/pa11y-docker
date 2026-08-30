#!/bin/sh
set -eu

case "${PUID}" in
  ''|*[!0-9]*) echo "PUID must be a positive integer" >&2; exit 1 ;;
esac
case "${PGID}" in
  ''|*[!0-9]*) echo "PGID must be a positive integer" >&2; exit 1 ;;
esac
if [ "${PUID}" -eq 0 ] || [ "${PGID}" -eq 0 ]; then
  echo "PUID and PGID must be greater than zero" >&2
  exit 1
fi

# Match the process identity to the host-provided IDs.
groupmod --non-unique --gid "${PGID}" pptruser
usermod --non-unique --uid "${PUID}" --gid "${PGID}" pptruser

# Match the application directory to the runtime user. With a bind mount,
# this also updates the mapped host directory on Linux.
chown pptruser:pptruser /app

# Keep the working directory on the host-mounted path. Pa11y resolves
# relative screenshot and export paths from the process working directory;
# application files remain in the image and are not copied into the mount.
cd /app

exec runuser --user pptruser -- "$@"
