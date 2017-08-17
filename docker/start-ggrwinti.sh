#!/bin/bash -e

sed -i 's,^#HERE#$,'"$(env | sed 's.[,\&].\\&.g' | sed ':a;N;$!ba;s,\n,\\n,g')"',' /etc/cron.daily/update-db

/start.sh
