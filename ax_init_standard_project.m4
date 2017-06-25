## @id $Id: ax_init_standard_project.m4 204 2016-09-29 18:29:53Z marc $

##       1         2         3         4         5         6         7         8
## 45678901234567890123456789012345678901234567890123456789012345678901234567890

# m4_esyscmd_s does not exist on centos 5 and 6
m4_define([mrw_esyscmd_s], [m4_normalize(m4_esyscmd([$1]))])

# define least version number from subversion's revision number:
# it is taken modulo 256 due to a bug on Apple's MaxOSX
m4_define(x_least, m4_ifdef([x_least_fix], [x_least_fix],
  m4_ifdef([x_least_diff],
    mrw_esyscmd_s([
      VCS_REVISION="ERROR-UNDEFINED-REVISION-to-be-built-in-subdirectory-of-checkout"
      for path in . .. ../.. ../../..; do
        if test -d ${path}/.svn; then
          (cd $path; svn upgrade 1>&2 > /dev/null || true)
          VCS_REVISION=$(LANG= svn info $path | sed -n 's/Last Changed Rev: //p')
          if test -n "${VCS_REVISION}"; then break; fi
        elif test -d ${path}/.git; then
          VCS_REVISION=$(cd ${path} > /dev/null 2/dev/null; git rev-list --all --count)
          if test -n "${VCS_REVISION}"; then break; fi
        fi
      done
      echo $ECHO_N $(($VCS_REVISION))
    ]),  mrw_esyscmd_s([
      VCS_REVISION="ERROR-UNDEFINED-REVISION-to-be-built-in-subdirectory-of-checkout"
      for path in . .. ../.. ../../..; do
        if test -d ${path}/.svn; then
          (cd $path; svn upgrade 1>&2 > /dev/null || true)
          VCS_REVISION=$(LANG= svn info $path | sed -n 's/Last Changed Rev: //p')
          if test -n "${VCS_REVISION}"; then break; fi
        elif test -d ${path}/.git; then
          VCS_REVISION=$(cd ${path} > /dev/null 2/dev/null; git rev-list --all --count)
          if test -n "${VCS_REVISION}"; then break; fi
        fi
      done
      # Mac does not support LEAST > 255
      echo $ECHO_N $(($VCS_REVISION%256))]))))

# define version number from subversion's revision number:
# it is taken modulo 256 due to a bug on Apple's MacOSX
# add to x_minor if revision number is > 256
m4_define(x_minor_diff, m4_ifdef([x_least_fix], 0, mrw_esyscmd_s([
  VCS_REVISION="ERROR-UNDEFINED-REVISION-to-be-built-in-subdirectory-of-checkout"
  for path in . .. ../.. ../../..; do
    if test -d ${path}/.svn; then
      (cd $path; svn upgrade 1>&2 > /dev/null || true)
      VCS_REVISION=$(LANG= svn info $path | sed -n 's/Last Changed Rev: //p')
      if test -n "${VCS_REVISION}"; then break; fi
    elif test -d ${path}/.git; then
      VCS_REVISION=$(cd ${path} > /dev/null 2/dev/null; git rev-list --all --count)
      if test -n "${VCS_REVISION}"; then break; fi
    fi;
  done
  # Mac does not support LEAST > 255
  echo $ECHO_N $(($VCS_REVISION/256))])))

# setup version number
m4_define(x_version, [x_major.m4_ifdef([x_least_diff], x_minor, m4_eval(x_minor+x_minor_diff)).m4_eval(m4_ifdef([x_least_diff], [x_least-x_least_diff], [x_least]))])

## bugreport mail address is taken from <user@host> in first line of AUTHORS
m4_define(x_bugreport, mrw_esyscmd_s([
  head -1 AUTHORS | \
    sed -n 's,.*<\([-_.a-z0-9A-Z]*@[-_.a-z0-9A-Z]*\)>.*,\1,gp'
]))

m4_include(ax_check_qt.m4)

AC_ALIAS([AC_DEFINE_DIR], [AX_DEFINE_DIR])
AC_DEFUN([AX_DEFINE_DIR], [
  prefix_NONE=
  exec_prefix_NONE=
  test "x$prefix" = xNONE && prefix_NONE=yes && prefix=$ac_default_prefix
  test "x$exec_prefix" = xNONE && exec_prefix_NONE=yes && exec_prefix=$prefix
dnl In Autoconf 2.60, ${datadir} refers to ${datarootdir}, which in turn
dnl refers to ${prefix}.  Thus we have to use `eval' twice.
  eval ax_define_dir="\"[$]$2\""
  eval ax_define_dir="\"$ax_define_dir\""
  AC_SUBST($1, "$ax_define_dir")
  AC_DEFINE_UNQUOTED($1, "$ax_define_dir", [$3])
  test "$prefix_NONE" && prefix=NONE
  test "$exec_prefix_NONE" && exec_prefix=NONE
])

# add target dependencies to an existing makefile.in
#  - parameters:
#     $1 = existing target
#     $2 = new dependency for that target
#     $3 = filename of makefile.in
AC_DEFUN([AX_ADD_MAKEFILE_TARGET_DEP], [
  sh_add_makefile_target_dep() {
    sed -i -e ':a;/^'${1}':.*\\$/{N;s/\\\n//;ta};s/^'${1}':.*$/& '${2}'/' "${srcdir}/${3}"
    if ! egrep -q "${1}:.* ${2}" "${srcdir}/${3}"; then
        echo "${1}: ${2}" >> "${srcdir}/${3}"
    fi
  }
  sh_add_makefile_target_dep "$1" "$2" "$3"
  if test "$1" != ".PHONY"; then
      sh_add_makefile_target_dep ".PHONY" "$2" "$3"
  fi
])

# Same as AC_SUBST, but adds -Dname="value" option to CPPFLAGS and a
# notz only a @name@ replacement, but also a @name_ENCODED@ one to be
# used in code.
#  - parameters:
#     $1 = variable name
AC_DEFUN([AX_SUBST], [
  [$1]_ENCODED=$(echo "${$1}" | awk 1 ORS='\\n' | sed 's,\\n$,,')
  [$1]_ENCODED=${[$1]_ENCODED//\"/\\\"}
  [$1]_ENCODED=${[$1]_ENCODED//\'/\'\"\'\"\'}
  [$1]_ENCODED=${[$1]_ENCODED//#/\\#}
  AM_CPPFLAGS+=" '-D$1=\"${[$1]_ENCODED}\"'"
  AC_SUBST([$1])
  AC_SUBST([$1]_ENCODED)
  AC_SUBST(AM_CPPFLAGS)
])

# must be called on the right position in configure.ac
#
# configure.ac must start with:
#
# m4_define(x_package_name, YOUR_PACKAGE_NAME) # project's name
# m4_define(x_major, MAJOR_NUMBER) # project's major version
# m4_define(x_minor, MINOR_NUMBER) # project's minor version
# m4_include(ax_init_standard_project.m4)
# AC_INIT(x_package_name, x_version, x_bugreport, x_package_name)
# AM_INIT_AUTOMAKE([1.9 tar-pax parallel-tests color-tests])
# AX_INIT_STANDARD_PROJECT
#
# you change nothing but: YOUR_PACKAGE_NAME, MAJOR_NUMBER, MINOR_NUMBER
#
# configures the basic environment
AC_DEFUN([AX_INIT_STANDARD_PROJECT], [
  PREFIX=$(test "$prefix" = NONE && prefix=$ac_default_prefix; eval echo "${prefix}")
  AX_SUBST(PREFIX)
  SYSCONFDIR=$(test "$prefix" = NONE && prefix=$ac_default_prefix; eval echo "${sysconfdir}")
  AX_SUBST(SYSCONFDIR)
  PKGSYSCONFDIR=$(test "$prefix" = NONE && prefix=$ac_default_prefix; eval echo "${SYSCONFDIR}/${PACKAGE_NAME}")
  AX_SUBST(PKGSYSCONFDIR)
  DATADIR=$(test "$prefix" = NONE && prefix=$ac_default_prefix; eval echo "${datadir}")
  AX_SUBST(DATADIR)
  PKGDATADIR=$(test "$prefix" = NONE && prefix=$ac_default_prefix; eval echo "${DATADIR}/${PACKAGE_NAME}")
  AX_SUBST(PKGDATADIR)
  LOCALSTATEDIR=$(test "$prefix" = NONE && prefix=$ac_default_prefix; eval echo "${localstatedir}")
  AX_SUBST(LOCALSTATEDIR)
  AC_MSG_CHECKING([target platfrom])
  UNIX=1
  MINGW=
  MACOSX=
  for h in ${target} ${target_os} ${host} ${host_os} \
           ${build} ${build_os} $(uname -s 2> /dev/null); do
    p="$h is generic Unix"
    case "$h" in
      (*mingw*)
        UNIX=; MINGW=1; p="MinGW"; break;;
      (*Darwin*|*darwin*|*rhapsody*|*macosx*)
        UNIX=; MACOSX=1; p="MacOSX"; break;;
    esac
  done
  AC_MSG_RESULT($p)
  AM_CONDITIONAL(UNIX, test "$UNIX" = "1")
  AM_CONDITIONAL(MINGW, test "$MINGW" = "1")
  AM_CONDITIONAL(MACOSX, test "$MACOSX" = "1")
  AX_SUBST(UNIX)
  AX_SUBST(MINGW)
  AX_SUBST(MACOSX)
  AM_CPPFLAGS+=" '-DMAKE_STRING(X)=\#X' '-DNAMESPACE=${PACKAGE_TARNAME//[^a-zA-Z0-9]/_}'"
  AX_SUBST(NUMBERS)
  AX_SUBST(HOME)
  if test -f README.md; then
    README=$(tail -n +3 README.md)
    DESCRIPTION=$(head -1 README.md)
  else
    README=$(tail -n +3 README)
    DESCRIPTION=$(head -1 README)
  fi
  README_ESCAPED=$(echo "$README" | sed ':a;N;$!ba;s/\n/\\n/g;s,",\\",g')
  if which pandoc 2>&1 > /dev/null; then   
    README_HTML=$(echo "$README" | pandoc -f markdown_github -t html | sed ':a;N;$!ba;s,\\\(.\),\\\\<span>\1</span>,g;s/\n/\\n/g;s,",\\",g;s,  ,\&nbsp;\&nbsp;,g')
  else
    README_HTML="${README}"
  fi
  AX_SUBST(README)
  _AM_SUBST_NOTMAKE([README])
  AX_SUBST(README_ESCAPED)
  _AM_SUBST_NOTMAKE([README_ESCAPED])
  AX_SUBST(README_HTML)
  _AM_SUBST_NOTMAKE([README_HTML])
  AX_SUBST(DESCRIPTION)
  _AM_SUBST_NOTMAKE([DESCRIPTION])
  LICENSE=$(echo $(head -1 COPYING))
  AX_SUBST(LICENSE)
  COPYING=$(<COPYING)
  AX_SUBST(COPYING)
  _AM_SUBST_NOTMAKE([COPYING])
  CHANGELOG=$(<ChangeLog)
  AC_SUBST(CHANGELOG)
  _AM_SUBST_NOTMAKE([CHANGELOG])
  DEB_CHANGELOG=$(sed '/^[[^\t]]/{h;N;d};s,\t,  ,g;/^  \* /{s,,,;H;g;s,^,  * ,;s,\n\([[^ ]]*\) *, \1\n    ,}' ChangeLog)
  if test -z "$DEB_CHANGELOG"; then
    DEB_CHANGELOG="  * see file ChangeLog and project management web site"
  fi
  AC_SUBST(DEB_CHANGELOG)
  _AM_SUBST_NOTMAKE([DEB_CHANGELOG])
  AUTHOR=$(head -1 AUTHORS)
  AUTHOR_NAME=$(echo $AUTHOR | sed 's, *[[<(]].*$,,')
  AUTHOR_URL=$(echo $AUTHOR | sed 's,.*(\(http[[^)]]*\)).*,\1,')
  AUTHOR_MAIL=$(echo $AUTHOR | sed 's,.*<\(.*@.*\)>.*,\1,')
  PACKAGER=$(gpg -K --display-charset utf-8 --lock-never 2>/dev/null | sed -n 's,uid *\(\[[ultimate\]] *\)\?,,p' | head -1)
  if test -z "${PACKAGER}"; then
    PACKAGER="$AUTHOR"
  fi
  AX_SUBST(AUTHOR)
  _AM_SUBST_NOTMAKE([AUTHOR])
  AX_SUBST(AUTHOR_NAME)
  AX_SUBST(AUTHOR_URL)
  AX_SUBST(AUTHOR_MAIL)
  AX_SUBST(PACKAGER)
  PROJECT_URL="${PROJECT_URL:-${AUTHOR_URL}/projects/${PACKAGE_NAME}}"
  SOURCE_DOWNLOAD="${SOURCE_DOWNLOAD:-${AUTHOR_URL}/downloads/${PACKAGE_NAME}}"
  AX_SUBST(PROJECT_URL)
  AX_SUBST(SOURCE_DOWNLOAD)
  VENDOR=$((lsb_release -is 2>/dev/null || echo unknown) | tr ' ' '_')
  AX_SUBST(VENDOR)
  DISTRO=$(lsb_release -sc 2>/dev/null || uname -s 2>/dev/null)
  AX_SUBST(DISTRO)
  ARCH=$((@<:@@<:@ $(uname -sm) =~ 64 @:>@@:>@ && echo amd64) || (@<:@@<:@ $(uname -sm) =~ 'i?86' @:>@@:>@ && echo i386 || uname -sm))
  AX_SUBST(ARCH)
  DISTRIBUTOR=$(lsb_release -si 2>/dev/null || uname -s 2>/dev/null)
  case "${DISTRIBUTOR// /-}" in
    (Ubuntu) UBUNTU=1; AX_SUBST(UBUNTU);;
    (Debian) DEBIAN=1; AX_SUBST(DEBIAN);;
    (SUSE-LINUX) SUSE=1; AX_SUBST(SUSE);;
    (Fedora) FEDORA=1; AX_SUBST(FEDORA);;
    (Centos) CENTOS=1; AX_SUBST(CENTOS);;
  esac
  AX_SUBST(DISTRIBUTOR)
  BUILD_NUMBER=${BUILD_NUMBER:-1}
  AX_SUBST(BUILD_NUMBER)
  BUILD_DATE=$(LANG= date +"%a, %d %b %Y %H:%M:%S %z")
  AX_SUBST(BUILD_DATE)
  if test -f "${PACKAGE_NAME}.desktop.in"; then
     PACKAGE_DESKTOP="${PACKAGE_NAME}.desktop"
  fi
  AX_SUBST(PACKAGE_DESKTOP)
  if test -f "${PACKAGE_NAME}-logo.png"; then
     PACKAGE_LOGO="${PACKAGE_NAME}-logo.png"
  fi
  AX_SUBST(PACKAGE_LOGO)
  if test -f "${PACKAGE_NAME}-icon.svg"; then
     PACKAGE_ICON="${PACKAGE_NAME}-icon.svg"
  elif test -f "${PACKAGE_NAME}-icon.png"; then
     PACKAGE_ICON="${PACKAGE_NAME}-icon.png"
  elif test -f "${PACKAGE_NAME}.svg"; then
     PACKAGE_ICON="${PACKAGE_NAME}.svg"
  elif test -f "${PACKAGE_NAME}.png"; then
     PACKAGE_ICON="${PACKAGE_NAME}.png"
  fi
  AX_SUBST(PACKAGE_ICON)

  AC_ARG_ENABLE(pedantic,
    [AS_HELP_STRING([--enable-pedantic],
                    [enable all warnings and checks, abort on warnings])],
    [have_pedantic="$enableval"; test "$enableval" = "yes" &&  \
       AM_CXXFLAGS="${AM_CXXFLAGS:-} -pedantic-errors -Wall -W -Wfloat-equal -Wundef -Wendif-labels -Wpointer-arith -Wcast-align -Wwrite-strings -Wconversion -Wsign-compare -Wmissing-format-attribute -Wno-multichar -Wpacked -Wredundant-decls -Werror -Wshadow -Wcast-qual -Wno-ctor-dtor-privacy"])
  dnl problem in libs: -Wshadow -Wcast-qual
  dnl auto.hpp: -Wno-ctor-dtor-privacy (removed)
  AM_CONDITIONAL(PEDANTIC, test "$enableval" = "yes")
  if test "$have_pedantic" == "yes"; then
    AC_MSG_NOTICE([Pedantic compile mode enabled!
     - all warnings for GNU g++ are enabled
     - all warnings result in an error
     - doxygen warnings are treated as error too]); fi

  AC_ARG_ENABLE(debug,
    [AS_HELP_STRING([--enable-debug],
                    [compile for debugger])],
    [have_debug="$enableval"], [have_debug="no"])
  AM_CONDITIONAL(DEBUG, test "$enableval" = "yes")
  if test "$have_debug" == "yes"; then
    AC_MSG_NOTICE([Debug compile mode enabled]);
    AM_CPPFLAGS="${AM_CPPFLAGS} -DDEBUG"
    AM_CXXFLAGS="${AM_CXXFLAGS:-} -ggdb3 -O0"
    AM_LDFLAGS="${AM_LDFLAGS} -ggdb3 -O0"
  else
    AM_CPPFLAGS="${AM_CPPFLAGS} -DQT_NO_DEBUG_OUTPUT -DQT_NO_DEBUG"
  fi

  AC_ARG_WITH(gcov,
    [AS_HELP_STRING([--with-gcov=FILE],
                    [enable gcov, set gcov file (defaults to gcov)])],
    [GCOV="$enableval"], [GCOV="no"])
  AM_CONDITIONAL(COVERAGE, test "$GCOV" != "no")
  if test "$GCOV" != "no"; then
    if test "$GCOV" == "yes"; then
      GCOV=gcov
    fi
    AC_CHECK_PROG(has_gcov, [$GCOV], [yes], [no])
    if test "$has_gcov" != "yes"; then
      AC_MSG_ERROR([gcov: program $GCOV not found])
    fi
    AC_MSG_NOTICE([Coverage tests enabled, using ${GCOV}]);
    AM_CXXFLAGS="${AM_CXXFLAGS:-} -O0 --coverage -fprofile-arcs -ftest-coverage"
    AM_LDFLAGS="${AM_LDFLAGS} -O0 --coverage -fprofile-arcs"
    AX_SUBST(GCOV)
  fi
  
  if test -f ${PACKAGE_NAME}.desktop.in; then
    AC_CONFIG_FILES([${PACKAGE_NAME}.desktop])
  fi

  AC_CONFIG_FILES([makefile])
  AX_ADD_MAKEFILE_TARGET_DEP([clean-am], [clean-standard-project-targets], [makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([distclean-am], [distclean-standard-project-targets], [makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([maintainer-clean-am], [maintainer-clean-standard-project-targets], [makefile.in])
  test -f makefile.in && cat >> makefile.in <<EOF
#### Begin: Appended by $0
EXTRA_DIST += bootstrap.sh ax_init_standard_project.m4 ax_cxx_compile_stdcxx_11.m4 \
              ax_check_qt.m4 resolve-debbuilddeps.sh resolve-rpmbuilddeps.sh \
              build-resource-file.sh mac-create-app-bundle.sh

clean-standard-project-targets:
	-rm -rf \${PACKAGE_NAME}-\${PACKAGE_VERSION}
	-rm \${PACKAGE_TARNAME}-\${PACKAGE_VERSION}.tar.gz
distclean-standard-project-targets:
	-rm -r autom4te.cache
	-rm aclocal.m4 config.guess config.sub configure depcomp compile install-sh ltmain.sh makefile missing mkinstalldirs test-driver
maintainer-clean-standard-project-targets:
	-rm makefile.in
#### End: $0
EOF
])

# use this in configure.ac to support C++
AC_DEFUN([AX_USE_CXX], [
  m4_include(ax_cxx_compile_stdcxx_11.m4)
  AC_LANG(C++)
  AX_CXX_COMPILE_STDCXX_14(noext, optional)
  AC_PROG_CXX
  AC_PROG_CPP

  AC_CONFIG_FILES([src/makefile])
  
  AM_CPPFLAGS+=' -I ${top_srcdir}/src -I ${top_builddir}/src -I ${srcdir} -I ${builddir}'
  AM_LDFLAGS+=' -L ${top_srcdir}/src -L ${top_builddir}/src'

  # Get rid of those stupid -g -O2 options!
  CXXFLAGS="${CXXFLAGS//-g -O2/}"
  CFLAGS="${CFLAGS//-g -O2/}"

# pass compile flags to make distcheck
  AM_DISTCHECK_CONFIGURE_FLAGS="CXXFLAGS='${CXXFLAGS}' CPPFLAGS='${CPPFLAGS}' CFLAGS='${CFLAGS}' LDFLAGS='${LDFLAGS}'"
  AC_SUBST(AM_DISTCHECK_CONFIGURE_FLAGS)

  AC_SUBST(AM_CXXFLAGS)
  AC_SUBST(AM_CPPFLAGS)
  AC_SUBST(AM_LDFLAGS)
  AX_ADD_MAKEFILE_TARGET_DEP([maintainer-clean-am], [maintainer-clean-cxx-targets], [src/makefile.in])
  test -f src/makefile.in && cat >> src/makefile.in <<EOF
#### Begin: Appended by $0
%.app: %
	-rm -r [\$][@]
	\$(MAKE) DESTDIR=[\$][\$](pwd)/[\$][@]/tmp install
	QTDIR="\${QTDIR}" \
	QT_PLUGINS="\${QT_PLUGINS}" \
	QT_PLUGIN_PATH="\${QT_PLUGIN_PATH}" \
	  \${top_builddir}/mac-create-app-bundle.sh \
	    [\$][@] [\$][<] [\$][\$](pwd)/[\$][@]/tmp\${prefix}

maintainer-clean-cxx-targets:
	-rm makefile.in
#### End: $0
EOF
])

# use this in configure.ac to support old school C
AC_DEFUN([AX_USE_C], [
  AC_LANG(C)
  AC_PROG_CC
  AC_PROG_CPP

  AC_CONFIG_FILES([src/makefile])
  
  AM_CPPFLAGS+=' -I ${top_srcdir}/src -I ${top_builddir}/src -I ${srcdir} -I ${builddir}'
  AM_LDFLAGS+=' -L ${top_srcdir}/src -L ${top_builddir}/src'

  # Get rid of those stupid -g -O2 options!
  CXXFLAGS="${CXXFLAGS//-g -O2/}"
  CFLAGS="${CFLAGS//-g -O2/}"

  # pass compile flags to make distcheck
  AM_DISTCHECK_CONFIGURE_FLAGS="CFLAGS='${CFLAGS}' CPPFLAGS='${CPPFLAGS}' CFLAGS='${CFLAGS}' LDFLAGS='${LDFLAGS}'"
  AC_SUBST(AM_DISTCHECK_CONFIGURE_FLAGS)

  AC_SUBST(AM_CFLAGS)
  AC_SUBST(AM_CPPFLAGS)
  AC_SUBST(AM_LDFLAGS)
  AX_ADD_MAKEFILE_TARGET_DEP([maintainer-clean-am], [maintainer-clean-c-targets], [src/makefile.in])
  test -f src/makefile.in && cat >> src/makefile.in <<EOF
#### Begin: Appended by $0
%.app: %
	-rm -r [\$][@]
	\$(MAKE) DESTDIR=[\$][\$](pwd)/[\$][@]/tmp install
	  \${top_builddir}/mac-create-app-bundle.sh \
	    [\$][@] [\$][<] [\$][\$](pwd)/[\$][@]/tmp\${prefix}

maintainer-clean-c-targets:
	-rm makefile.in
#### End: $0
EOF
])

# use this in configure.ac to support tests without CppUnit
AC_DEFUN([AX_BUILD_TEST], [
  AC_CONFIG_FILES([test/makefile])
  AX_ADD_MAKEFILE_TARGET_DEP([maintainer-clean-am], [maintainer-clean-test-targets], [test/makefile.in])
  test -f test/makefile.in && cat >> test/makefile.in <<EOF
#### Begin: Appended by $0
maintainer-clean-test-targets:
	-rm makefile.in
#### End: $0
EOF
])

# use this in configure.ac to support CppUnit for C++ unit tests
AC_DEFUN([AX_USE_CPPUNIT], [
  PKG_CHECK_MODULES(CPPUNIT, cppunit, [have_cppunit="yes"], [have_cppunit="no"])
  # infos and warnings
  if test "$have_cppunit" = "no"; then
    AC_MSG_WARN([Missing cppunit development library!
     - you cannot check the project using "make check"
     - everything else works perfectly]); fi
  AX_BUILD_TEST
])

# use this in configure.ac to support C++ examples
AC_DEFUN([AX_BUILD_EXAMPLES], [
  AC_CONFIG_FILES([examples/makefile])
  AX_ADD_MAKEFILE_TARGET_DEP([maintainer-clean-am], [maintainer-clean-example-targets], [examples/makefile.in])
  test -f examples/makefile.in && cat >> examples/makefile.in <<EOF
#### Begin: Appended by $0
maintainer-clean-example-targets:
	-rm makefile.in
#### End: $0
EOF
])

# use this in configure.ac to support NodeJS
AC_DEFUN([AX_USE_NODEJS], [
  AC_PATH_PROG(ANDROID, [android], [0],
                         [${PATH}${PATH_SEPARATOR}${ANDROID_HOME}/tools])
  AC_CONFIG_FILES([nodejs/package.json])
  AC_CONFIG_FILES([nodejs/makefile])
  AX_ADD_MAKEFILE_TARGET_DEP([maintainer-clean-am], [maintainer-clean-nodejs-targets], [nodejs/makefile.in])
  test -f nodejs/makefile.in && cat >> nodejs/makefile.in <<EOF
#### Begin: Appended by $0
maintainer-clean-nodejs-targets:
	-rm makefile.in
#### End: $0
EOF
])

# use this in configure.ac to support Cordova
AC_DEFUN([AX_USE_CORDOVA], [
  AC_PATH_PROG(ANDROID, [android], [0],
                         [${PATH}${PATH_SEPARATOR}${ANDROID_HOME}/tools])
  AC_PATH_PROG(CORDOVA, [cordova], [0],
                        [${PATH}${PATH_SEPARATOR}$(pwd)/node_modules/cordova/bin])
  if test ${CORDOVA} = 0; then
     AC_MSG_WARN([cordova is missing, on ubuntu install cordova-cli from repository ppa:cordova-ubuntu/ppa])
  fi
  if test ${ANDROID} = 0; then
     AC_MSG_WARN([android sdk is missing, set variable ANDROID_HOME after installation])
  fi
  AM_CONDITIONAL(HAVE_CORDOVA, [test ${CORDOVA} != 0 -a ${ANDROID} != 0])
  AX_SUBST(CORDOVA)
  AC_CONFIG_FILES([cordova/makefile])
  AC_CONFIG_FILES([cordova/config.xml])
EOF
  AX_ADD_MAKEFILE_TARGET_DEP([maintainer-clean-am], [maintainer-clean-cordova-targets], [cordova/makefile.in])
  test -f cordova/makefile.in && cat >> cordova/makefile.in <<EOF
#### Begin: Appended by $0
maintainer-clean-cordova-targets:
	-rm makefile.in
#### End: $0
EOF
])

# use this in configure.ac to support HTML data for webservers
AC_DEFUN([AX_BUILD_HTML], [
  AC_CONFIG_FILES([html/makefile])
  AX_ADD_MAKEFILE_TARGET_DEP([maintainer-clean-am], [maintainer-clean-html-targets], [html/makefile.in])
  test -f html/makefile.in && cat >> html/makefile.in <<EOF
#### Begin: Appended by $0
maintainer-clean-html-targets:
	-rm makefile.in
#### End: $0
EOF
])

# use this in configure.ac to support HTML data for webservers
AC_DEFUN([AX_BUILD_HTML_NPM], [
  AC_CONFIG_FILES([html/package.json])
  AX_BUILD_HTML
])

# use this in configure.ac to support C++ libraries
AC_DEFUN([AX_USE_LIBTOOL], [
  # libtool versioning
  LIB_MAJOR=m4_eval(x_major+x_minor+x_minor_diff)
  LIB_MINOR=x_least
  LIB_LEAST=m4_eval(x_minor+x_minor_diff)
  LIB_VERSION="${LIB_MAJOR}:${LIB_MINOR}:${LIB_LEAST}"
  AM_LDFLAGS="-version-info ${LIB_VERSION}"
  AC_SUBST(AM_LDFLAGS)
  AC_SUBST(LIB_VERSION)
  AC_PROG_LIBTOOL
  AC_CONFIG_FILES([src/${PACKAGE_NAME}.pc])
  AX_ADD_MAKEFILE_TARGET_DEP([install-data-am], [install-data-libtool-pkg], [src/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([uninstall-am], [uninstall-data-am], [src/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([uninstall-data-am], [uninstall-data-libtool-pkg], [src/makefile.in])
  test -f src/makefile.in && cat >> src/makefile.in <<EOF
#### Begin: Appended by $0
install-data-libtool-pkg:
	test -d \$(DESTDIR)\${libdir}/pkgconfig || mkdir -p \$(DESTDIR)\${libdir}/pkgconfig
	chmod -R u+w \$(DESTDIR)\${libdir}/pkgconfig
	cp \${PACKAGE_NAME}.pc \$(DESTDIR)\${libdir}/pkgconfig/
uninstall-data-libtool-pkg:
	-chmod -R u+w \$(DESTDIR)\${libdir}/pkgconfig
	-rm -f \$(DESTDIR)\${libdir}/pkgconfig/\${PACKAGE_NAME}.pc
#### End: $0
EOF
])

# use this in configure.ac to support debian packages
AC_DEFUN([AX_USE_DEBIAN_PACKAGING], [
  if test -f README.md; then
    README_DEB=$(tail -n +3 README.md | sed -e 's/^ *$/./g' -e 's/^/ /g')
  else
    README_DEB=$(tail -n +3 README | sed -e 's/^ *$/./g' -e 's/^/ /g')
  fi
  AC_SUBST(README_DEB)
  _AM_SUBST_NOTMAKE([README_DEB])
  AC_CONFIG_FILES([debian/changelog debian/control])
  AX_ADD_MAKEFILE_TARGET_DEP([clean-am], [clean-debian-targets], [makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([distclean-am], [distclean-debian-targets], [makefile.in])
  test -f makefile.in && cat >> makefile.in <<EOF
#### Begin: Appended by $0
EXTRA_DIST += debian
clean-debian-targets:
	-rm -rf \${PACKAGE_NAME}_\${PACKAGE_VERSION}~\${DISTRO}.\${BUILD_NUMBER}.{dsc,tar.gz} \${PACKAGE_NAME}_\${PACKAGE_VERSION}~\${DISTRO}.\${BUILD_NUMBER}*.changes \$\$(sed -n 's,Package: \(.*\),\1_${PACKAGE_VERSION}~${DISTRO}.${BUILD_NUMBER}*.deb,p;' debian/control)
deb: distdir
	cd \${PACKAGE_NAME}-\${PACKAGE_VERSION} && ( export CFLAGS="\${CFLAGS}"; export CPPFLAGS="\${CPPFLAGS}"; export CXXFLAGS="\${CXXFLAGS}"; export LDFLAGS="\${LDFLAGS}"; export DEB_CFLAGS_APPEND="\${CFLAGS}"; export DEB_CPPFLAGS_APPEND="\${CPPFLAGS}"; export  DEB_CXXFLAGS_APPEND="\${CXXFLAGS}"; export DEB_LDFLAGS_APPEND="\${LDFLAGS}"; dpkg-buildpackage )
distclean-debian-targets:
	-rm debian/changelog debian/control
#### End: $0
EOF
])

# use this in configure.ac to support RPM packages
AC_DEFUN([AX_USE_RPM_PACKAGING], [
  AC_CONFIG_FILES([${PACKAGE_NAME}.spec])
  #AX_ADD_MAKEFILE_TARGET_DEP([clean-am], [clean-rpm-targets], [makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([clean-am], [clean-rpm-targets], [makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([distclean-am], [distclean-rpm-targets], [makefile.in])
  test -f makefile.in && cat >> makefile.in <<EOF
#### Begin: Appended by $0
EXTRA_DIST += \${PACKAGE_NAME}.spec.in
rpm: dist
	rpmbuild -ba --define "_topdir \$\$(pwd)" --define "_sourcedir \$\$(pwd)" \${PACKAGE_NAME}.spec
	./rpmsign.exp "\${PACKAGER}" "\{PASSWORD}" RPMS/*/*.rpm SRPMS/*.rpm
clean-rpm-targets:
	-rm -rf BUILD BUILDROOT RPMS SPECS SRPMS
distclean-rpm-targets:
	-rm \${PACKAGE_NAME}.spec
#### End: $0
EOF
])

# use this in configure.ac to support scripts, e.g. bash scripts
AC_DEFUN([AX_USE_ETC], [
  AC_CONFIG_FILES([etc/makefile])
])

# use this in configure.ac to support scripts, e.g. bash scripts
AC_DEFUN([AX_USE_SCRIPTS], [
  AC_CONFIG_FILES([scripts/makefile])
])

# use this in configure.ac to support Doxygen documentation generation
AC_DEFUN([AX_USE_DOXYGEN], [
  AC_CHECK_PROG(have_doxygen, doxygen, yes, no)
  AC_CHECK_PROG(have_dot, dot, yes, no)
  AC_CHECK_PROG(have_mscgen, mscgen, yes, no)
  AM_CONDITIONAL(NEED_PLANTUML, test "$have_doxygen" = "yes" -a "1.8.11" != $((echo "1.8.11"; doxygen -v 2>/dev/null) | sort -V | head -1))
  PDF_DOC=${PACKAGE_NAME}-${PACKAGE_VERSION}.pdf
  AC_SUBST(PDF_DOC)
  if test "$have_doxygen" = "no"; then
    AC_MSG_WARN([Missing program doxygen!
     - you cannot rebuild the documentation
     - there are precompiled derived files in the distribution]); fi
  if test "$have_dot" = "no"; then
    AC_MSG_WARN([Missing program dot!
     - when you rebild documentation, there are no generated images
     - there are precompiled derived files in the distribution]); fi
  if test "$have_mscgen" = "no"; then
    AC_MSG_WARN([Missing program mscgen!
     - when you rebild documentation, there are no message state charts
     - there are precompiled derived files in the distribution]); fi
  AC_CONFIG_FILES([doc/makefile doc/doxyfile doc/header.html doc/footer.html])
  AX_ADD_MAKEFILE_TARGET_DEP([clean-am], [clean-documentation], [doc/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([distclean-am], [distclean-documentation], [doc/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([maintainer-clean-am], [maintainer-clean-documentation], [doc/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([install-data-am], [install-data-documentation], [doc/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([uninstall-am], [uninstall-documentation], [doc/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([all], [doc], [doc/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([.PHONY], [pdf gen-uml-images], [doc/makefile.in])
  test -f doc/makefile.in && cat >> doc/makefile.in <<EOF
#### Begin: Appended by $0
doc: doxyfile @NEED_PLANTUML_TRUE@ gen-uml-images
	@NEED_PLANTUML_TRUE@ doxyadd() { grep -q "\$\$[1] += \$\$[2]" doxyfile || sed -i '/^'"\$\$[1]"' *=/a'"\$\$[1]"' += '"\$\$[2]" doxyfile; }; \\
	@NEED_PLANTUML_TRUE@ doxyadd ALIASES '"startuml{1}=@image html \\\\1\\\\n@image latex \\\\1\\\\n\\\\if DontIgnorePlantUMLCode"'; \\
	@NEED_PLANTUML_TRUE@ doxyadd ALIASES '"enduml=\\\\endif"'; \\
	@NEED_PLANTUML_TRUE@ doxyadd IMAGE_PATH '"gen-uml-images"';
	doxygen doxyfile
@PEDANTIC_TRUE@	test \! -s doxygen.errors

@NEED_PLANTUML_TRUE@EXTRA_DIST = ${EXTRA_DIST} plantuml.jar
@NEED_PLANTUML_TRUE@
@NEED_PLANTUML_TRUE@gen-uml-images:
@NEED_PLANTUML_TRUE@	test -d gen-uml-images || mkdir gen-uml-images
@NEED_PLANTUML_TRUE@	eval \$\$(sed -n 's, *INPUT *\\(+\\?\\)= *\\(.*\\),INPUT\\1=" \\2",gp' doxyfile); \\
@NEED_PLANTUML_TRUE@	eval \$\$(sed -n 's, *FILE_PATTERNS *\\(+\\?\\)= *\\(.*\\),FILE_PATTERNS\\1=" \\2",gp' doxyfile); \\
@NEED_PLANTUML_TRUE@	SOURCES="**.("\$\$(echo \$\${FILE_PATTERNS} | sed 's,*.,,g;s, ,|,g')")"; \\
@NEED_PLANTUML_TRUE@	for src in \$\$INPUT; do \\
@NEED_PLANTUML_TRUE@	  java  -Djava.awt.headless=true -jar \${top_srcdir}/doc/plantuml.jar -v -o \$\$(pwd)/gen-uml-images "\$\$src/\$\$SOURCES"; \\
@NEED_PLANTUML_TRUE@	done

clean-documentation:
	-rm doxygen.errors @PDF_DOC@
	@NEED_PLANTUML_TRUE@ -rm -rf gen-uml-images
distclean-documentation:
	-rm -r html
	-rm  @PACKAGE_NAME@.doxytag
maintainer-clean-documentation:
	-rm makefile.in
install-data-documentation:
	test -d \$(DESTDIR)\${docdir} || mkdir -p \$(DESTDIR)\${docdir}
	chmod -R u+w \$(DESTDIR)\${docdir}
	cp -r html \$(DESTDIR)\${docdir}/
uninstall-documentation:
	-chmod -R u+w \$(DESTDIR)\${docdir}
	-rm -rf \$(DESTDIR)\${docdir}/html
#### End: $0
EOF
])

# use this in configure.ac to support Doxygen documentation generation
AC_DEFUN([AX_USE_PERLDOC], [
  PERL_SOURCES="m4_default([$1], [perl])"
  AX_SUBST(PERL_SOURCES)
  if test -z "$PERL_SOURCES"; then
    AC_MSG_ERROR([You must specify the path to perl files
     - use [AX]_[USE]_PERLDOC([[pathes to perldoc]])]); fi
  AC_CHECK_PROG(have_perldoc, pods2html, yes, no)
  if test "$have_doxygen" = "no"; then
    AC_MSG_WARN([Missing program pods2html!
     - you cannot rebuild the documentation
     - there are precompiled derived files in the distribution
     - if you need to generate documentation, install libpod-tree-perl]); fi
  AC_CONFIG_FILES([doc/makefile])
  AX_ADD_MAKEFILE_TARGET_DEP([distclean-am], [distclean-perldoc], [doc/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([maintainer-clean-am], [maintainer-clean-perldoc], [doc/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([install-data-am], [install-data-perldoc], [doc/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([uninstall-am], [uninstall-perldoc], [doc/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([all], [doc], [doc/makefile.in])
  AX_ADD_MAKEFILE_TARGET_DEP([.PHONY], [doc], [doc/makefile.in])
  test -f doc/makefile.in && cat >> doc/makefile.in <<EOF
#### Begin: Appended by $0
doc: perldoc/index.html

perldoc/index.html: \${PERL_SOURCES:%=perldoc/%}
	echo "<html><head><title>Perl Documentation</title></head><body><h1>Perl Documentation</h1><ul>" > perldoc/index.html
	for p in \${PERL_SOURCES:%=perldoc/%}; do \
	  echo '<li><a href="'"\$\${p#perldoc/}"'/index.html">'"\$\${p#perldoc/}"'</a></li>' >> perldoc/index.html; \
	done
	echo "</ul></body></html>" >> perldoc/index.html

perldoc/%:
	pods2html --notoc --empty --index index @top_srcdir@/\${@:perldoc/%=%} \$[@]

distclean-perldoc:
	-rm -r perldoc
maintainer-clean-perldoc:
	-rm makefile.in
install-data-perldoc:
	test -d \$(DESTDIR)\${docdir} || mkdir -p \$(DESTDIR)\${docdir}
	chmod -R u+w \$(DESTDIR)\${docdir}
	cp -r perldoc \$(DESTDIR)\${docdir}/
uninstall-perldoc:
	-chmod -R u+w \$(DESTDIR)\${docdir}
	-rm -rf \$(DESTDIR)\${docdir}/perldoc
#### End: $0
EOF
])

# require a specific package, with fallback: test for a header
#  - parameter:
#     $1 = unique id (no special characters)
#     $2 = module name (optional, if different from id)
#     $3 = a header file to find (optional)
#     $4 = alternative module names (space separated, optional)
#     $5 = optional flags:
#            manualflags if CXXFLAGS, CPPFLAGS, LIBS should remain unchanged
#     $6 = optional parameters, allowed are (evaluated in this order):
#           - RPM_DIST_PKG=<name>
#             special name for the RPM package
#           - DEB_DIST_PKG=<name>
#             special name for the debian package
#           - DIST_PKG=<name>
#             if the name of the package is different
#           - DEV_DIST_PKG=<name>
#             if the name of the development package is different
#
# uses PKG_CHECK_MODULES to test for a module
# then, if given, looks for the header file
# if header file is not found, searches in alternative modules
# sets all flags, so that the module can be used everywhere
# fails if not found
AC_DEFUN([AX_PKG_REQUIRE], [
  PKG_PROG_PKG_CONFIG
  optional_flags="$5"
  $6
  if test -n "$DEV_DIST_PKG"; then
    DEV_DEB_DIST_PKG=${DEV_DIST_PKG}-dev
    DEV_RPM_DIST_PKG=${DEV_DIST_PKG}-devel
  fi
  $1_found=no
  secondpar="m4_default([$2], [$1])"
  PKG_CHECK_MODULES([$1], [m4_default([$2], [$1])], [
    $1_found=$secondpar
    PKG_REQUIREMENTS+=" $secondpar"
  ], [
    if test -n "$4"; then
      AC_MSG_WARN([Recommended package $secondpar for feature $1 not installed, trying $4])
      for pkg in $4; do
        PKG_CHECK_MODULES([$1], [$pkg], [
          PKG_REQUIREMENTS+=" $pkg"
          $1_found=$pkg
          break;
        ], [
          AC_MSG_WARN([Recommended package $pkg for feature $1 not installed])
        ])
      done
    fi
  ])
  AC_SUBST(CPPFLAGS)
  AC_SUBST(CXXFLAGS)
  AC_SUBST(PKG_REQUIREMENTS)
  if test -n "$3"; then
    if test "${$1_found}" = "no"; then
      tmp_package="yes"
    else
      tmp_package=${$1_found}
    fi
    $1_found=no
    old_CPPFLAGS=${CPPFLAGS}
    CPPFLAGS=" ${$1_CFLAGS} ${CPPFLAGS}"
    AC_CHECK_HEADER([$3], [
      $1_found=${tmp_package}
    ], [
      for x in ${$1_CFLAGS}; do
        AC_MSG_NOTICE([search for $3 in ${x[#]-I}])
        for f in $(find ${x[#]-I} -name "$3" 2> /dev/null); do
          if test -f "$f"; then
            $1_found=${tmp_package}
            $1_CFLAGS+=" -I${f%/*}"
            AC_MSG_NOTICE([added path ${f%/*}])
            break;
          fi
        done
        if test "${$1_found}" != "no"; then
          break;
        fi
      done
      if test "${$1_found}" = "no"; then
        tmp_includedir=$(${PKG_CONFIG} --variable=includedir $tmp_package)
        for x in ${tmp_includedir}; do
          AC_MSG_NOTICE([search for $3 in $x])
          for f in $(find ${x} -name "$3" 2> /dev/null); do
            if test -f "$f"; then
              $1_found=${tmp_package}
              $1_CFLAGS+=" -I${f%/*}"
              AC_MSG_NOTICE([added path ${f%/*}])
              break;
            fi
          done
          if test "${$1_found}" != "no"; then
            break;
          fi
        done
      fi
    ])
    CPPFLAGS=${old_CPPFLAGS}
  fi
  if test "${$1_found}" = "no"; then
    if test -n "$3"; then
      if test -n "$4"; then
        AC_MSG_ERROR([Feature $1 not found, need header $3 in modules $secondpar or $4])
      else
        AC_MSG_ERROR([Feature $1 not found, need header $3 in module $secondpar])
      fi
    else
      AC_MSG_ERROR([Feature $1 not found please install module $secondpar])
    fi
  fi
  AX_DEB_BUILD_DEPEND([${DEV_DEB_DIST_PKG:-${DEB_DIST_PKG:-${DIST_PKG:-${$1_found}-dev}}}])
  AX_RPM_BUILD_DEPEND([${DEV_RPM_DIST_PKG:-${RPM_DIST_PKG:-${DIST_PKG:-${$1_found}-devel}}}])
  AX_DEB_DEPEND([${DEB_DIST_PKG:-${DIST_PKG:-${$1_found}}}])
  AX_RPM_DEPEND([${RPM_DIST_PKG:-${DIST_PKG:-${$1_found}}}])
  [$1]_CPPFLAGS="${$1_CFLAGS}"
  [$1]_CXXFLAGS="${$1_CFLAGS}"
  AC_SUBST([$1]_CPPFLAGS)
  AC_SUBST([$1]_CXXFLAGS)
  if test "${optional_flags/manualflags/}" = "${optional_flags}"; then
    CPPFLAGS+=" ${$1_CPPFLAGS}"
    CXXFLAGS+=" ${$1_CXXFLAGS}"
    LIBS+=" ${$1_LIBS}"
    AC_MSG_NOTICE([Adding flags for $1])
  else
    AC_MSG_NOTICE([To enable $1, add $1_CPPFLAGS, $1_CXXFLAGS and $1_LIBS])
  fi
])

# check if a specific package exists
#  - parameter:
#     $1 = unique id (no special characters)
#     $2 = module name (optional, if different from id)
#     $3 = optional flags:
#          manualflags if CXXFLAGS, CPPFLAGS, LIBS should remain unchanged
#     $4 = optional parameters, allowed are (evaluated in this order):
#           - RPM_DIST_PKG=<name>
#             special name for the RPM package
#           - DEB_DIST_PKG=<name>
#             special name for the debian package
#           - DIST_PKG=<name>
#             if the name of the package is different
#           - DEV_DIST_PKG=<name>
#             if the name of the development package is different
#
# uses PKG_CHECK_MODULES to test for a module
# sets automake conditional HAVE_$1 to 0 (not found) or 1 (found)
# sets all flags, so that the module can be used everywhere
AC_DEFUN([AX_PKG_CHECK], [
  optional_flags="$3"
  $4
  if test -n "$DEV_DIST_PKG"; then
    DEV_DEB_DIST_PKG=${DEV_DIST_PKG}-dev
    DEV_RPM_DIST_PKG=${DEV_DIST_PKG}-devel
  fi
  PKG_PROG_PKG_CONFIG
  PKG_CHECK_MODULES([$1], [m4_default([$2], [$1])], [
    HAVE_$1=1
    [$1]_CPPFLAGS="${$1_CFLAGS}"
    [$1]_CXXFLAGS="${$1_CFLAGS}"
    AC_SUBST([$1]_CPPFLAGS)
    AC_SUBST([$1]_CXXFLAGS)
    if test "${optional_flags/manualflags/}" = "${optional_flags}"; then
      CPPFLAGS+=" ${$1_CPPFLAGS}"
      CXXFLAGS+=" ${$1_CXXFLAGS}"
      LIBS+=" ${$1_LIBS}"
      AC_MSG_NOTICE([Adding flags for $1])
    else
      AC_MSG_NOTICE([To enable $1, add $1_CPPFLAGS, $1_CXXFLAGS and $1_LIBS])
    fi
    if test -z "$PKG_REQUIREMENTS"; then
      PKG_REQUIREMENTS="m4_default([$2], [$1])"
    else
      PKG_REQUIREMENTS="${PKG_REQUIREMENTS}, m4_default([$2], [$1])"
    fi
  ], [
    HAVE_$1=0
  ])
  AX_DEB_BUILD_DEPEND([${DEV_DEB_DIST_PKG:-${DEB_DIST_PKG:-${DIST_PKG:-m4_default([$2], [$1])-dev}}}])
  AX_RPM_BUILD_DEPEND([${DEV_RPM_DIST_PKG:-${RPM_DIST_PKG:-${DIST_PKG:-m4_default([$2], [$1])-devel}}}])
  AX_DEB_DEPEND([${DEB_DIST_PKG:-${DIST_PKG:-m4_default([$2], [$1])}}])
  AX_RPM_DEPEND([${RPM_DIST_PKG:-${DIST_PKG:-m4_default([$2], [$1])}}])
  AM_CONDITIONAL(HAVE_$1, test $HAVE_[$1] -eq 1)
  AC_SUBST(HAVE_$1)
  AC_SUBST(CPPFLAGS)
  AC_SUBST(CXXFLAGS)
  AC_SUBST(PKG_REQUIREMENTS)
])

# make sure, a specific header exists
# - parameter:
#    $1 = header name
#    $2 = pathes to search for
AC_DEFUN([AX_REQUIRE_HEADER], [
  AC_CHECK_HEADER($1, [], [
    if test -n "$2"; then
      found=0
      for d in $2; do
        if test -f "${d}/$1"; then
          AC_MSG_NOTICE([found file ${d}/$1])
          CPPFLAGS+=" -I${d}"
          found=1
          break;
        else
          AC_MSG_NOTICE([not found file ${d}/$1])
        fi
      done
    fi
    if test $found -eq 0; then
      AC_MSG_ERROR([Header $1 not found])
    fi
    ], [])
  ], [])
])

# Check within a list of CPP-Flags for the first that is usable and
# configure it
#  - parameter:
#     $1 = white-space separated list of alternative flags
#     $2 = module name (optional, if different from id)
AC_DEFUN([AX_CHECK_VALID_CPP_FLAG], [
  AC_MSG_CHECKING([m4_default([$2], [for valid flag in "$1"])])
  save_cppflags="$CPPFLAGS"
  newflag="no"
  for test_flag in $1; do
    CPPFLAGS+=" ${test_flag}"
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM()], [
      newflag="$test_flag"
      CPPFLAGS="$save_cppflags"
      CPPFLAGS+=" ${test_flag}"
      break;
    ])
    CPPFLAGS="$save_cppflags"
  done
  AC_SUBST(CPPFLAGS)
  AC_MSG_RESULT([$newflag in $CPPFLAGS])
])

# Check within a list of CXX-Flags for the first that is usable and
# configure it
#  - parameter:
#     $1 = white-space separated list of alternative flags
#     $2 = module name (optional, if different from id)
AC_DEFUN([AX_CHECK_VALID_CXX_FLAG], [
  AC_MSG_CHECKING([m4_default([$2], [for valid flag in "$1"])])
  save_cxxflags="$CXXFLAGS"
  newflag="no"
  for test_flag in $1; do
    CXXFLAGS+=" ${test_flag}"
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM()], [
      newflag="$test_flag"
      CXXFLAGS="$save_cxxflags"
      CXXFLAGS+=" ${test_flag}"
      break;
    ])
    CXXFLAGS="$save_cxxflags"
  done
  AC_SUBST(CXXFLAGS)
  AC_MSG_RESULT([$newflag in $CXXFLAGS])
])

# Check within a list of C-Flags for the first that is usable and
# configure it
#  - parameter:
#     $1 = white-space separated list of alternative flags
#     $2 = module name (optional, if different from id)
AC_DEFUN([AX_CHECK_VALID_C_FLAG], [
  AC_MSG_CHECKING([m4_default([$2], [for valid flag in "$1"])])
  save_cflags="$CFLAGS"
  newflag="no"
  for test_flag in $1; do
    CFLAGS+=" ${test_flag}"
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM()], [
      newflag="$test_flag"
      CFLAGS="$save_cflags"
      CFLAGS+=" ${test_flag}"
      break;
    ])
    CFLAGS="$save_cflags"
  done
  AC_SUBST(CFLAGS)
  AC_MSG_RESULT([$newflag in $CFLAGS])
])

# Check within a list of LD-Flags for the first that is usable and
# configure it
#  - parameter:
#     $1 = white-space separated list of alternative flags
#     $2 = module name (optional, if different from id)
AC_DEFUN([AX_CHECK_VALID_LD_FLAG], [
  AC_MSG_CHECKING([m4_default([$2], [for valid flag in "$1"])])
  save_ldflags="$LDFLAGS"
  newflag="no"
  for test_flag in $1; do
    LDFLAGS+=" ${test_flag}"
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM()], [
      newflag="$test_flag"
      LDFLAGS="$save_ldflags"
      LDFLAGS+=" ${test_flag}"
      break;
    ])
    LDFLAGS="$save_ldflags"
  done
  AC_SUBST(LDFLAGS)
  AC_MSG_RESULT([$newflag in $LDFLAGS])
])

# Check if a package exists in the current distribution, if yes, require it
# in debian/control.in append @DEB_DEPEND_IFEXISTS@ to Build-Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_DEB_DEPEND_IFEXISTS], [
  pkg="$1"
  if test -n "$(apt-cache policy -q ${pkg} 2> /dev/null)"; then
     DEB_DEPEND_IFEXISTS="${DEB_DEPEND_IFEXISTS}, ${pkg}"
  fi
])

# require package in debian/control.in append @DEB_BUILD_DEPEND@ to Build-Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_DEB_BUILD_DEPEND], [
  pkg="$1"
  DEB_BUILD_DEPEND="${DEB_BUILD_DEPEND}, ${pkg}"
])

# require package in debian/control.in append @DEB_DEPEND@ to Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_DEB_DEPEND], [
  pkg="$1"
  DEB_DEPEND="${DEB_DEPEND}, ${pkg}"
])

# require package in debian/control.in append @DEB_DEPEND@ to Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_DEB_SECTION], [
  pkg="$1"
  DEB_SECTION="${pkg}"
])

# call after setting debian dependencies
AC_DEFUN([AX_DEB_RESOLVE], [
  AC_SUBST(DEB_BUILD_DEPEND)
  AC_SUBST(DEB_DEPEND)
  AC_SUBST(DEB_SECTION)
  AC_SUBST(DEB_DEPEND_IFEXISTS)
])

# Check if a package exists in the current distribution, if yes, require it
# in .spec.in append @RPM_DEPEND_IFEXISTS@ to Build-Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_RPM_DEPEND_IFEXISTS], [
  pkg="$1"
  
  if (test -x /usr/bin/zypper && zypper search -x "$pkg" 1>&2 > /dev/null) || \
     (test -x /usr/bin/dnf && dnf list -q "$pkg" 1>&2 > /dev/null) || \
     (test -x /usr/bin/yum && yum list -q "$pkg" 1>&2 > /dev/null) || \
     (test -x /usr/sbin/urpmq && urpmq "$pkg" 1>&2 > /dev/null); then
       RPM_DEPEND_IFEXISTS="${RPM_DEPEND_IFEXISTS}, ${pkg}"
  fi
])

# require package in .spec.in append @RPM_BUILD_DEPEND@ to Build-Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_RPM_BUILD_DEPEND], [
  pkg="$1"
  RPM_BUILD_DEPEND="${RPM_BUILD_DEPEND}, ${pkg}"
])

# require package in .spec.in append @RPM_DEPEND@ to Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_RPM_DEPEND], [
  pkg="$1"
  if test -z "${RPM_DEPEND}"; then
    RPM_DEPEND="${pkg}"
  else
    RPM_DEPEND="${RPM_DEPEND}, ${pkg}"
  fi
])

# require package in debian/control.in append @DEB_DEPEND@ to Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_RPM_GROUP], [
  pkg="$1"
  RPM_GROUP="${pkg}"
])

# call after setting rpmian dependencies
AC_DEFUN([AX_RPM_RESOLVE], [
  AC_SUBST(RPM_BUILD_DEPEND)
  AC_SUBST(RPM_DEPEND)
  AC_SUBST(RPM_GROUP)
  AC_SUBST(RPM_DEPEND_IFEXISTS)
])

# Check if a package exists in the current distribution, if yes, require it
# in .spec.in append @ALL_DEPEND_IFEXISTS@ to Build-Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_ALL_DEPEND_IFEXISTS], [
  pkg="$1"
  if test -n "$(apt-cache policy -q ${pkg} 2> /dev/null)"; then
     DEB_DEPEND_IFEXISTS="${DEB_DEPEND_IFEXISTS}, ${pkg}"
  fi
  if (test -x /usr/bin/zypper && zypper search -x "$pkg" 1>&2 > /dev/null) || \
     (test -x /usr/bin/dnf && dnf list -q "$pkg" 1>&2 > /dev/null) || \
     (test -x /usr/bin/yum && yum list -q "$pkg" 1>&2 > /dev/null) || \
     (test -x /usr/sbin/urpmq && urpmq "$pkg" 1>&2 > /dev/null); then
       RPM_DEPEND_IFEXISTS="${RPM_DEPEND_IFEXISTS}, ${pkg}"
  fi
])

# Check if a package exists in the current distribution, if yes, require it
# in .spec.in append @ALL_DEPEND_IFEXISTS@ to Build-Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_ALL_DEPEND_IFEXISTS_DEV], [
  pkg="$1"
  if test -n "$(apt-cache policy -q ${pkg}-dev 2> /dev/null)"; then
     DEB_DEPEND_IFEXISTS="${DEB_DEPEND_IFEXISTS}, ${pkg}-dev"
  fi
  if (test -x /usr/bin/zypper && zypper search -x "$pkg"-devel 1>&2 > /dev/null) || \
     (test -x /usr/bin/dnf && dnf list -q "$pkg"-devel 1>&2 > /dev/null) || \
     (test -x /usr/bin/yum && yum list -q "$pkg"-devel 1>&2 > /dev/null) || \
     (test -x /usr/sbin/urpmq && urpmq "$pkg"-devel 1>&2 > /dev/null); then
       RPM_DEPEND_IFEXISTS="${RPM_DEPEND_IFEXISTS}, ${pkg}-devel"
  fi
])

# require package in .spec.in append @ALL_BUILD_DEPEND@ to Build-Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_ALL_BUILD_DEPEND], [
  pkg="$1"
  DEB_BUILD_DEPEND="${DEB_BUILD_DEPEND}, ${pkg}"
  RPM_BUILD_DEPEND="${RPM_BUILD_DEPEND}, ${pkg}"
])

# require package in .spec.in append @ALL_BUILD_DEPEND@ to Build-Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_ALL_BUILD_DEPEND_DEV], [
  pkg="$1"
  DEB_BUILD_DEPEND="${DEB_BUILD_DEPEND}, ${pkg// /-dev}-dev"
  RPM_BUILD_DEPEND="${RPM_BUILD_DEPEND}, ${pkg// /-devel}-devel"
])

# require package in .spec.in append @ALL_DEPEND@ to Depends
#  - parameter:
#     $1 = package name
AC_DEFUN([AX_ALL_DEPEND], [
  pkg="$1"
  DEB_DEPEND="${DEB_DEPEND}, ${pkg}"
  if test -z "${RPM_DEPEND}"; then
    RPM_DEPEND="${pkg}"
  else
    RPM_DEPEND="${RPM_DEPEND}, ${pkg}"
  fi
])

# finish configuration - to be called instead of AC_OUTPUT
AC_DEFUN([AX_OUTPUT], [
  AX_DEB_RESOLVE
  AX_RPM_RESOLVE
  AC_OUTPUT
])
