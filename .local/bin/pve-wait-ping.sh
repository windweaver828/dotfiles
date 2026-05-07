#!/bin/bash

until ping -c1 -W1 192.168.22.200 >/dev/null 2>&1; do
  printf '.'
  sleep 1
done
echo " pve is back"
