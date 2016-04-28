#! /bin/bash -ex

## @id $Id$

## Resolve RPM Build Dependencies
## Installs all the required packages
## Call: ./resolve-rpmbuilddeps 'name of build schroot'
## e.g. call: ./resolve-rpmbuilddeps opensuse-13.2_x86_64

##       1         2         3         4         5         6         7         8
## 45678901234567890123456789012345678901234567890123456789012345678901234567890

SCHROOTNAME="$1"
PACKAGE_NAME=$(sed -n 's/^ *m4_define(x_package_name, \(.*\)).*/\1/p' configure.ac)

if test -n "${SCHROOTNAME}"; then
    FILES=$(LANG= schroot -c ${SCHROOTNAME} -- rpmbuild -bb --clean --nobuild --define "_topdir ." --define "_sourcedir ." ${PACKAGE_NAME}.spec  2>&1 | sed -n 's, is needed by.*,,p')
    if test -n "${FILES}"; then
        schroot -c ${SCHROOTNAME} -u root -- yum install -y ${FILES} || \
            schroot -c ${SCHROOTNAME} -u root -- zypper install -y ${FILES} || \
            schroot -c ${SCHROOTNAME} -u root -- dnf install -y ${FILES}
    fi
else
    FILES=$(LANG= rpmbuild -bb --clean --nobuild --define "_topdir ." --define "_sourcedir ." ${PACKAGE_NAME}.spec 2>&1 | sed -n 's, is needed by.*,,p')
    if test -n "${FILES}"; then
        yum install -y ${FILES} || \
            zypper install -y ${FILES} || \
            dnf install -y ${FILES}
    fi
fi

echo "**** Success: All Dependencies Resolved"
