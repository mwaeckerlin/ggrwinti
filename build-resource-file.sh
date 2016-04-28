#! /bin/bash -ex

## @id $Id$

## build resource.qrc file from a resource directory
##
## Argument: $1: resource path (default: resources)
## Result: file named <resource-path>.qrc (default: resources.qrc)
##
## Call:
##
##   cd src
##   ../build-resource-file.sh

##       1         2         3         4         5         6         7         8
## 45678901234567890123456789012345678901234567890123456789012345678901234567890

RESOURCES=${1:-resources}
TARGET=${RESOURCES}.qrc

test -d ${RESOURCES}

echo "<RCC>" > ${TARGET}
for d in $(find resources -mindepth 1 -type d); do
    echo "  <qresource prefix=\"${d#${RESOURCES}/}\">" >> ${TARGET}
    for f in $(find $d -mindepth 1 -maxdepth 1 -type f); do
        echo "    <file alias=\"${f##*/}\">$f</file>" >> ${TARGET}
    done
    echo "  </qresource>" >> ${TARGET}
done
echo "</RCC>" >> ${TARGET}
