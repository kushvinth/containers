#!/bin/sh
# Keeps seanime's internet (via the gluetun VPN container) alive.
# Run every few minutes from cron/systemd. Safe to run often: does nothing when healthy.
cd "$(dirname "$0")" || exit 1

check() { docker exec seanime sh -c 'curl -s -m 8 -o /dev/null https://www.cloudflare.com && curl -s -m 8 -o /dev/null https://graphql.anilist.co' 2>/dev/null; }

check && exit 0
sleep 20; check && exit 0   # ignore brief blips / VPN reconnects

echo "$(date -Is) seanime has no internet, repairing"
# 1) gluetun may just need its tunnel back; restart it and wait for a public IP
docker restart gluetun-seanime >/dev/null 2>&1
i=0; until docker logs --since 2m gluetun-seanime 2>&1 | grep -q "Public IP address"; do
  i=$((i+1)); [ $i -gt 30 ] && break; sleep 4
done
# 2) seanime shares gluetun's network namespace and goes stale whenever gluetun is restarted/recreated,
#    so always recreate it (same pinned image, no pull) so it attaches to the live gluetun
docker compose up -d --force-recreate --no-deps seanime >/dev/null 2>&1
sleep 25
if check; then echo "$(date -Is) repaired"; else echo "$(date -Is) STILL BROKEN, check gluetun logs"; exit 1; fi
