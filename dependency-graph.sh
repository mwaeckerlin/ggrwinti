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
files=${0%/*}/configure.ac
short=0
while test $# -gt 0; do
    case "$1" in
        (--short|-s) short=1;;
        (--help|-h) less <<EOF
SYNOPSIS

  $0 [OPTIONS] <files>

OPTIONS

  --help, -h                 show this help
  --short, -s                short graph with no external dependencies

  <files>                    list of zero or more configure.ac files
                             (default: ${files})

DESCRIPTION

  Evaluates dependencies of all the given configure.ac file. By
  default takes the local configure.ac. Outputs a graphwiz dot file
  with the dependencies. Solid lines are required dependencies, dotted
  lines are optional dependencies.

EXAMPLE

  Evaluate all dependencies between all local subversion and git
  projects, if they are in the path ~/svn and ~/git:

    $0 ~/svn/*/configure.ac ~/git/*/configure.ac 

EOF
            exit;;
        (*) files=$*; break;;
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

filter() {
    if test $short -eq 1; then
        all=$(cat)
        allowed=$(sed -n '/"\(.*\)" \[style=solid\];/{s//\1/;H};${x;s/\n//;s/\n/\\|/gp}' <<<"${all}")
        sed -n '/"\('"${allowed}"'\)" -> "\('"${allowed}"'\)"/p' <<<"${all}"
    else
        cat
    fi
}

echo "digraph G {"
if test $short -eq 0; then
    echo "node [style=dashed];"
fi
(
    for file in $files; do
        if ! test -e $file; then
            error "file $file not found"; exit 1
        fi
        sed -n '
      /^ *m4_define(x_package_name, */ {s//"/;s/ *).*/"/;h;s/.*/& [style=solid];/p}
      /^ *AX_REQUIRE_QT/ {s/.*/"qt" -> /;G;s/\n//;s/.*/&;/p}
      /^ *AX_PKG_REQUIRE(\[\?\([^],)]\+\)\]\?, \[\?\([^],)]\+\)\]\?.*/ {s//"\2" -> /;G;s/\n//;s/.*/&;/p}
      /^ *AX_PKG_REQUIRE(\[\?\([^],)]\+\)\]\?.*/ {s//"\1" -> /;G;s/\n//;s/.*/&;/p}
      /^ *AX_CHECK_QT/ {s/.*/"qt" -> /;G;s/\n//;s/.*/& [style=dashed];/p}
      /^ *AX_PKG_CHECK(\[\?\([^],)]\+\)\]\?, \[\?\([^],)]\+\)\]\?.*/ {s//"\2" -> /;G;s/\n//;s/.*/& [style=dotted];/p}
      /^ *AX_PKG_CHECK(\[\?\([^],)]\+\)\]\?.*/ {s//"\1" -> /;G;s/\n//;s/.*/& [style=dotted];/p}
    ' $file
    done
) | filter
echo "}"
