#! /bin/bash -e
set -o errtrace

# build and test everything in a fresh docker installation
myarch=$(dpkg --print-architecture)
if test "${arch}" = "amd64"; then
    myarch="amd64|i386"
fi
mode="deb"
img="mwaeckerlin/ubuntu:latest"
repos=()
keys=()
envs=("-e LANG=${LANG}" "-e HOME=${HOME}" "-e TERM=xterm" "-e DEBIAN_FRONTEND=noninteractive" "-e DEBCONF_NONINTERACTIVE_SEEN=true")
dirs=("-v $(pwd):/workdir" "-v ${HOME}/.gnupg:${HOME}/.gnupg")
packages=()
targets="all check distcheck"
commands=()
arch=$((which dpkg > /dev/null 2> /dev/null && dpkg --print-architecture) || echo amd64)
host=
flags=()
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
            echo "  -m, --mode <type>     mode: deb, rpm, win, default: ${mode}"
            echo "  -i, --image <image>   use given docker image instead of ${img}"
            echo "  -a, --arch <arch>     build for given hardware architecture"
            echo "  -t, --targets targets specify build targets, default: ${targets}"
            echo "  --host <target-arch>  host for cross compiling, e.g. i686-w64-mingw32"
            echo "  -f, --flag <flag>     add flag to ./bootstrap.sh or ./configure"
            echo "  -r, --repo <url>      add given apt repository"
            echo "  -k, --key <url>       add public key from url"
            echo "  -e, --env <var>=<val> set environment variable in docker"
            echo "  -d, --dir <dir>       access given directory read only"
            echo "  -p, --package <pkg>   install extra debian packages"
            echo "  -c, --cmd <command>   execute commands as root in docker"
            echo "  -w, --wait            on error keep docker container and wait for enter"
            echo
            echo "  The option -i must be after -m, because mode sets a new default image"
            echo "  The option -m must be after -t, because mode may be auto detected from targets"
            echo "  The option -m must be after -h, because mode may set a host"
            echo "  If target is either deb or rpm, mode is set to the same value"
            echo "  If target is win, host is set to i686-w64-mingw32"
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
                (deb|apt) img="mwaeckerlin/ubuntu:latest";;
                (rpm|zypper) img="opensuse:latest";;
                (yum) img="centos:latest";;
                (dnf) img="fedora:latest";;
                (win)
                    img="mwaeckerlin/ubuntu:latest"; host="${host:---host=i686-w64-mingw32}"
                    targets="all install"
                    flags+=("--prefix=/workdir/usr")
                    packages+=("mingw-w64")
                    ;;
                (*)
                    echo "**** ERROR: unknown mode '$1', try --help" 1>&2
                    exit 1
                    ;;
            esac
            ;;
        (-i|--image) shift;
            img="$1"
            ;;
        (-a|--arch) shift;
            arch="$1"
            ;;
        (-t|--targets) shift;
            targets="$1"
            if test "$1" = "deb" -o "$1" = "rpm"; then
                # set mode to same value
                set -- "-m" "$@"
                continue
            fi
            ;;
        (--host) shift;
            host="--host=$1"
            ;;
        (-f|--flag) shift;
            flags+=("$1")
            ;;
        (-r|--repo) shift;
            echo "OPTION: $1"
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
                echo "  ... now you can access the docker container as root or user:"
                echo "      docker exec -it ${DOCKER_ID} bash"
                echo "      docker exec -u $(id -u) -it ${DOCKER_ID} bash"
                echo -n "  ... press enter to cleanup: "
                read
            fi
            echo -n "   ... cleanup docker: "
            docker stop "${DOCKER_ID}" || true
            docker rm "${DOCKER_ID}"
            echo "returning status: $e"
            echo "--->"
            exit $e
        fi
    done
    echo -n "SUCCESS ... cleanup docker: "
    docker rm -f "${DOCKER_ID}"
    exit 0
}

function ifthenelse() {
    arg="$1"
    shift
    cmd="$*"
    DISTRIBUTOR=$(docker exec ${DOCKER_ID} lsb_release -si | sed 's, .*,,' | tr [:upper:] [:lower:])
    CODENAME=$(docker exec ${DOCKER_ID} lsb_release -cs)
    ARCH=$((docker exec ${DOCKER_ID} which dpkg > /dev/null 2> /dev/null && docker exec ${DOCKER_ID} dpkg --print-architecture) || echo amd64)
    if test "${arg/:::/}" = "${arg}"; then
        docker exec ${DOCKER_ID} bash -c "${cmd//ARG/${arg//@DISTRIBUTOR@/${DISTRIBUTOR}}}"
    else
        os="${arg%%:::*}"
        thenpart="${arg#*:::}"
        elsepart=
        if test "${thenpart/:::/}" != "${thenpart}"; then
            elsepart="${thenpart##*:::}"
            thenpart="${thenpart%%:::*}"
        fi
        if [[ "${DISTRIBUTOR}-${CODENAME}-${ARCH}" =~ ${os} ]]; then
            if test -n "${thenpart}"; then
                docker exec ${DOCKER_ID} bash -c "${cmd//ARG/${thenpart//@DISTRIBUTOR@/${DISTRIBUTOR}}}"
            fi
        else
            if test -n "${elsepart}"; then
                docker exec ${DOCKER_ID} bash -c "${cmd//ARG/${elsepart//@DISTRIBUTOR@/${DISTRIBUTOR}}}"
            fi
        fi
    fi
}

set -x

docker pull $img
DOCKER_ID=$(docker create ${dirs[@]} ${envs[@]} -w /workdir $img sleep infinity)
trap 'traperror '"${DOCKER_ID}"' "$? ${PIPESTATUS[@]}" $LINENO $BASH_LINENO "$BASH_COMMAND" "${FUNCNAME[@]}" "${FUNCTION}"' SIGINT INT TERM EXIT
if ! [[ $arch =~ $myarch ]]; then
    docker cp "/usr/bin/qemu-${arch}-static" "${DOCKER_ID}:/usr/bin/qemu-${arch}-static"
fi
docker start "${DOCKER_ID}"
if ! docker exec ${DOCKER_ID} getent group $(id -g) > /dev/null 2>&1; then
    docker exec ${DOCKER_ID} groupadd -g $(id -g) $(id -gn)
fi
if ! docker exec ${DOCKER_ID} getent passwd $(id -u) > /dev/null 2>&1; then
    docker exec ${DOCKER_ID} useradd -m -u $(id -u) -g $(id -g) -d"${HOME}" $(id -un)
fi
docker exec ${DOCKER_ID} chown $(id -u):$(id -g) "${HOME}"
case $mode in
    (deb|apt|win)
        if [[ "${img}" =~ "ubuntu" ]]; then
            docker exec ${DOCKER_ID} locale-gen ${LANG}
            docker exec ${DOCKER_ID} update-locale LANG=${LANG}
        fi
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
            ifthenelse "${repo}" "apt-add-repository 'ARG'"
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
    (rpm|yum|dnf|zypper|urpmi)
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
        INSTALL_TOOL=$((docker exec ${DOCKER_ID} test -x /usr/bin/zypper && echo zypper install -y) ||  (docker exec ${DOCKER_ID} test -x /usr/bin/dnf && echo dnf install -y) || (docker exec ${DOCKER_ID} test -x /usr/bin/yum && echo yum install -y) || (docker exec ${DOCKER_ID} test -x /usr/sbin/urpmi && echo urpmi --auto))
        if test "$INSTALL_TOOL" = "urpmi --auto"; then
            LSB_RELEASE=lsb-release
        else
            LSB_RELEASE=/usr/bin/lsb_release
        fi
        docker exec ${DOCKER_ID} ${INSTALL_TOOL} rpm-build automake libtool subversion gcc-c++ pkgconfig wget $LSB_RELEASE
        i=0
        for key in "${keys[@]}"; do
            wget -Orpm-key "$key"
            docker exec -i ${DOCKER_ID} rpm --import rpm-key
            rm rpm-key
        done
        for repo in "${repos[@]}"; do
            INSTALL_REPO=$((docker exec ${DOCKER_ID} test -x /usr/bin/zypper && echo zypper ar) || (docker exec ${DOCKER_ID} test -x /usr/bin/dnf && echo dnf config-manager --add-repo) || (docker exec ${DOCKER_ID} test -x /usr/bin/yum && echo wget -O/etc/yum.repos.d/additional$i.repo) || (docker exec ${DOCKER_ID} test -x /usr/sbin/urpmi && echo false))
            ifthenelse "${repo}" "${INSTALL_REPO} 'ARG'"
            ((++i))
        done
        for package in "${packages[@]}"; do
            ifthenelse "${package}" "${INSTALL_TOOL} ARG"
        done
        for command in "${commands[@]}"; do
            ifthenelse "${command}" "ARG"
        done
        docker exec ${DOCKER_ID} ./resolve-rpmbuilddeps.sh
        ;;
esac
FLAGS=()
for f in "${flags[@]}"; do
    FLAGS+=($(ifthenelse "$f" "echo 'ARG'"))
done
          
docker exec -u $(id -u):$(id -g) ${DOCKER_ID} ./bootstrap.sh -t "${targets}" ${host} "${FLAGS[@]}"
