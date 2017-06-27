#!/bin/bash -e

# template for bash scripts

# internal use only
append_msg() {
    if test $# -ne 0; then
        echo -en ":\e[0m \e[1m$*"
    fi
    echo -e "\e[0m"
}

# write a notice
notice() {
    if test $# -eq 0; then
        return
    fi
    echo -e "\e[1m$*\e[0m" 1>&3
}

# write error message
error() {
    echo -en "\e[1;31merror" 1>&2
    append_msg $* 1>&2
}

# write a warning message
warning() {
    echo -en "\e[1;33mwarning" 1>&2
    append_msg $* 1>&2
}

# write a success message
success() {
    echo -en "\e[1;32msuccess" 1>&2
    append_msg $* 1>&2
}

# commandline parameter evaluation
SQL_BEFORE="pragma busy_timeout=20000; insert into"
SQL_AFTER=" on duplicate key update id = values(id), title = values(title), ggrnr = values(ggrnr), type = values(type), status = values(status), datum = values(datum)"
PREFIX=${PREFIX:-oc_}
basis="http://gemeinderat.winterthur.ch/de/"
overview="${basis}politbusiness/"
sitzungen="${basis}sitzung/"
detail="http://gemeinderat.winterthur.ch/de/politbusiness/?action=showinfo&info_id="
while test $# -gt 0; do
    case "$1" in
        (--prefix|-p) shift; PREFIX=$1;;
        (--mysql|-m)
            SQL_BEFORE="insert into"
            SQL_AFTER=" on duplicate key update id = values(id), title = values(title), ggrnr = values(ggrnr), type = values(type), status = values(status), datum = values(datum)"
            ;;
        (--sqlite|-s)
            SQL_BEFORE="insert or replace into"
            SQL_AFTER=""
            ;;
        (--help|-h) less <<EOF
SYNOPSIS

  $0 [OPTIONS]

OPTIONS

  --help, -h                 show this help
  --prefix, -p <prefix>      database table prefix
  --mysql, -m                mysql mode
  --sqlite, -s               sqlite mode

DESCRIPTION

  update GGR-Winti databases from internet

EOF
            exit;;
        (*) error "unknow option $1, try $0 --help"; exit 1;;
    esac
    if test $# -eq 0; then
        error "missing parameter, try $0 --help"; exit 1
    fi
    shift;
done

# run a command, print the result and abort in case of error
# option: --no-check: ignore the result, continue in case of error
run() {
    check=1
    while test $# -gt 0; do
        case "$1" in
            (--no-check) check=0;;
            (*) break;;
        esac
        shift;
    done
    echo -en "\e[1m-> running:\e[0m $* ..."
    result=$($* 2>&1)
    res=$?
    if test $res -ne 0; then
        if test $check -eq 1; then
            error "failed with return code: $res"
            if test -n "$result"; then
                echo "$result"
            fi
            exit 1
        else
            warning "ignored return code: $res"
        fi
    else
        success
    fi
}

# error handler
function traperror() {
    set +x
    local err=($1) # error status
    local line="$2" # LINENO
    local linecallfunc="$3"
    local command="$4"
    local funcstack="$5"
    for e in ${err[@]}; do
        if test -n "$e" -a "$e" != "0"; then
            error "line $line - command '$command' exited with status: $e (${err[@]})"
            if [ "${funcstack}" != "main" -o "$linecallfunc" != "0" ]; then
                echo -n "   ... error at ${funcstack} "
                if [ "$linecallfunc" != "" ]; then
                    echo -n "called at line $linecallfunc"
                fi
                echo
            fi
            exit $e
        fi
    done
    success
    exit 0
}

# catch errors
trap 'traperror "$? ${PIPESTATUS[@]}" $LINENO $BASH_LINENO "$BASH_COMMAND" "${FUNCNAME[@]}" "${FUNCTION}"' ERR SIGINT INT TERM EXIT

##########################################################################################


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
             | sed -nf ${HTML2SQL} | sed "s,','',g" | sed "s/^.*$/,'&'/")
    if test $(echo "$values" | wc -l) -eq 5; then
        echo "${SQL_BEFORE} ${PREFIX}ggrwinti_geschaefte (id, title, ggrnr, type, status, datum) values ("
        echo "${geschaeft}"
        echo "$values"
        echo ")${SQL_AFTER};"
    fi
done

echo "begin transaction;"
echo "delete from ${PREFIX}ggrwinti_sitzung;"
naechste=$(wget -qO- http://gemeinderat.winterthur.ch/de/sitzung/ | html2 2> /dev/null | sed -n 's,.*tbody/tr/td/span/a/@href=,,p' | head -1)
echo "insert into ${PREFIX}ggrwinti_sitzung (nr, ggrnr) values"
wget -qO- "${sitzungen}${naechste}" | html2 2> /dev/null | ${SITZUNGENAWK}
echo "commit;"
