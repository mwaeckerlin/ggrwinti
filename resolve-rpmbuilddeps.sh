#! /bin/bash -ex

## @id $Id$

## Resolve RPM Build Dependencies
## Installs all the required packages
## Call: ./resolve-rpmbuilddeps 'name of build schroot'
## e.g. call: ./resolve-rpmbuilddeps opensuse-13.2_x86_64

##       1         2         3         4         5         6         7         8
## 45678901234567890123456789012345678901234567890123456789012345678901234567890

INSTALL_TOOL=${INSTALL_TOOL:-$((test -x /usr/bin/zypper && echo zypper install -y) ||  (test -x /usr/bin/dnf && echo dnf install -y) || (test -x /usr/bin/yum && echo yum install -y) || (test -x /usr/sbin/urpmi && echo urpmi --auto))}
SCHROOTNAME="$1"
PACKAGE_NAME=$(sed -n 's/^ *m4_define(x_package_name, \(.*\)).*/\1/p' configure.ac)

TRAP_CMD="sleep ${SLEEP:-0};"
DEPS=
for f in BUILD BUILDROOT RPMS SPECS SRPMS; do
  if ! test -d $f; then
      TRAP_CMD+="rm -rf $f;"
      mkdir $f
  fi
done
if test -e ${PACKAGE_NAME}.spec.in -a ! -e ${PACKAGE_NAME}.spec; then
    function pkg_exists() {
        (test -x /usr/bin/zypper && zypper search -x "$1" 1>&2 > /dev/null) || \
            (test -x /usr/bin/dnf && dnf list -q "$1" 1>&2 > /dev/null) || \
            (test -x /usr/bin/yum && yum list -q "$1" 1>&2 > /dev/null) || \
            (test -x /usr/sbin/urpmq && urpmq "$1" 1>&2 > /dev/null)
    }
    function AX_PKG_CHECK() {
        local DEV_RPM_DIST_PKG=
        local DEV_DIST_PKG=
        local pkg=
        eval $4
        if test -z "$2"; then
            pkg=$1
        else
            pkg=$2
        fi
        pkg=${DEV_RPM_DIST_PKG:-${DEV_DIST_PKG:-${pkg}}-devel}
        if pkg_exists "${pkg}"; then
            echo ${pkg}
        fi
    }
    function AX_PKG_REQUIRE() {
        local DEV_RPM_DIST_PKG=
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
                if pkg_exists "${f}-devel"; then
                    pkg=$f
                    break
                fi
            done
        fi
        echo ${DEV_RPM_DIST_PKG:-${DEV_DIST_PKG:-${pkg}}-devel}
    }
    DEPS+=" $(eval $(sed -n '/^ *AX_PKG_REQUIRE/{s,^ *\(AX_PKG_REQUIRE\) *(\(.*\)).*,\1 \2,;s.\[\([^]]*\)\],\?."\1".g;s,$,;,g;p}' configure.ac))"
    DEPS+=" $(eval $(sed -n '/^ *AX_PKG_CHECK/{s,^ *\(AX_PKG_CHECK\) *(\(.*\)).*,\1 \2,;s.\[\([^]]*\)\],\?."\1".g;s,$,;,g;p}' configure.ac))"
    for f in $(sed -n 's, *AX_\(RPM\|ALL\)_DEPEND_IFEXISTS(\([^)]*\)).*,\2,p' configure.ac); do
        if pkg_exists "${f}"; then
            DEPS+=" ${f}"
        fi
    done
    for f in $(sed -n 's, *AX_\(RPM\|ALL\)_DEPEND_IFEXISTS_DEV(\([^)]*\)).*,\2,p' configure.ac); do
        if pkg_exists "${f}-devel"; then
            DEPS+=" ${f}-devel"
        fi
    done
    for f in $(sed -n 's, *AX_\(RPM\|ALL\)\(_BUILD\)\?_DEPEND(\([^)]*\)).*,\3,p' configure.ac); do
        DEPS+=" ${f}"
    done
    for f in $(sed -n 's, *AX_\(RPM\|ALL\)\(_BUILD\)\?_DEPEND_DEV(\([^)]*\)).*,\3,p' configure.ac); do
        DEPS+=" ${f}-devel"
    done
    TRAP_CMD+="rm ${PACKAGE_NAME}.spec;"
    trap "${TRAP_CMD}" INT TERM EXIT
    sed 's,@\(\(ALL\|RPM\)_DEPEND_IFEXISTS\|\(ALL\|RPM\)_BUILD_DEPEND\|\(ALL\|RPM\)_DEPEND\)@,,g' ${PACKAGE_NAME}.spec.in | \
        sed 's,@[^@]*@,dummytext,g' > ${PACKAGE_NAME}.spec
fi

TGZFILE=$(sed -n '/^Name: */{s///;h};/^Version: */{s///;H;x;s/\n/-/;s/$/.tar.gz/;p}' ${PACKAGE_NAME}.spec)
if ! test -e $TGZFILE; then
    TRAP_CMD+="rm ${TGZFILE};"
    trap "${TRAP_CMD}" INT TERM EXIT
    touch $TGZFILE
fi

if test -n "${SCHROOTNAME}"; then
    FILES=$(LANG= schroot -c ${SCHROOTNAME} -- rpmbuild -bb --clean --nobuild --define "_topdir ." --define "_sourcedir ." ${PACKAGE_NAME}.spec  2>&1 | sed -n 's, is needed by.*,,p')
    if test -n "${FILES// /}${DEPS// /}"; then
        schroot -c ${SCHROOTNAME} -u root -- ${INSTALL_TOOL}  ${FILES} ${DEPS}
    fi
else
    FILES=$(LANG= rpmbuild -bb --clean --nobuild --define "_topdir ." --define "_sourcedir ." ${PACKAGE_NAME}.spec 2>&1 | sed -n 's, is needed by.*,,p')
    if test -n "${FILES// /}${DEPS// /}"; then
        ${INSTALL_TOOL} ${FILES} ${DEPS}
    fi
fi

if test -n "${SCHROOTNAME}"; then
    FILES=$(LANG= schroot -c ${SCHROOTNAME} -- rpmbuild -bb --clean --nobuild --define "_topdir ." --define "_sourcedir ." ${PACKAGE_NAME}.spec  2>&1 | sed -n 's, is needed by.*,,p')
else
    FILES=$(LANG= rpmbuild -bb --clean --nobuild --define "_topdir ." --define "_sourcedir ." ${PACKAGE_NAME}.spec 2>&1 | sed -n 's, is needed by.*,,p')
fi
if test -n "${FILES// /}"; then
    echo "**** ERROR: Cannot install: " $FILES
    exit 1
fi

echo "**** Success: All Dependencies Resolved"
