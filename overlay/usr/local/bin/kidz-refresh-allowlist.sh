#!/usr/bin/env bash
set -euo pipefail

DOMAINS=(
  scratch.mit.edu
  www.scratch.mit.edu
  pbskids.org
  www.pbskids.org
)

ipset create kidz_allow hash:ip family inet -exist
ipset create kidz_allow6 hash:ip family inet6 -exist
ipset flush kidz_allow
ipset flush kidz_allow6

for domain in "${DOMAINS[@]}"; do
  getent ahostsv4 "$domain" | awk '{print $1}' | sort -u | while read -r ip; do
    [ -n "$ip" ] && ipset add kidz_allow "$ip" -exist
  done || true

  getent ahostsv6 "$domain" | awk '{print $1}' | sort -u | while read -r ip; do
    [ -n "$ip" ] && ipset add kidz_allow6 "$ip" -exist
  done || true
done
