#! /bin/bash -ex

## @id $Id$

## Resolve Debian Build Dependencies
## Installs all the required packages
## Call: ./resolve-debbuilddeps 'name of build schroot'
## e.g. call: ./resolve-debbuilddeps trusty_amd64

##       1         2         3         4         5         6         7         8
## 45678901234567890123456789012345678901234567890123456789012345678901234567890

SCHROOTNAME="$1"
if test -n "${SCHROOTNAME}"; then
  DO="schroot -c "${SCHROOTNAME}" --"
  SUDO="schroot -c "${SCHROOTNAME}" -u root -d / --"
else
  DO=""
  if grep -q '/docker' /proc/1/cgroup; then
      SUDO=""
  else
      SUDO="sudo"
  fi
fi

function install() {
    if ${SUDO} apt-get install -y --force-yes --no-install-suggests --no-install-recommends $*; then
        return 0
    else
        return 1
    fi
}

TO_INSTALL=
DEPS=

if test -e debian/control.in -a ! -e debian/control; then
    function pkg_exists() {
        test -n "$(${DO} apt-cache policy -q ${1})"
    }
    function AX_PKG_CHECK() {
        local DEV_DEB_DIST_PKG=
        local DEV_DIST_PKG=
        local pkg=
        eval $4
        if test -z "$2"; then
            pkg=$1
        else
            pkg=$2
        fi
        pkg=${DEV_DEB_DIST_PKG:-${DEV_DIST_PKG:-${pkg}}-dev}
        if pkg_exists "${pkg}"; then
            echo $pkg
        fi
    }
    function AX_PKG_REQUIRE() {
        local DEV_DEB_DIST_PKG=
        local DEV_DIST_PKG=
        local pkg=
        eval $6
        if test -z "$2"; then
            pkg=$1
        else
            pkg=$2
        fi
        if test -n "$4"; then
            for f in $pkg $4; do
                if pkg_exists "${f}-dev"; then
                    pkg=$f
                    break
                fi
            done
        fi
        echo ${DEV_DEB_DIST_PKG:-${DEV_DIST_PKG:-${pkg}}-dev}
    }
    DEPS+=" $(eval $(sed -n '/^ *AX_PKG_REQUIRE/{s,^ *\(AX_PKG_REQUIRE\) *(\(.*\)).*,\1 \2,;s.\[\([^]]*\)\],\?."\1".g;s,$,;,g;p}' configure.ac))"
    DEPS+=" $(eval $(sed -n '/^ *AX_PKG_CHECK/{s,^ *\(AX_PKG_CHECK\) *(\(.*\)).*,\1 \2,;s.\[\([^]]*\)\],\?."\1".g;s,$,;,g;p}' configure.ac))"
    for f in $(sed -n 's, *AX_\(DEB\|ALL\)_DEPEND_IFEXISTS(\([^)]*\)).*,\2,p' configure.ac); do
        if pkg_exists "${f}"; then
            DEPS+=" ${f}"
        fi
    done
    for f in $(sed -n 's, *AX_\(DEB\|ALL\)_DEPEND_IFEXISTS_DEV(\([^)]*\)).*,\2,p' configure.ac); do
        if pkg_exists "${f}-dev"; then
            DEPS+=" ${f}-dev"
        fi
    done
    for f in $(sed -n 's, *AX_\(DEB\|ALL\)\(_BUILD\)\?_DEPEND(\([^)]*\)).*,\3,p' configure.ac); do
        DEPS+=" ${f}"
    done
    for f in $(sed -n 's, *AX_\(DEB\|ALL\)\(_BUILD\)\?_DEPEND_DEV(\([^)]*\)).*,\3,p' configure.ac); do
        DEPS+=" ${f}-dev"
    done
    trap "rm debian/control" INT TERM EXIT
    sed 's,@\(\(ALL\|DEB\)_DEPEND_IFEXISTS\|\(ALL\|DEB\)_BUILD_DEPEND\|\(ALL\|DEB\)_DEPEND\)@,,g' debian/control.in | \
        sed 's,@[^@]*@, dummytext,g' > debian/control
fi

install dpkg-dev

DEPS+=" $(LANG= ${DO} dpkg-checkbuilddeps 2>&1 | sed -n '/Unmet build dependencies/ { s,.*Unmet build dependencies: ,,g; s, ([^)]*),,g; s, *| *,|,g; p}')"

for pa in ${DEPS}; do
    if test "${pa//|/}" = "${pa}"; then
        TO_INSTALL+=" ${pa}"
        continue;
    fi
    success=0
    for p in ${pa//|/ }; do
        if install ${TO_INSTALL} ${p}; then
            TO_INSTALL+=" ${p}"
            success=1
            break
        fi
    done
    if test ${success} -eq 0; then
        echo "**** Error: Installation Failed: ${pa}"
        exit 1
    fi
done

if test -n "${TO_INSTALL}" && ! install ${TO_INSTALL}; then
    echo "**** Error: Installation Failed: ${TO_INSTALL}"
    exit 1
fi

FILES="$(LANG= ${DO} dpkg-checkbuilddeps 2>&1 | sed -n '/Unmet build dependencies/ { s,.*Unmet build dependencies: ,,g; s, ([^)]*),,g; s, *| *,|,g; p}')"
if test -n "${FILES}"; then
    echo "**** ERROR: Cannot install: " $FILES
    exit 1
fi

echo "**** Success: All Dependencies Resolved"
