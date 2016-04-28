#!/bin/bash -e
if test -n "git" -a -d .git -a -e -x ; then
    git2cl > ChangeLog
fi
aclocal

automake -a
autoconf
