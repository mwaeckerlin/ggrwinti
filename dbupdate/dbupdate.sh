#!/bin/sh -e

cd /srv

wget -qO- https://parlament.winterthur.ch/_rtr/politbusiness \
| sed -n ':a;$!N;$!ba;s/.*data-entities="\([^"]*\)".*/\1/p' \
| recode html..ascii \
| ascii2uni -Z '\u%04X' -q \
| node geschaefteupdate

wget -qO- https://parlament.winterthur.ch/sitzung \
| sed -n ':a;$!N;$!ba;s/.*data-entities="\([^"]*\)".*/\1/p' \
| recode html..ascii \
| ascii2uni -Z '\u%04X' -q \
| node sitzungenupdate \
| while read ggrsitzung; do
    i=1
    wget -qO- https://parlament.winterthur.ch/sitzung/$ggrsitzung \
    | xmllint --html --xmlout /dev/stdin 2>/dev/null \
    | xml2 \
    | sed -n 's,/html/body/main/.*/table/tbody/tr/td/a/@href=/_rte/information/,,p' \
    | while read geschaeft; do
        printf "%02d%s,%s,%s,%s\n" "$((i))" "$ggrsitzung" "$((i++))" "$ggrsitzung" "$geschaeft"
    done | node traktandenupdate
done

# mysql -h mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE