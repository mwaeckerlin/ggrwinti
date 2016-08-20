#!/usr/bin/awk -f 

BEGIN {
    FS="="
    status=0
    tainted=0
}

$1 ~ /@id$/ && $2 == "event_traktanden_content" {
    status=1
}

status>0 && $1 ~ /@class$/ && $2 == "sitzungstraktanden_nummer" {
    status=2
}

status>0 && $1 ~ /@class$/ && $2 == "sitzungstraktanden_geschaeft" {
    status=3
}

status==2 && $1 ~ /td$/ && $2!="" {
    nummer=$2
    status=1
    tainted=1
}

status==3 && $1 ~ /td\/a$/ && $2!="" {
    geschaeft=$2
    status=1
    tainted=1
}

tainted==1 && $1 ~ /tr$/ {
    print "('" nummer "', '" geschaeft "'),"
    tainted=0
}

END {
    if (tainted==1) {
    print "('" nummer "', '" geschaeft "');"
        tainted=0
    }
}

