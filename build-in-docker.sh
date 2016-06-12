#! /bin/bash -e
set -o errtrace

# build and test everything in a fresh docker installation
mode="apt"
img="ubuntu:latest"
repos=()
keys=()
envs=()
dirs=("-v $(pwd):/workdir")
packages=()
targets="all check distcheck"
commands=()
wait=0
if test -e ./build-in-docker.conf; then
    # you can preconfigure the variables in file build-in-docker.conf
    # if you do so, add the file to EXTRA_DIST in makefile.am
    source ./build-in-docker.conf
fi
while test $# -gt 0; do
    case "$1" in
        (-h|--help)
            echo "$0 [OPTIONS]"
            echo
            echo "OPTIONS:"
            echo
            echo "  -h, --help            show this help"
            echo "  -m, --mode <type>     mode: apt or yum, default: ${mode}"
            echo "  -i, --image <image>   use given docker image instead of ${img}"
            echo "  -t, --targets targets specify build targets, default: ${targets}"
            echo "  -r, --repo <url>      add given apt repository"
            echo "  -k, --key <url>       add public key from url"
            echo "  -e, --env <var>=<val> set environment variable in docker"
            echo "  -d, --dir <dir>       access given directory read only"
            echo "  -p, --package <pkg>   install extra debian packages"
            echo "  -c, --cmd <command>   execute commands as root in docker"
            echo "  -w, --wait            on error keep docker container and wait for enter"
            echo
            echo "  The option -i must be after -m, because mode sets a new default image"
            echo
            echo "  The options -r -k -e -d -p -c can be repeated several times."
            echo
            echo "  The options -r -p -c allow an if-then-else contruct"
            echo "  depending on the operating system:"
            echo "    <os>:::<A>:::<B>"
            echo "    <os>:::<A>"
            echo "  Read as: On linux type <os> use <A> else use <B>"
            echo "  That means: If the distributer ID or codename in lsb_release"
            echo "  matches regular expression <os>, then <A> is replaced, else <B> is replaced."
            echo "  The three colons are for splitting <os> from <A> and <B> part."
            echo "  E.g.: Install package curl on wheezy and npm on olter systems:"
            echo "    $0 -p Debian|precise:::curl:::npm"
            echo
            echo "EXAMPLE:"
            echo
            echo "$0 -i mwaeckerlin/ubuntu:trusty-i386 \\"
            echo "                     -t deb \\"
            echo "                     -e ANDROID_HOME=/opt/local/android \\"
            echo "                     -d /opt/local/android \\"
            echo "                     -r universe \\"
            echo "                     -r https://dev.marc.waeckerlin.org/repository \\"
            echo "                     -k https://dev.marc.waeckerlin.org/repository/PublicKey \\"
            echo "                     -p mrw-c++"
            echo
            exit 0
            ;;
        (-m|--mode) shift;
            mode="$1"
            case "$mode" in
                (apt) img="ubuntu:latest";;
                (yum) img="centos:latest";;
                (*)
                    echo "**** ERROR: unknown mode '$1', try --help" 1>&2
                    exit 1
                    ;;
            esac
            ;;
        (-i|--image) shift;
            img="$1"
            ;;
        (-t|--targets) shift;
            targets="$1"
            ;;
        (-r|--repo) shift;
            repos+=("$1")
            ;;
        (-k|--key) shift;
            keys+=("$1")
            ;;
        (-e|--env) shift;
            envs+=("-e $1")
            ;;
        (-d|--dirs) shift;
            dirs+=("-v $1:$1:ro")
            ;;
        (-p|--package) shift;
            packages+=("$1")
            ;;
        (-c|--cmd) shift;
            commands+=("$1")
            ;;
        (-w|--wait)
            wait=1
            ;;
        (*)
            echo "**** ERROR: unknown option '$1', try --help" 1>&2
            exit 1
            ;;
    esac
    if test $# -eq 0; then
        echo "**** ERROR: missing value, try --help" 2>61
        exit 1
    fi
    shift
done

function traperror() {
    set +x
    local DOCKER_ID="$1"
    local err=($2) # error status
    local line="$3" # LINENO
    local linecallfunc="$4" 
    local command="$5"
    local funcstack="$6"
    for e in ${err[@]}; do
        if test -n "$e" -a "$e" != "0"; then
            echo "<---"
            echo "ERROR: line $line - command '$command' exited with status: $e (${err[@]})"
            if [ "${funcstack}" != "main" -o "$linecallfunc" != "0" ]; then
                echo -n "   ... Error at ${funcstack} "
                if [ "$linecallfunc" != "" ]; then
                    echo -n "called at line $linecallfunc"
                fi
                echo
            fi
            if [ "$wait" -eq 1 ]; then
                echo "  ... now you can access the docker container:"
                echo "      docker exec -u $(id -u) -it ${DOCKER_ID} bash"
                echo -n "  ... press enter to cleanup: "
                read
            fi
            echo -n "   ... cleanup docker: "
            docker rm -f "${DOCKER_ID}"
            echo "returning status: $e"
            echo "--->"
            exit $e
        fi
    done
    if [ "$wait" -eq 1 ]; then
        echo "  ... now you can access the docker container:"
        echo "      docker exec -u $(id -u) -it ${DOCKER_ID} bash"
        echo -n "  ... press enter to cleanup: "
        read
    fi
    echo -n "   SUCCESS ... cleanup docker: "
    docker rm -f "${DOCKER_ID}"
    exit 0
}

function ifthenelse() {
    arg="$1"
    shift
    cmd="$*"
    if test "${arg/:::/}" = "${arg}"; then
        docker exec ${DOCKER_ID} bash -c "${cmd//ARG/${arg}}"
    else
        os="${arg%%:::*}"
        thenpart="${arg#*:::}"
        if test "${thenpart/:::/}" = "${thenpart}"; then
            docker exec ${DOCKER_ID} bash -c 'os="'$os'"; if [[ "$(lsb_release -is)-$(lsb_release -cs)-$(dpkg --print-architecture)" =~ ${os} ]]; then '"${cmd//ARG/${thenpart}}"'; fi'
        else
            elsepart="${thenpart##*:::}"
            thenpart="${thenpart%:::*}"
            if test -n "${thenpart}"; then
                docker exec ${DOCKER_ID} bash -c 'os="'$os'"; if [[ "$(lsb_release -is)-$(lsb_release -cs)-$(dpkg --print-architecture)" =~ ${os} ]]; then '"${cmd//ARG/${thenpart}}"'; else '"${cmd//ARG/${elsepart}}"'; fi'
            else
                docker exec ${DOCKER_ID} bash -c 'os="'$os'"; if [[ "$(lsb_release -is)-$(lsb_release -cs)-$(dpkg --print-architecture)" =~ ${os} ]]; then true; else '"${cmd//ARG/${elsepart}}"'; fi'
            fi    
        fi
    fi
}

set -x

docker pull $img
DOCKER_ID=$(docker run -d ${dirs[@]} ${envs[@]} -e HOME="${HOME}" -w /workdir $img sleep infinity)
trap 'traperror '"${DOCKER_ID}"' "$? ${PIPESTATUS[@]}" $LINENO $BASH_LINENO "$BASH_COMMAND" "${FUNCNAME[@]}" "${FUNCTION}"' SIGINT INT TERM EXIT
case $mode in
    (apt)
        OPTIONS='-o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew -y --force-yes --no-install-suggests --no-install-recommends'
        for f in 'libpam-systemd:amd64' 'policykit*' 'colord'; do
            docker exec ${DOCKER_ID} bash -c "echo 'Package: $f' >> /etc/apt/preferences"
            docker exec ${DOCKER_ID} bash -c "echo 'Pin-Priority: -100' >> /etc/apt/preferences"
            docker exec ${DOCKER_ID} bash -c "echo >> /etc/apt/preferences"
        done
        docker exec ${DOCKER_ID} apt-get update ${OPTIONS}
        docker exec ${DOCKER_ID} apt-get upgrade ${OPTIONS}
        docker exec ${DOCKER_ID} apt-get install ${OPTIONS} python-software-properties software-properties-common apt-transport-https dpkg-dev lsb-release || \
            docker exec ${DOCKER_ID} apt-get install ${OPTIONS} software-properties-common apt-transport-https dpkg-dev lsb-release || \
            docker exec ${DOCKER_ID} apt-get install ${OPTIONS} python-software-properties apt-transport-https dpkg-dev lsb-release;
        for repo in "${repos[@]}"; do
            ifthenelse "${repo}" "apt-add-repository ARG"
        done
        for key in "${keys[@]}"; do
            wget -O- "$key" \
                | docker exec -i ${DOCKER_ID} apt-key add -
        done
        docker exec ${DOCKER_ID} apt-get update ${OPTIONS}
        for package in "${packages[@]}"; do
            ifthenelse "${package}" "apt-get install ${OPTIONS} ARG"
        done
        for command in "${commands[@]}"; do
            ifthenelse "${command}" "ARG"
        done
        docker exec ${DOCKER_ID} ./resolve-debbuilddeps.sh
        ;;
    (yum)
        ./bootstrap.sh -t dist
        if [[ "$img" =~ "centos" ]]; then
            docker exec ${DOCKER_ID} yum install -y redhat-lsb
            docker exec -i ${DOCKER_ID} bash -c 'cat > /etc/yum.repos.d/wandisco-svn.repo' <<EOF
[WandiscoSVN]
name=Wandisco SVN Repo
EOF
            docker exec -i ${DOCKER_ID} bash -c 'echo "baseurl=http://opensource.wandisco.com/centos/$(lsb_release -sr | sed '"'"'s,[^0-9].*,,'"'"')/svn-'$(svn --version | head -1 | sed 's,[^0-9]*\([0-9]\+\.[0-9]\+\).*,\1,')'/RPMS/$(uname -i)/" >> /etc/yum.repos.d/wandisco-svn.repo'
            docker exec -i ${DOCKER_ID} bash -c 'cat >> /etc/yum.repos.d/wandisco-svn.repo' <<EOF
enabled=1
gpgcheck=0
EOF
        fi
        docker exec ${DOCKER_ID} yum install -y rpm-build 
        docker exec ${DOCKER_ID} groupadd -g $(id -g) build
        docker exec ${DOCKER_ID} useradd -g $(id -g) -u $(id -u) build
        docker exec ${DOCKER_ID} ./resolve-rpmbuilddeps.sh || true
        ;;
esac
docker exec -u $(id -u):$(id -g) ${DOCKER_ID} ./bootstrap.sh -t "${targets}"
