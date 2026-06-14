#!/usr/bin/env bash
set -euo pipefail

GUEST_UID="$(id -u guest)"

/usr/local/bin/kidz-refresh-allowlist.sh

iptables -N KIDZ_GUEST_NET 2>/dev/null || true
iptables -F KIDZ_GUEST_NET
iptables -A KIDZ_GUEST_NET -o lo -j ACCEPT
iptables -A KIDZ_GUEST_NET -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A KIDZ_GUEST_NET -p udp --dport 53 -j ACCEPT
iptables -A KIDZ_GUEST_NET -p tcp --dport 53 -j ACCEPT
iptables -A KIDZ_GUEST_NET -p tcp -m multiport --dports 80,443 -m set --match-set kidz_allow dst -j ACCEPT
iptables -A KIDZ_GUEST_NET -j REJECT
iptables -C OUTPUT -m owner --uid-owner "$GUEST_UID" -j KIDZ_GUEST_NET 2>/dev/null || iptables -A OUTPUT -m owner --uid-owner "$GUEST_UID" -j KIDZ_GUEST_NET

ip6tables -N KIDZ_GUEST_NET 2>/dev/null || true
ip6tables -F KIDZ_GUEST_NET
ip6tables -A KIDZ_GUEST_NET -o lo -j ACCEPT
ip6tables -A KIDZ_GUEST_NET -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A KIDZ_GUEST_NET -p udp --dport 53 -j ACCEPT
ip6tables -A KIDZ_GUEST_NET -p tcp --dport 53 -j ACCEPT
ip6tables -A KIDZ_GUEST_NET -p tcp -m multiport --dports 80,443 -m set --match-set kidz_allow6 dst -j ACCEPT
ip6tables -A KIDZ_GUEST_NET -j REJECT
ip6tables -C OUTPUT -m owner --uid-owner "$GUEST_UID" -j KIDZ_GUEST_NET 2>/dev/null || ip6tables -A OUTPUT -m owner --uid-owner "$GUEST_UID" -j KIDZ_GUEST_NET

netfilter-persistent save
