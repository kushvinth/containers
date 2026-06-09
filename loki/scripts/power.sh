#!/bin/bash

LOAD=$(cut -d' ' -f1 /proc/loadavg)

# Base idle power + load factor
POWER=$(awk "BEGIN { print 6 + ($LOAD * 2.5) }")

cat <<EOF > /home/kushvinth/Server/loki/textfile_collector/power.prom
server_estimated_power_watts $POWER
EOF
