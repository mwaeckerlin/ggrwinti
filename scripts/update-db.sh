#!/bin/bash -e

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
PREFIX=${PREFIX:-oc_}
basis="http://gemeinderat.winterthur.ch/de/"
overview="${basis}politbusiness/"
sitzungen="${basis}sitzung/"
detail="http://gemeinderat.winterthur.ch/de/politbusiness/?action=showinfo&info_id="
only=
db=mysql
while test $# -gt 0; do
    case "$1" in
        (--prefix|-p) shift; PREFIX=$1;;
        (--mysql|-m) db=mysql;;
        (--sqlite|-s) db=sqlite;;
        (--geschaefte|-g) only=g;;
        (--sitzungen|-x) only=s;;
        (--help|-h) less <<EOF
SYNOPSIS

  $0 [OPTIONS]

OPTIONS

  --help, -h                 show this help
  --prefix, -p <prefix>      database table prefix
  --mysql, -m                mysql mode
  --sqlite, -s               sqlite mode
  --geschaefte, -g           only update geschaefte table
  --sitzungen, -x            only update sitzungen table

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


HTML2SQL=${0%/*}/html2sql.sed
if ! test -x "$HTML2SQL"; then
    HTML2SQL=$(which html2sql.sed)
    if ! test -x "$HTML2SQL"; then
        HTML2SQL=html2sql.sed
        if ! test -x "$HTML2SQL"; then
            echo "ERROR: html2sql.sed not found" 1>&2
            exit 1
        fi
    fi
fi
SITZUNGENAWK=${0%/*}/sitzungen.awk
if ! test -x "$SITZUNGENAWK"; then
    SITZUNGENAWK=$(which sitzungen.awk)
    if ! test -x "$SITZUNGENAWK"; then
        SITZUNGENAWK=sitzungen.awk
        if ! test -x "$SITZUNGENAWK"; then
            echo "ERROR: sitzungen.awk not found" 1>&2
            exit 1
        fi
    fi
fi

join() {
    local IFS="$1"
    shift
    echo -n "$*"
}

sql() {
    declare -a arg2=("${!2}")
    declare -a arg3=("${!3}")
    case "$db" in
        (mysql)
            declare -a nms
            for t in "${arg2[@]}"; do
                nms+=("$t=values($t)")
            done
            echo -n "insert into ${PREFIX}ggrwinti_${1} ("
            join ',' "${arg2[@]}"
            echo -n ") values ("
            join ',' "${arg3[@]}"
            echo -n ") on duplicate key update "
            join ',' "${nms[@]}"
        ;;
        (sqlite)
            echo -n "pragma busy_timeout=20000; "
            echo -n "insert or replace into ${PREFIX}ggrwinti_${1} ("
            join ',' "${arg2[@]}"
            echo -n ") values ("
            join ',' "${arg3[@]}"
            echo -n ")"
            
        ;;
        (*)
            error unknown database
            ;;
    esac
    echo ';'
}

export LANG=de_CH.ISO-8859-1

if test "$only" != "s"; then
    geschaefte=$(wget -qO- "${overview}" | sed -n 's,^.*?action=showinfo&info_id=\([0-9]*\).*$,\1,p')
    for geschaeft in ${geschaefte}; do
        declare -a values=()
        mapfile -t values < <(echo $geschaeft; wget -qO- "${detail}${geschaeft}" | html2 | sed -nf ${HTML2SQL} | sed "s,','',g")
        if test ${#values[@]} -eq 6; then
            declare -a vals=()
            for v in "${values[@]}"; do
                vals+=("'${v//'\\'}'")
            done
            names=( 'id' 'title' 'ggrnr' 'type' 'status' 'date' )
            sql geschaefte names[@]  vals[@]
        fi
    done
fi

if test "$only" != "g"; then
    sitzungen=$(wget -qO- 'http://gemeinderat.winterthur.ch/de/sitzung/?show=all' | sed -n 's,.*href="?action=showevent&amp;event_id=\([0-9]\+\).*,\1,p')
    for id in $sitzungen; do
        url='http://gemeinderat.winterthur.ch/de/sitzung/?action=showevent&event_id='$id
        content=$(wget -qO- "$url" | sed 's,<[^>]*>,\n,g')
        date=$(sed -n 's/^\([0-9][0-9]\)\.\([0-9][0-9]\)\.\(20[0-9][0-9]\)/\3-\2-\1/p' <<<"$content")
        if test -z "$date"; then
            error wget -qO- "'$url'"
            break
        fi
        names=('id' 'date')
        values=("$id" "'$date'")
        sql ggrsitzungen names[@] values[@]
        traktanden=$(sed -n '/^\([0-9]\+\)\.$/{s,,\1,;h;:a;n;/20[0-9][0-9]\.[0-9]\{1,3\}$/!b a;:g;s/^\([0-9]\{4\}\.\)\([0-9]\{1,2\}\)$/\10\2/;tg;H;x;s/\n/,/p}' <<<"$content")
        oldifs="$IFS"
        for traktandum in ${traktanden}; do
            IFS=","
            read -a values <<<"${traktandum}"
            values[1]="(select id from ${PREFIX}ggrwinti_geschaefte where ggrnr='${values[1]}' limit 1)"
            values[2]=$id
            values[3]=$(($id*100+${values[0]}))
            names=('nr' 'geschaeft' 'ggrsitzung' 'id')
            sql ggrsitzung_traktanden names[@] values[@]
        done
        IFS="$oldifs"
    done
fi
