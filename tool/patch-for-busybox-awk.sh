#!/bin/sh

set -e # KEEP

J=${1:-JSON.awk}

cp "$J" "$J.$(date +'%Y%m%d%H%M%S').bak"

sed -i -e 's/\\000/\\001/g' -e '/^# Version:/ s/$/ PATCHED for busybox awk/' $J

if ! grep -qFm1 '\000' "$J"; then
	echo "$J is patched for busybox awk"
fi
