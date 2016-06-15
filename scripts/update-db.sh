#!/bin/bash

PREFIX=${PREFIX:-oc_}
overview="http://gemeinderat.winterthur.ch/de/politbusiness/"
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
