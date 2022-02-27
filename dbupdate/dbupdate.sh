#!/bin/sh

wget -qO- https://parlament.winterthur.ch/_rtr/politbusiness \
| sed -n ':a;$!N;$!ba;s/.*data-entities="\([^"]*\)".*/\1/p' \
| recode html..ascii \
| ascii2uni -Z '\u%04X' -q \
| node dbupdate