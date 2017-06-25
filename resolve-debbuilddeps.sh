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
    if ${SUDO} apt-get -y install $*; then
        return 0
    else
        return 1
    fi
}

TO_INSTALL=
DEPS=

if test -e debian/control.in -a ! -e debian/control; then
    for f in $(sed -n 's, *AX_\(DEB\|ALL\)_DEPEND_IFEXISTS(\([^)]*\)).*,\2,p' configure.ac); do
        if test -n "$(${DO} apt-cache policy -q ${f})" && ((! $(${DO} apt-cache policy ${f} 2>&1 | grep -q 'N: Unable to locate package')) && (! ${DO} dpkg -l "${f}")); then
            DEPS+=" ${f}"
        fi
    done
    for f in $(sed -n 's, *AX_\(DEB\|ALL\)_DEPEND_IFEXISTS_DEV(\([^)]*\)).*,\2,p' configure.ac); do
        if test -n "$(${DO} apt-cache policy -q ${f}-dev)" && ((! $(${DO} apt-cache policy ${f}-dev 2>&1 | grep -q 'N: Unable to locate package')) && (! ${DO} dpkg -l "${f}-dev")); then
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
    if test ${pa//|/} = ${pa}; then
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

echo "**** Success: All Dependencies Resolved"
