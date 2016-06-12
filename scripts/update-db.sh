#!/bin/bash -e

overview="http://gemeinderat.winterthur.ch/de/politbusiness/"
detail="http://gemeinderat.winterthur.ch/de/politbusiness/?action=showinfo&info_id="

geschaefte=$(wget -qO- "${overview}" | sed -n 's,^.*?action=showinfo&info_id=\([0-9]*\).*$,\1,p')

for geschaeft in ${geschaefte}; do
    echo "insert or replace into ggrwinti_geschaefte (id, title, ggrnr, type, status, date) values ("
    echo "${geschaeft},"
    wget -qO- "${detail}${geschaeft}" | html2 \
        | sed -nf html2sql.sed | sed "s,',\\',g" | sed "s/^.*$/'&',/"
    echo ")"
done
