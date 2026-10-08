#!/bin/sh
set -e

sysctl -w net.ipv4.ip_forward=1 2>/dev/null || true

HOST_GW="${HOST_GW:-172.18.0.1}"
HOST_SUBNET="${HOST_SUBNET:-172.18.0.0/16}"
PORTS="${PORTS:-8096 25565 25567 22}"

# The host (Ubuntu/UFW) enforces the nft backend, while this image defaults to
# the legacy backend. Use iptables-nft when poking the host tables.
HOST_IPTABLES="$(command -v iptables-nft 2>/dev/null || command -v iptables)"

# Tailnet traffic hits the tailscale0 interface in this container. DNAT it to
# the docker bridge gateway (the host) where Jellyfin/Minecraft/sshd listen.
setup_yoink() {
  for port in $PORTS; do
    iptables -t nat -C PREROUTING -i tailscale0 -p tcp --dport "$port" \
      -j DNAT --to-destination "${HOST_GW}:${port}" 2>/dev/null \
      || iptables -t nat -A PREROUTING -i tailscale0 -p tcp --dport "$port" \
        -j DNAT --to-destination "${HOST_GW}:${port}"

    iptables -C FORWARD -i tailscale0 -p tcp --dport "$port" -j ACCEPT 2>/dev/null \
      || iptables -A FORWARD -i tailscale0 -p tcp --dport "$port" -j ACCEPT
  done

  iptables -C FORWARD -o tailscale0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null \
    || iptables -A FORWARD -o tailscale0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

  iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null \
    || iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

# The DNAT target is the host's own IP, so the packet is filtered by the host
# INPUT chain (policy DROP / UFW). Open just these ports for the docker subnet.
setup_host_input() {
  for port in $PORTS; do
    nsenter -t 1 -n "$HOST_IPTABLES" -C INPUT -s "$HOST_SUBNET" -p tcp --dport "$port" -j ACCEPT 2>/dev/null \
      || nsenter -t 1 -n "$HOST_IPTABLES" -I INPUT 1 -s "$HOST_SUBNET" -p tcp --dport "$port" -j ACCEPT 2>/dev/null \
      || true
  done
}

setup_yoink
setup_host_input

(
  while true; do
    if ip link show tailscale0 >/dev/null 2>&1; then
      setup_yoink
      setup_host_input
      break
    fi
    sleep 1
  done
) &

exec /usr/local/bin/containerboot
