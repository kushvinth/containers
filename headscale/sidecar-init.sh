#!/bin/sh
set -e

# Port yoink: Headscale traffic to this node's tailscale IP:8096 is DNAT'd to
# the Docker bridge gateway (host), where Jellyfin listens in host network mode.
sysctl -w net.ipv4.ip_forward=1 2>/dev/null || true

HOST_GW="${HOST_GW:-172.18.0.1}"
JELLYFIN_PORT="${JELLYFIN_PORT:-8096}"
MINECRAFT_PORT="${MINECRAFT_PORT:-25565}"
MINECRAFT_LIFESTEAL_PORT="${MINECRAFT_LIFESTEAL_PORT:-25567}"

setup_yoink() {
  iptables -t nat -C PREROUTING -i tailscale0 -p tcp --dport "$JELLYFIN_PORT" \
    -j DNAT --to-destination "${HOST_GW}:${JELLYFIN_PORT}" 2>/dev/null \
    || iptables -t nat -A PREROUTING -i tailscale0 -p tcp --dport "$JELLYFIN_PORT" \
      -j DNAT --to-destination "${HOST_GW}:${JELLYFIN_PORT}"

  iptables -C FORWARD -i tailscale0 -p tcp --dport "$JELLYFIN_PORT" -j ACCEPT 2>/dev/null \
    || iptables -A FORWARD -i tailscale0 -p tcp --dport "$JELLYFIN_PORT" -j ACCEPT

  iptables -t nat -C PREROUTING -i tailscale0 -p tcp --dport "$MINECRAFT_PORT" \
    -j DNAT --to-destination "${HOST_GW}:${MINECRAFT_PORT}" 2>/dev/null \
    || iptables -t nat -A PREROUTING -i tailscale0 -p tcp --dport "$MINECRAFT_PORT" \
      -j DNAT --to-destination "${HOST_GW}:${MINECRAFT_PORT}"

  iptables -C FORWARD -i tailscale0 -p tcp --dport "$MINECRAFT_PORT" -j ACCEPT 2>/dev/null \
    || iptables -A FORWARD -i tailscale0 -p tcp --dport "$MINECRAFT_PORT" -j ACCEPT

  iptables -t nat -C PREROUTING -i tailscale0 -p tcp --dport "$MINECRAFT_LIFESTEAL_PORT" \
    -j DNAT --to-destination "${HOST_GW}:${MINECRAFT_LIFESTEAL_PORT}" 2>/dev/null \
    || iptables -t nat -A PREROUTING -i tailscale0 -p tcp --dport "$MINECRAFT_LIFESTEAL_PORT" \
      -j DNAT --to-destination "${HOST_GW}:${MINECRAFT_LIFESTEAL_PORT}"

  iptables -C FORWARD -i tailscale0 -p tcp --dport "$MINECRAFT_LIFESTEAL_PORT" -j ACCEPT 2>/dev/null \
    || iptables -A FORWARD -i tailscale0 -p tcp --dport "$MINECRAFT_LIFESTEAL_PORT" -j ACCEPT

  iptables -C FORWARD -o tailscale0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null \
    || iptables -A FORWARD -o tailscale0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

  iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null \
    || iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

setup_yoink

(
  while true; do
    if ip link show tailscale0 >/dev/null 2>&1; then
      setup_yoink
      break
    fi
    sleep 1
  done
) &

exec /usr/local/bin/containerboot
