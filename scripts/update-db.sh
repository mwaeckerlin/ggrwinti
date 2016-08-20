#!/bin/bash

PREFIX=${PREFIX:-oc_}
basis="http://gemeinderat.winterthur.ch/de/"
overview="${basis}politbusiness/"
sitzungen="${basis}sitzung/"
detail="http://gemeinderat.winterthur.ch/de/politbusiness/?action=showinfo&info_id="
HTML2SQL=$(which html2sql.sed)
if ! test -x "$HTML2SQL"; then
    HTML2SQL=${0%/*}/html2sql.sed
    if ! test -x "$HTML2SQL"; then
        HTML2SQL=html2sql.sed
        if ! test -x "$HTML2SQL"; then
            echo "ERROR: html2sql.sed not found" 1>&2
            exit 1
        fi
    fi
fi
SITZUNGENAWK=$(which sitzungen.awk)
if ! test -x "$SITZUNGENAWK"; then
    SITZUNGENAWK=${0%/*}/sitzungen.awk
    if ! test -x "$SITZUNGENAWK"; then
        SITZUNGENAWK=sitzungen.awk
        if ! test -x "$SITZUNGENAWK"; then
            echo "ERROR: sitzungen.awk not found" 1>&2
            exit 1
        fi
    fi
fi


geschaefte=$(wget -qO- "${overview}" | sed -n 's,^.*?action=showinfo&info_id=\([0-9]*\).*$,\1,p')
for geschaeft in ${geschaefte}; do
    values=$(wget -qO- "${detail}${geschaeft}" | html2 \
             | sed -nf ${HTML2SQL} | sed "s,',\\\\',g" | sed "s/^.*$/,'&'/")
    if test $(echo "$values" | wc -l) -eq 5; then
        echo "insert into ${PREFIX}ggrwinti_geschaefte (id, title, ggrnr, type, status, datum) values ("
        echo "${geschaeft}"
        echo "$values"
        echo ") on duplicate key update id = values(id), title = values(title), ggrnr = values(ggrnr), type = values(type), status = values(status), datum = values(datum);"
    fi
done

echo "start transction;"
echo "delete from ${PREFIX}ggrwinti_sitzung"
naechste=$(wget -qO- http://gemeinderat.winterthur.ch/de/sitzung/ | html2 2> /dev/null | sed -n 's,.*tbody/tr/td/span/a/@href=,,p' | head -1)
echo "insert into ${PREFIX}ggrwinti_sitzung (nr, ggrnr) values"
wget -qO- "${sitzungen}${naechste}" | html2 2> /dev/null | awk -F= -f ${SITZUNGENAWK}
echo "commit"
