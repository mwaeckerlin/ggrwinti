# SYNOPSIS
#
#   Check if a module exists:
#     AX_CHECK_QT([qt_prefix], [list-of-qt-modules], [optional-modules] [flags])
#
#   Abort if a module does not exist:
#     AX_REQUIRE_QT([qt_prefix], [list-of-qt-modules], [optional-modules] [flags])
#
# DESCRIPTIONS
#
#    qt_prefix
#
#      Each call to AX_CHECK_QT should have a different prefix
#      value (with a few exceptions discussed later on). This value,
#      usually provided in uppercase, is used as prefix to the
#      variables holding the compiler flags and libraries reported by
#      pkg-config.
#
#      For instance, if your prefix was to be FOO you'll be provided
#      two variables FOO_CFLAGS and FOO_LIBS.
#
#      This will also be used as message during the configure checks:
#      checking for FOO....
#
#    list-of-modules
#
#      A single call to the macro can check for the presence of one or
#      more qt modules; you'll see later how to make good use of this
#      feature. Each entry in the list can have a version comparison
#      specifier, with the same syntax as the Requires keyword in the
#      data files themselves.
#
#    optional-modules
#
#      Optional list of more, optional modules, e.g. modules that
#      exist only in Qt5, but not in Qt4, such as QtWidgets or
#      QtWebKitWidgets
#
#    flags
#
#      Optional flages, space separated from this list:
#
#          manualflags
#
#            CXXFLAGS, CPPFLAGS and LIBS variables are not
#            automatically expanded, but you need to add the
#            qt_prefix_CXXFLAGS, qt_prefix_CPPFLAGS and qt_prefix_LIBS
#            variables manually where you need them. This is useful,
#            if some build targets need a feature and some don't.


AC_DEFUN([AX_CXX_QT_TOOL], [
  PKG_PROG_PKG_CONFIG
  if test -z "$HAVE_$1"; then
    HAVE_$1=1
    AC_MSG_CHECKING([for $2])
    AC_ARG_VAR([$1], [path to Qt tool $2])
    $1=${$1:-$(${PKG_CONFIG} --variable=$2_location Qt5Core)}
    $1=${$1:-$(${PKG_CONFIG} --variable=host_bins Qt5Core)/$2-qt5}
    $1=${$1:-$(${PKG_CONFIG} --variable=host_bins Qt5Core)/$2}
    $1=${$1:-$(${PKG_CONFIG} --variable=$2_location QtCore)}
    $1=${$1:-$(${PKG_CONFIG} --variable=host_bins QtCore)/$2}
    $1=${$1:-$(${PKG_CONFIG} --variable=host_bins QtCore)/$2-qt4}
    if ! which "${$1%% *}" > /dev/null; then
      if which "$2-qt5" > /dev/null; then
        $1=$2-qt5
      elif which "$2" > /dev/null; then
        $1=$2
      elif which "$2-qt4" > /dev/null; then
        $1=$2-qt4
      else
        HAVE_$1=0
        $1=""
      fi
    fi
    AC_SUBST($1)
    AM_CONDITIONAL(HAVE_$1, test $HAVE_[$1] -eq 1)
    if test $HAVE_$1 -eq 1; then
      AC_MSG_RESULT([$$1])
    else
      AC_MSG_RESULT([not found])
    fi
  fi
])

AC_DEFUN([AX_CXX_QT_TOOLS], [
  AX_CXX_QT_TOOL(QMAKE, qmake)
  AX_CXX_QT_TOOL(MOC, moc)
  AX_CXX_QT_TOOL(UIC, uic)
  AX_CXX_QT_TOOL(RCC, rcc)
  AX_CXX_QT_TOOL(LUPDATE, lupdate)
  AX_CXX_QT_TOOL(LRELEASE, lrelease)
])

AC_DEFUN([AX_CHECK_QT], [
  qt_modules="$2"
  qt_modules_optional="$3"
  qt_flags="$4"
  AX_CXX_QT_TOOLS
  HAVE_$1=0
  PKG_PROG_PKG_CONFIG
  PKG_CHECK_MODULES([$1]5, [${qt_modules//Qt/Qt5}], [
    HAVE_$1=1
    AC_DEFINE([HAVE_$1])
    QTDIR=$(${PKG_CONFIG} --variable=prefix Qt5Core)
    qt_host_bins=$(${PKG_CONFIG} --variable=host_bins Qt5Core)
    if test -d "${qt_host_bins}"; then
      QT_PLUGIN_PATH=${qt_host_bins}/../plugins
    else
      QT_PLUGIN_PATH=${QTDIR}/share/qt5/plugins
    fi
    MOC_FLAGS+=" -DHAVE_$1=1 ${[$1]5_CFLAGS}"
    [$1]_CPPFLAGS="${[$1]5_CFLAGS}"
    [$1]_CXXFLAGS="${[$1]5_CFLAGS}"
    [$1]_LIBS="${[$1]5_LIBS}"
    AC_SUBST([$1]_CPPFLAGS)
    AC_SUBST([$1]_CXXFLAGS)
    if test "${qt_flags/manualflags/}" = "${qt_flags}"; then
      CPPFLAGS+=" ${[$1]_CPPFLAGS}"
      CXXFLAGS+=" ${[$1]_CXXFLAGS}"
      LIBS+=" ${[$1]_LIBS}"
      AC_MSG_NOTICE([Adding flags for $1])
    else
      AC_MSG_NOTICE([To enable $1, add $1_CPPFLAGS, $1_CXXFLAGS and $1_LIBS])
    fi
    PKG_REQUIREMENTS+=" ${qt_modules//Qt/Qt5}"
    if test -n "${qt_modules_optional}"; then
      PKG_CHECK_MODULES([$1]5_OPTIONAL, [${qt_modules_optional//Qt/Qt5}], [
        MOC_FLAGS+=" ${[$1]5_OPTIONAL_CFLAGS}"
        [$1]_CPPFLAGS+=" ${[$1]5_OPTIONAL_CFLAGS}"
        [$1]_CXXFLAGS+=" ${[$1]5_OPTIONAL_CFLAGS}"
        [$1]_LIBS+=" ${[$1]5_OPTIONAL_LIBS}"
        AC_SUBST([$1]_CPPFLAGS)
        AC_SUBST([$1]_CXXFLAGS)
        if test "${qt_flags/manualflags/}" = "${qt_flags}"; then
          CPPFLAGS+=" ${[$1]5_OPTIONAL_CFLAGS}"
          CXXFLAGS+=" ${[$1]5_OPTIONAL_CFLAGS}"
          LIBS+=" ${[$1]5_OPTIONAL_LIBS}"
          AC_MSG_NOTICE([Adding flags for $1])
        else
          AC_MSG_NOTICE([To enable $1, add $1_CPPFLAGS, $1_CXXFLAGS and $1_LIBS])
        fi
        PKG_REQUIREMENTS+=" ${qt_modules_optional//Qt/Qt5}"
      ], [
        AC_MSG_NOTICE([Not found: ${qt_modules_optional//Qt/Qt5}])
      ])
    fi
  ], [
    PKG_CHECK_MODULES([$1], [${qt_modules}], [
      HAVE_$1=1
      AC_DEFINE([HAVE_$1])
      QTDIR=$(${PKG_CONFIG} --variable=prefix QtCore)
      qt_host_bins=$(${PKG_CONFIG} --variable=host_bins QtCore)
      if test -d "${qt_host_bins}"; then
        QT_PLUGIN_PATH=${qt_host_bins}/../plugins
      else
        QT_PLUGIN_PATH=${QTDIR}/share/qt/plugins
      fi
      MOC_FLAGS+=" -DHAVE_$1=1 ${$1_CFLAGS}"
      [$1]_CPPFLAGS="${[$1]_CFLAGS}"
      [$1]_CXXFLAGS="${[$1]_CFLAGS}"
      AC_SUBST([$1]_CPPFLAGS)
      AC_SUBST([$1]_CXXFLAGS)
      if test "${qt_flags/manualflags/}" = "${qt_flags}"; then
        CPPFLAGS+=" ${[$1]_CPPFLAGS}"
        CXXFLAGS+=" ${[$1]_CXXFLAGS}"
        LIBS+=" ${[$1]_LIBS}"
          AC_MSG_NOTICE([Adding flags for $1])
        else
          AC_MSG_NOTICE([To enable $1, add $1_CPPFLAGS, $1_CXXFLAGS and $1_LIBS])
      fi
      PKG_REQUIREMENTS+=" ${qt_modules}"
      if test -n "$3"; then
        PKG_CHECK_MODULES($1_OPTIONAL, [${qt_modules_optional}], [
          MOC_FLAGS+="${$1_OPTIONAL_CFLAGS}"
          [$1]_CPPFLAGS+=" ${$1_OPTIONAL_CFLAGS}"
          [$1]_CXXFLAGS+=" ${$1_OPTIONAL_CFLAGS}"
          [$1]_LIBS+=" ${$1_OPTIONAL_LIBS}"
          AC_SUBST([$1]_CPPFLAGS)
          AC_SUBST([$1]_CXXFLAGS)
          if test "${qt_flags/manualflags/}" = "${qt_flags}"; then
            CPPFLAGS+=" ${$1_OPTIONAL_CFLAGS}"
            CXXFLAGS+=" ${$1_OPTIONAL_CFLAGS}"
            LIBS+=" ${$1_OPTIONAL_LIBS}"
            AC_MSG_NOTICE([Adding flags for $1])
          else
            AC_MSG_NOTICE([To enable $1, add $1_CPPFLAGS, $1_CXXFLAGS and $1_LIBS])
          fi
          PKG_REQUIREMENTS+=" ${qt_modules_optional}"
        ], [
          AC_MSG_NOTICE([Not found: ${qt_modules_optional}])
        ])
      fi
    ], [HAVE_$1=0])
  ])
  AM_CONDITIONAL(HAVE_$1, test $HAVE_[$1] -eq 1)
  AX_CHECK_VALID_CXX_FLAG([-fPIC -fPIE], [position independent code flag])
  if test -n "${MINGW}"; then
    AX_CHECK_VALID_CXX_FLAG([-Wl,-subsystem,windows], [windows console flag])
  fi
  test "x$prefix" = xNONE && prefix=$ac_default_prefix
  if test "${QT_PLUGIN_PATH}" = "${QT_PLUGIN_PATH#${prefix}}"; then
    QT_PLUGIN_PATH=${prefix}${QT_PLUGIN_PATH#/usr}
  fi
  AC_ARG_WITH([qt-plugin-path],
              [AS_HELP_STRING([--with-qt-plugin-path=PATH],
                              [define a different qt plugin path, current @<:@default=check@:>@])],
              [QT_PLUGIN_PATH=$with_qt_plugin_path],
              [])
  AC_MSG_NOTICE([Qt Plugins are installed to ${QT_PLUGIN_PATH}])
  AC_SUBST(QTDIR)
  AC_SUBST(QT_PLUGIN_PATH)
  AC_SUBST(CPPFLAGS)
  AC_SUBST(MOC_FLAGS)
  AC_SUBST(CXXFLAGS)
  AC_SUBST(PKG_REQUIREMENTS)
  AX_ADDITIONAL_QT_RULES_HACK='

LANGUAGE_FILE_BASE ?= translations

ui_%.hxx: %.ui
	$(UIC) -o [$][@] $<

moc_%.cxx: %.hxx
	$(MOC) $(MOC_FLAGS) -o [$][@] $<

qrc_%.cxx: %.qrc
	$(RCC) -o [$][@] -name ${<:%.qrc=%} $<
  AC_SUBST(AX_ADDITIONAL_QT_RULES_HACK)

#%.qrc: %
#	cwd=$$(pwd) && cd $< && $(RCC) -project -o $${cwd}/[$][@]

%.qm: %.ts
	${LRELEASE} $< -qm [$][@]

%.ts: ${LANGUAGE_FILES:%=%}
	${LUPDATE} -no-obsolete \
	           -target-language ${@:${LANGUAGE_FILE_BASE}_%.ts=%} \
	           -ts [$][@] $<

'])

AC_DEFUN([AX_REQUIRE_QT], [
  AX_CHECK_QT([$1], [$2], [$3], [$4])
  if ! test "$HAVE_$1" -eq 1; then
     AC_MSG_ERROR([Required Qt modules not found: $2])
  fi
])


#   Omit Qt Keywords
#     AX_QT_NO_KEYWORDS
AC_DEFUN([AX_QT_NO_KEYWORDS], [
  CPPFLAGS+=" -DQT_NO_KEYWORDS"
])
