#!/usr/bin/env bash

set -euo pipefail

args=(
  -enable-kvm
  -cpu host
  -m 1G
  -smp 2
  -drive if=pflash,format=raw,readonly=on,file=$OVMF_CODE
  -drive if=pflash,format=raw,file=$OVMF_VARS
  -drive file=$IMAGE
  -nic tap,model=virtio,script=no,downscript=no,ifname=tap0,mac=52:54:00:12:32:01 # eth0 - enp3s0 2.5g LAN
  -nic tap,model=virtio,script=no,downscript=no,ifname=tap1,mac=52:54:00:12:32:02 # eth1 - enp1s0 1.0g WAN
)

if [ ${DEV:-0} -eq 1 ]; then
  args+=(
    -nographic
  )
else
  args+=(
    -display none
    -chardev socket,id=serial0,path=$SERIAL,server=on,wait=off
    -serial chardev:serial0
    -qmp unix:$QMP,server=on,wait=off
  )
fi

$QEMU "${args[@]}"
