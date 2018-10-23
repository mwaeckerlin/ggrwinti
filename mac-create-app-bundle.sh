#!/bin/bash -ex

## @id $Id$
##
## Create Mac OS-X App Bundle from built file
##
## Parameters:
##  $1: name of the app-target
##  $2: name of the project
##  $3: package installation target
##
##       1         2         3         4         5         6         7         8
## 45678901234567890123456789012345678901234567890123456789012345678901234567890

if test "$(uname -s)" != "Darwin"; then
    echo "**** ERROR: run on Mac OS-X: $0"
    exit 1
fi

project=${2:-$(sed -n 's/ *m4_define *( *x_package_name, *\(.*\) *).*/\1/p' $(pwd)/configure.ac)}
apptarget=${1:-${project}.app}
sources=${3:-$(pwd)/tmp}
! test -e "$apptarget" || rm -rf "$apptarget"
test -n "$project"
test -d "$sources"
target="$(pwd)/${apptarget}/Contents/MacOS"

echo "Creating $apptarget for $project from $sources"

# Step 1: create and fill app directory structure
mkdir -p ${apptarget}/Contents/{Resources,MacOS}
! test -d ${sources}/bin || \
    find ${sources}/bin -mindepth 1 -maxdepth 1 -exec cp -a {} ${apptarget}/Contents/MacOS/ \;
! test -d ${sources}/scripts || \
    find ${sources}/scripts -mindepth 1 -maxdepth 1 -exec cp -a {} ${apptarget}/Contents/MacOS/ \;
executablefile=${apptarget}/Contents/MacOS/${project}
test -x $executablefile || executablefile=$(ls -1 ${apptarget}/Contents/MacOS/ | head -1)
! test -d ${sources}/lib || \
    find ${sources}/lib -mindepth 1 -maxdepth 1 -exec cp -a {} ${apptarget}/Contents/MacOS/ \;
! test -d ${sources}/share/${project} || \
    find ${sources}/share/${project} -mindepth 1 -maxdepth 1 -exec cp -a {} ${apptarget}/Contents/Resources/ \;
! test -d ${sources}/share || \
    find ${sources}/share -mindepth 1 -maxdepth 1 -name ${project} -prune -o -exec cp -a {} ${apptarget}/Contents/Resources/ \;
! test -d ${sources} || \
    find ${sources} -mindepth 1 -maxdepth 1 -name share -o -name bin -o -name lib -o -name scripts -prune -o -exec cp -a {} ${apptarget}/Contents/Resources/ \;

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
            | egrep '/usr/local/|/opt/local/|/opt/X11/|'"${HOME}" \
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
        rsync -r "${MENU_NIB}" ${apptarget}/Contents/Resources/
        test -d ${apptarget}/Contents/Resources/qt_menu.nib
    fi
fi

# Step 5: copy local or create new info.plist
if test -f Info.plist; then
    cp -a Info.plist ${apptarget}/Contents/Info.plist
else
    cat > ${apptarget}/Contents/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <qdict>
    <key>CFBundleIdentifier</key>
    <string>${project}</string>
    <key>CFBundleExecutable</key>
    <string>${executablefile##*/}</string>
  </dict>
</plist>
EOF
fi
