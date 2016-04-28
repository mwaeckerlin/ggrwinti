#!/bin/bash -ex

## @id $Id$
##
## Create Mac OS-X App Bundle from built file
##
## Parameters:
##  $1: name of the app-target
##  $2: name of the project
##  $3: installation source
##
##       1         2         3         4         5         6         7         8
## 45678901234567890123456789012345678901234567890123456789012345678901234567890

if test "$(uname -s)" != "Darwin"; then
    echo "**** ERROR: run on Mac OS-X: $0"
    exit 1
fi
test -n "$1"
test -n "$2"
test -d "$3"
target="$(pwd)/${1}/Contents/MacOS"

# Step 1: create and fill app directory structure
mkdir -p ${1}/Contents/{Resources,MacOS}
! test -d ${3}/bin || \
     find ${3}/bin -mindepth 1 -maxdepth 1 -exec mv {} ${1}/Contents/MacOS/ \;
executablefile=$(ls -1 ${1}/Contents/MacOS/ | head -1)
! test -d ${3}/lib || \
    find ${3}/lib -mindepth 1 -maxdepth 1 -exec mv {} ${1}/Contents/MacOS/ \;
! test -d ${3}/share/${2} || \
    find ${3}/share/${2} -mindepth 1 -maxdepth 1 -exec mv {} ${1}/Contents/Resources/ \;
! test -d ${3}/share/${2} || rmdir ${3}/share/${2}
! test -d ${3}/share || \
    find ${3}/share -mindepth 1 -maxdepth 1 -exec mv {} ${1}/Contents/Resources/ \;
! test -d ${3}/bin || rmdir ${3}/bin
! test -d ${3}/lib || rmdir ${3}/lib
! test -d ${3}/share || rmdir ${3}/share
! test -d ${3} || \
    find ${3} -mindepth 1 -maxdepth 1 -exec mv {} ${1}/Contents/Resources/ \;
! test -d ${3} || rmdir ${3}
! test -d ${1}/tmp || rm -r ${1}/tmp

# Step 2: copy qt plugins, if necessary
for f in ${QT_PLUGINS}; do
    test -d ${target}/${f} \
        || cp -r ${QT_PLUGIN_PATH}/${f} ${target}/${f} \
        || exit 1
done

# Step 3: resolve all library dependencies
found=1
oldpath="$(pwd)"
while [ $found -ne 0 ]; do
    found=0
    cd "${target}"
    for file in $(find . -type f); do
        for lib in $(otool -L ${file} | tail -n +2 \
            | egrep '/opt/local/|'"${HOME}" \
            | grep -v $file | awk '{print $1}'); do
            found=1
            test -f ${lib##*/} \
                || ( \
                cp ${lib} . \
                && chmod u+w ${lib##*/} \
                ) \
                || exit 1
            install_name_tool -change ${lib} \
                @executable_path/${lib##*/} ${file} \
                || exit 1
        done
    done
done
cd ${oldpath}

# Step 4: if necessary, install qt_menu.nib
if test -n "${QTDIR}"; then
    MENU_NIB=$(find ${QTDIR} -name .svn -o -name .git -prune -o -name qt_menu.nib -print \
               | head -1)
    if test -e "${MENU_NIB}"; then
        rsync -r "${MENU_NIB}" ${1}/Contents/Resources/
        test -d ${1}/Contents/Resources/qt_menu.nib
    fi
fi

# Step 5: copy or create info.plist
infoplist=$(find ${1}/Contents/Resources -name Info.plist)
if test -f "${infoplist}"; then
    mv "${infoplist}" ${1}/Contents/Info.plist
else
    cat > ${1}/Contents/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>CFBundleIdentifier</key>
    <string>${2}</string>
    <key>CFBundleExecutable</key>
    <string>${executablefile##/}</string>
  </dict>
</plist>
EOF
fi
