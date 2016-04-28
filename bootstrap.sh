#! /bin/bash
## @file
##
## $Id: bootstrap.sh 52 2015-11-03 15:38:21Z marc $
##
## $Date: 2004/08/31 15:57:19 $
## $Author: marc $
##
## @copy &copy; Marc W&auml;ckerlin
## @license LGPL, see file <a href="license.html">COPYING</a>
##
## $Log: bootstrap.sh,v $
## Revision 1.3  2004/08/31 15:57:19  marc
## added file header
##

MY_NAME=${0##*/}
PROJECT_PATH=$(pwd)
DEFAULT_PROJECT_NAME=${PROJECT_PATH##*/}
configure=0
build=0
docker=0
buildtarget=""
overwrite=0
rebuild=0
novcs=0
excludevcs=()
rebuildfiles=()
while test $# -gt 0; do
    case "$1" in
        (--configure|-c) configure=1;;
        (--docker|-d) docker=1;;
        (--build|-b) configure=1; build=1; buildtarget+=" distcheck";;
        (--target|-t) shift; configure=1; build=1; buildtarget+=" $1";;
        (--clean) shift; configure=1; build=1; buildtarget+=" maintainer-clean";;
        (--overwrite|-o) overwrite=1;;
        (--rebuild|-r) rebuild=1;;
        (--rebuild-file|-f) shift; rebuildfiles+=("$1");;
        (--no-vcs|-n) novcs=1;;
        (--exclude-vcs|-x) shift; excludevcs+=("$1");;
        (--version|-v)
            echo "$Id: bootstrap.sh 52 2015-11-03 15:38:21Z marc $";
            exit;;
        (--help|-h) less <<EOF
SYNOPSIS

  ${MY_NAME} [--help|-h] [OPTIOS]

OPTIONS

  --configure, -c            call ./configure after initialization
  --docker, -d               build and run tests in a docker instance
  --build, -b                build, also call ./configure && make distcheck
  --target, -t <target>      same as -b, but specify target instead of distcheck
  --overwrite, -o            overwrite all basic files (bootstrap.sh, m4-macros)
  --rebuild, -r              force rebuild of generated files, even if modified
  --rebuild-file, -f <file>  rebild specific file (can be added multiple times)
  --no-vcs, -n               do not automatically add files to version control
  --exclude-vcs, -x <file>   exclude specific file from version control
  --help, -h                 show this help
  --version, -v              show version and date of this file

DESCRIPTION

  Initializes your build environment, as far as neccessary. Reads your
  used features from configure.ac, if that file exists, or creates a
  configure.ac. Automatically copies or creates all required template
  files.

  From your new and empty project's subversion or git path, call $0 to
  initialize your build environment.

  Before you call ${MY_NAME} the very first time, edit ${0#/*}/AUTHORS
  and replace it with your name (or the authors of your project, one
  name each line, main developper and copyright holder on the first
  line).

  The first call to ${MY_NAME} should be something like
  ../bootstrap-build-environment/${MY_NAME} and not
  ./${MY_NAME}. Actually, you called $0.

  In the way you called ${MY_NAME}, it has detected
  ${DEFAULT_PROJECT_NAME} as the project name for your project in
  ${PROJECT_PATH}. In the first run, you should call ${MY_NAME} from a
  checked out the bootstrap-build-environment from
  https://dev.marc.waeckerlin.org/, and the path from where you call
  ${MY_NAME} (which is actually ${PROJECT_PATH}) should be the path to
  your newly created project. Please note that your project must be a
  checked out subversion or git repository, since this build
  environment relies on subversion or git.

  Example for an initial run, where your new projet is stored in
  subversion on https:/path/to/your/new-project:

    cd ~/svn
    svn co https://dev.marc.waeckerlin.org/svn/bootstrap-build-environment/trunk \\
           bootstrap-build-environment
    svn co https:/path/to/your/new-project/trunk new-project
    cd new-project
    ../bootstrap-build-environment/bootstrap.sh

  Example for an initial run, where your new projet is stored in
  git on https:/path/to/your/new-project:

    cd ~/svn
    svn co https://dev.marc.waeckerlin.org/svn/bootstrap-build-environment/trunk \\
           bootstrap-build-environment
    cd ~/git
    git clone https:/path/to/your/new-project
    cd new-project
    ../bootstrap-build-environment/bootstrap.sh

RUNNING

  If you run ${MY_NAME}, it first generates the necessary files (see
  below), then first runs make distclean if a makefile exists. After
  this it calles aclocal, libtoolize, automake, autoconf and
  optionally ./configure. If necessary, files are added to version
  control.

GENERATED FILES

  This script copies the following files into your project environment:
    * ${MY_NAME}
    * autogen.sh - just the basics to initialize auto tools and create configure
    * ax_init_standard_project.m4 - auxiliary macro definition file
    * ax_cxx_compile_stdcxx_11.m4 - auxiliary macro definition file
    * ax_check_qt.m4 - auxiliary macro definition file
    * resolve-debbuilddeps.sh - script to install debian package dependencies
    * resolve-rpmbuilddeps.sh - script to install RPM package dependencies
    * build-in-docker.sh - script to build the project encapsulated in a docker container
    * build-resource-file.sh - build resource.qrc file from a resource directory
    * sql-to-dot.sed - script to convert SQL schema files to graphviz dot in doxygen
    * mac-create-app-bundle.sh - script to create apple mac os-x app-bundle
    * test/runtests.sh - template file to run test scripts, i.e. docker based
    * AUTHORS - replace your name in AUTHORS before first run
    * NEWS - empty file add your project's news
    * README - add project description (first line is header, followed by an empty line)
    * configure.ac - global configuration file template
    * makefile.am - global makefile template
    * ${DEFAULT_PROJECT_NAME}.desktop.in - linux desktop file
    * src/makefile.am - if you enabled AX_USE_CXX
    * src/version.hxx - if you enabled AX_USE_CXX
    * src/version.cxx - if you enabled AX_USE_CXX
    * html/makefile.am - if you enabled AX_BUILD_HTML
    * scripts/makefile.am - if you enabled AX_USE_SCRIPTS
    * doc/makefile.am - if you enabled AX_USE_DOXYGEN
    * doc/doxyfile.in - if you enabled AX_USE_DOXYGEN
    * test/makefile.am - if you enabled AX_BUILD_TEST or AX_USE_CPPUNIT
    * examples/makefile.am - if you enabled AX_BUILD_EXAMPLES
    * debian/changelog.in - if you enabled AX_USE_DEBIAN_PACKAGING
    * debian/control.in - if you enabled AX_USE_DEBIAN_PACKAGING
    * debian/docs - if you enabled AX_USE_DEBIAN_PACKAGING
    * debian/${DEFAULT_PROJECT_NAME}.install - if you enabled AX_USE_DEBIAN_PACKAGING
    * debian/${DEFAULT_PROJECT_NAME}.dirs - if you enabled AX_USE_DEBIAN_PACKAGING
    * debian/${DEFAULT_PROJECT_NAME}-dev.install - if you enabled AX_USE_DEBIAN_PACKAGING
    * debian/${DEFAULT_PROJECT_NAME}-dev.dirs - if you enabled AX_USE_DEBIAN_PACKAGING
    * debian/rules - if you enabled AX_USE_DEBIAN_PACKAGING
    * debian/compat - if you enabled AX_USE_DEBIAN_PACKAGING
    * ${DEFAULT_PROJECT_NAME}.spec.in - if you enable AX_USE_RPM_PACKAGING
    * src/${DEFAULT_PROJECT_NAME}.pc.in - if you enabled AX_USE_LIBTOOL

REBUILDING FILES

  To rebuild all these files, just run "${MY_NAME} -r".

  To copy only the files provided by this package, that means those
  files you must never change, that means to update the build system
  to the latest release, run "${MY_NAME} -o"

  You can also rebuild a list of singleany list of specific file files
  by adding option "${MY_NAME} -f <file>" to rebuild file
  "<file>". You can add option "-f" more than once.

FILES TO EDIT

  After creation of the files, you can edit them according to your
  needs. Please don't forget to redo your edits after rebuilding a
  file. Most files don't even need to be edited, they work out of the
  box.

  The following files normally require editing:
    * AUTHORS
    * NEWS
    * README
    * configure.ac
    * src/makefile.am
    * html/makefile.am
    * test/makefile.am
    * examples/makefile.am

FILE DEPENDENCIES

  You should rebuild (see above) the files, whenever you change the
  configuration a dependent, i.e.:

    * test/makefile.am depends on AX_USE_LIBTOOL
    * html/makefile.am depends on AX_BUILD_HTML
    * doc/doxyfile.in depends on AX_BUILD_EXAMPLES
    * debian/control.in depends on AX_USE_DOXYGEN, AX_USE_CPPUNIT
      AX_CXX_QT, AX_CHECK_QT, AX_REQUIRE_QT, AX_USE_LIBTOOL
    * debian/${DEFAULT_PROJECT_NAME}.install depends on AX_USE_LIBTOOL
    * debian/${DEFAULT_PROJECT_NAME}.dirs depends on AX_USE_LIBTOOL
    * debian/${DEFAULT_PROJECT_NAME}-dev.install depends on AX_USE_LIBTOOL
    * debian/${DEFAULT_PROJECT_NAME}-dev.dirs depends on AX_USE_LIBTOOL
    * ${DEFAULT_PROJECT_NAME}.spec.in depends on AX_USE_RPM_PACKAGING,
      AX_USE_LIBTOOL, AX_CHECK_QT, AX_REQUIRE_QT, AX_CXX_QT, AX_USE_CPPUNIT

FILES

  * AUTHORS:      First line is the main author and used in Debian and RPM
                  packaging, so there must be a GPG key that matches
                  to this line.
  * NEWS:         File to add project news.
  * README:       First line is a short description of your project, then an
                  empty line must follow. All remaining lines are a
                  long description of your project. this information
                  is copied, e.g. in Debian or RPM packages. In C++
                  <ou can access the readme by calling
                  ${DEFAULT_PROJECT_NAME}::description().
  * ChangeLog:    Your changelog is automatically maintained from
                  subversion history, using svn2cl. You don't need to
                  care about. It uses git2cl on git repositories.
  * configure.ac: This file becomes very short and simple. You provide
                  the project name, the major and minor version. The
                  least version number is automatically taken from
                  subversion's revision, so every checkin
                  automatically increments the least version
                  number. In git, git rev-list --all --count is used.
                  The following macros are supported in configure.ac:
      * Enable C++: AX_USE_CXX
      * Enable LibTool library creation: AX_USE_LIBTOOL
      * Enable Scripts: AX_USE_SCRIPTS
      * Enable Doxygen documentation generation: AX_USE_DOXYGEN
      * Enable Debian packaging by calling "make deb": AX_USE_DEBIAN_PACKAGING
      * Enable RPM packaging by calling "make rpm": AX_USE_RPM_PACKAGING
      * Enable C++ testing using CppUnit: AX_USE_CPPUNIT
      * Enable other tests: AX_BUILD_TEST
      * Enable C++ examples, i.e. for libraries: AX_BUILD_EXAMPLES
      * Check for C++11 support: AX_CXX_COMPILE_STDCXX_11 (see ax_cxx_compile_stdcxx_11.m4)
      * Require a QT module: AX_REQUIRE_QT (see ax_check_qt.m4)
      * Optionally use a QT module: AX_CHECK_QT  (see ax_check_qt.m4)
      * Require a module: AX_PKG_REQUIRE (see ax_init_standard_project.m4)
      * Check for an optional module: AX_PKG_CHECK (see ax_init_standard_project.m4)

EXAMPLES: src/makefile.am in a QT project

  In this example, you wrote the following files:
    * ${DEFAULT_PROJECT_NAME}.hxx - Qt Header file, passed to moc
    * ${DEFAULT_PROJECT_NAME}.cxx - C++ file containing main()
    * ${DEFAULT_PROJECT_NAME}.ui - UI file

  All rules are implicitely added, all you need to do is to add the
  following definitions, most lines are generic:

bin_PROGRAMS = ${DEFAULT_PROJECT_NAME}
${DEFAULT_PROJECT_NAME}_MOCFILES = moc_${DEFAULT_PROJECT_NAME}.cxx
${DEFAULT_PROJECT_NAME}_UIFILES = ui_${DEFAULT_PROJECT_NAME}.hxx
${DEFAULT_PROJECT_NAME}_SOURCES = version.cxx version.hxx ${DEFAULT_PROJECT_NAME}.cxx ${DEFAULT_PROJECT_NAME}_MOCFILES ${DEFAULT_PROJECT_NAME}_UIFILES
BUILT_SOURCES = \${${DEFAULT_PROJECT_NAME}_MOCFILES} \${${DEFAULT_PROJECT_NAME}_UIFILES}
EXTRA_DIST = \${${DEFAULT_PROJECT_NAME}_MOCFILES:moc_%.cxx=%.hxx} \${${DEFAULT_PROJECT_NAME}_UIFILES:ui_%.hxx=%.ui}
MAINTAINERCLEANFILES = makefile.in
EOF
            exit;;
        (*) break;;
    esac
    shift;
done

echo -en "\e[1m-> checking:\e[0m for version control system ..."
VCS=""
VCSDEPENDS=""
if test -d .svn; then
    VCS="svn"
    VCSDEPENDS="subversion,"
    echo -e " \e[32msuccess\e[0m detected ${VCS}"
elif test -d .git; then
    VCS="git"
    VCSDEPENDS="git,"
    echo -e " \e[32msuccess\e[0m detected ${VCS}"
else
    echo -e " \e[33mignored\e[0m"
fi

HEADER='## @id '"\$Id\$"'
##
## This file has been added:
##  - by '${MY_NAME}'
##  -  on '$(LANG= date +"%a, %d %B %Y %H:%M:%S %z")'
## Feel free to change it or even remove and rebuild it, up to your needs
##
##       1         2         3         4         5         6         7         8
## 45678901234567890123456789012345678901234567890123456789012345678901234567890

'

CHEADER='/** @id '"\$Id\$"'

   This file has been added:
     - by '${MY_NAME}'
     - on '$(LANG= date +"%a, %d %B %Y %H:%M:%S %z")'

*/
//       1         2         3         4         5         6         7         8
// 45678901234567890123456789012345678901234567890123456789012345678901234567890


'

notice() {
    echo -e "\e[1;33m$*\e[0m"
}

run() {
    check=1
    while test $# -gt 0; do
        case "$1" in
            (--no-check) check=0;;
            (*) break;;
        esac
        shift;
    done
    echo -en "\e[1m-> running:\e[0m $* ..."
    result=$($* 2>&1)
    res=$?
    if test $res -ne 0; then
        if test $check -eq 1; then
            echo -e " \e[31merror\e[0m"
            echo -e "\e[1m*** Failed with return code: $res\e[0m"
            if test -n "$result"; then
                echo "$result"
            fi
            exit 1
        else
            echo -e " \e[33mignored\e[0m"
        fi
    else
        echo -e " \e[32msuccess\e[0m"
    fi
}

testtag() {
    local IFS="|"
    egrep -q '^ *'"($*)" configure.ac
}

contains() {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

checkdir() {
    if ! test -d "$1"; then # create path
        run mkdir -p "$1"
        if test -n "${VCS}" -a $novcs -eq 0 && ! contains "$1" "${excludevcs[@]}"; then
            run ${VCS} add "$1"
        fi
    fi
}

checkfile() {
    exists=0
    if test -f "$1" -o -f "$1".in; then
        exists=1
    fi
    test $exists -eq 1
}

to() {
    mode="u=rw,g=rw,o=r"
    while test $# -gt 0; do
        case "$1" in
            (--condition) shift # test for a tag, abort if not set
                if ! testtag "$1"; then
                    return 0
                fi;;
            (--unless) shift # test for a tag, abort if set
                if testtag "$1"; then
                    return 0
                fi;;
            (--mode) shift # test for a tag, abort if not set
                mode="$1";;
            (*) break;;
        esac
        shift;
    done
    if checkfile "$1" && test $rebuild -eq 0 -o "$1" = "configure.ac" \
        && ! contains "$1" "${rebuildfiles[@]}"; then
        # file already exists and must not be rebuilt
        return 1
    fi
    checkdir "$(dirname ${1})"
    echo -en "\e[1m-> generating:\e[0m $1 ..."
    result=$(cat > "$1" 2>&1)
    res=$?
    if test $res -ne 0; then
        echo -e " \e[31merror\e[0m"
        echo -e "\e[1m*** Failed with return code: $res\e[0m"
        if test -n "$result"; then
            echo "$result"
        fi
        exit 1
    else
        echo -e " \e[32msuccess\e[0m"
    fi
    run chmod $mode $1
    if test $exists -eq 0; then
        if test -n "${VCS}" -a $novcs -eq 0 && ! contains "$1" "${excludevcs[@]}"; then
            run ${VCS} add "$1"
            if test "${VCS}" = "svn"; then
                run svn propset svn:keywords "Id" "$1"
            fi
        fi
    fi
    return 0
}

copy() {
    if  checkfile "$1" && test $overwrite -eq 0 \
        && ! contains "$1" "${rebuildfiles[@]}"; then
        # file already exists and must not be rebuilt
        return
    fi
    local source="${0%/*}/$1"
    if ! test -r "${source}"; then
        source="../${source}"
        if ! test -r "${source}"; then
            source="${0%/*}/$1"
        fi
    fi
    run cp "${source}" "$1"
    if test $exists -eq 0; then
        if test -n "${VCS}" -a $novcs -eq 0 && ! contains "$1" "${excludevcs[@]}"; then
            run ${VCS} add "$1"
            if test "${VCS}" = "svn"; then
                run svn propset svn:keywords "Id" "$1"
            fi
        fi
    fi
}

doxyreplace() {
    echo -en "\e[1m-> doxyfile:\e[0m configure $1 ..."
    if sed -i 's|\(^'"$1"' *=\) *.*|\1'" $2"'|g' doc/doxyfile.in; then
        echo -e " \e[32msuccess\e[0m"
    else
        echo -e " \e[31merror\e[0m"
        echo -e "\e[1m**** command: $0 $*\e[0m"
        exit 1
    fi
}

doxyadd() {
    echo -en "\e[1m-> doxyfile:\e[0m configure $1 ..."
    if sed -i '/^'"$1"' *=/a'"$1"' += '"$2" doc/doxyfile.in; then
        echo -e " \e[32msuccess\e[0m"
    else
        echo -e " \e[31merror\e[0m"
        echo -e "\e[1m**** command: $0 $*\e[0m"
        exit 1
    fi
}

vcs2cl() {
    exists=0
    if test -f "ChangeLog"; then
        exists=1
    else
        touch "ChangeLog"
    fi
    if test -x $(which ${VCS}2cl); then
        if test "${VCS}" = "git"; then
            ${VCS}2cl > ChangeLog
        elif test -n "${VCS}"; then
            ${VCS}2cl
        fi
    fi
    if test $exists -eq 0; then
        if test -n "${VCS}" -a $novcs -eq 0 && ! contains "ChangeLog" "${excludevcs[@]}"; then
            run ${VCS} add ChangeLog
        fi
    fi
}

# Check if we are in subversion root, if so, create trunk, branches, tags:
if test "${VCS}" = "svn" -a $novcs -eq 0; then
    if test "$(LANG= svn info | sed -n 's,Relative URL: *,,p')" = "^/"; then
        svn mkdir trunk branches tags
        cd trunk
    fi
fi

# Initialize the environment:
copy ${MY_NAME}
copy ax_init_standard_project.m4
copy ax_cxx_compile_stdcxx_11.m4
copy ax_check_qt.m4
copy resolve-debbuilddeps.sh
copy resolve-rpmbuilddeps.sh
copy build-in-docker.sh
copy build-resource-file.sh
copy sql-to-dot.sed
copy mac-create-app-bundle.sh
AUTHOR=$(gpg -K  | sed -n 's,uid *,,p' | sort | head -1)
if test -z "${AUTHOR}"; then
    AUTHOR="FIRSTNAME LASTNAME (URL) <EMAIL>"
fi
to AUTHORS <<EOF && notice "please edit AUTHORS"
$AUTHOR
EOF
to NEWS <<EOF && notice "please edit NEWS"
$(date) created ${DEFAULT_PROJECT_NAME}
EOF
to README <<EOF && notice "please edit README"
${DEFAULT_PROJECT_NAME}

add description for ${DEFAULT_PROJECT_NAME}
EOF
to configure.ac <<EOF && notice "please edit configure.ac, then rerun $0" && exit 0
${HEADER}m4_define(x_package_name, ${DEFAULT_PROJECT_NAME}) # project's name
m4_define(x_major, 0) # project's major version
m4_define(x_minor, 0) # project's minor version
m4_include(ax_init_standard_project.m4)
AC_INIT(x_package_name, x_version, x_bugreport, x_package_name)
AM_INIT_AUTOMAKE([1.9 tar-pax])
AX_INIT_STANDARD_PROJECT

# requirements, uncomment, what you need:
#AX_USE_CXX
#AX_USE_LIBTOOL
#AX_USE_SCRIPTS
#AX_USE_DOXYGEN
#AX_USE_DEBIAN_PACKAGING
#AX_USE_RPM_PACKAGING
#AX_USE_CPPUNIT
#AX_BUILD_TEST
#AX_BUILD_EXAMPLES
#AX_BUILD_HTML

# qt features, uncomment, what you need:
#AX_CHECK_QT([QT], [QtCore QtGui QtNetwork], [QtWidgets])
#AX_REQUIRE_QT([QT], [QtCore QtGui QtNetwork], [QtWidgets])
#AX_QT_NO_KEYWORDS

# create output
AC_OUTPUT
EOF

PACKAGE_NAME=$(sed -n 's/.*m4_define *( *x_package_name *, *\([^ ]*\) *).*/\1/p' configure.ac)
SAVEIFS="$IFS"
IFS="-" PackageName=( $PACKAGE_NAME )
IFS="$SAVEIFS"
PackageName=${PackageName[*]^}
PackageName=${PackageName// /}

if ! testtag AX_CHECK_QT && \
   ! testtag AX_REQUIRE_QT; then
    echo "${HEADER}MAINTAINERCLEANFILES = makefile.in" | \
        to --condition AX_USE_CXX src/makefile.am
elif ! test -e src/makefile.am; then
    to --condition AX_USE_CXX src/makefile.am <<EOF
${HEADER}bin_PROGRAMS = ${PACKAGE_NAME}

## required to enable the translation feature
LANGUAGE_FILE_BASE = ${PACKAGE_NAME}

## list here the Qt plugins your project depends on
## required to build Mac OS-X app-bundle
QT_PLUGINS = iconengines imageformats platforms

#### enable if you deliver a KDE/Gnome desktop file
#applicationsdir = ${datarootdir}/applications
#dist_applications_DATA = ${PACKAGE_NAME}.desktop

#### enable (ev. instead of bin_PROGRAMS) if you build a library
#lib_LTLIBRARIES = ${PACKAGE_NAME}.la
#${PACKAGE_NAME}_la_SOURCES = libmain.cxx version.cxx
## noop to prevent:
## «src/makefile.am: error: object 'version.\$(OBJEXT)' created both with
## libtool and without»
#${PACKAGE_NAME}_la_CXXFLAGS = \$(AM_CXXFLAGS)

## list headers that are required for build, but that are not installed
noinst_HEADERS = version.hxx

## list all %.hxx files with Q_OBJECT as moc_%.cxx
${PACKAGE_NAME//-/_}_MOCFILES = moc_${PACKAGE_NAME}.cxx

## list all %.ui files as ui_%.hxx
${PACKAGE_NAME//-/_}_UIFILES = ui_${PACKAGE_NAME}.hxx

## list all %.qrc resource files as qrc_%.cxx
## note: if there exists a directory %, the file %.qrc is generated from that
${PACKAGE_NAME//-/_}_RESOURCES =  qrc_languages.cxx # qrc_resources.cxx

## list all final translation files, list all supported languages here
${PACKAGE_NAME//-/_}_TRANSLATIONS = \${LANGUAGE_FILE_BASE}_en.qm	\\
     \${LANGUAGE_FILE_BASE}_de.qm \\
     \${LANGUAGE_FILE_BASE}_fr.qm \\
     \${LANGUAGE_FILE_BASE}_it.qm

## list all C++ files that need translation
${PACKAGE_NAME//-/_}_TR_FILES = main.cxx version.cxx

## automatic assembly, no need to change
${PACKAGE_NAME//-/_}_SOURCES = \${${PACKAGE_NAME//-/_}_TR_FILES} \${BUILT_SOURCES}

## automatic assembly, no need to change
BUILT_SOURCES = \${${PACKAGE_NAME//-/_}_MOCFILES} \
                \${${PACKAGE_NAME//-/_}_UIFILES} \
                \${${PACKAGE_NAME//-/_}_TRANSLATIONS} \
                \${${PACKAGE_NAME//-/_}_RESOURCES}

## automatic assembly, no need to change
EXTRA_DIST_TR = \${${PACKAGE_NAME//-/_}_MOCFILES:moc_%.cxx=%.hxx} \
                \${${PACKAGE_NAME//-/_}_UIFILES:ui_%.hxx=%.ui}

## automatic assembly, no need to change
## except: adapt the pre-delivered qt_%.qm list (language files you copy from qt
EXTRA_DIST = \${EXTRA_DIST_TR} \
             \${${PACKAGE_NAME//-/_}_RESOURCES:qrc_%.cxx:%.qrc} \
             \${${PACKAGE_NAME//-/_}_TRANSLATIONS:%.qm=%.ts} \
             qt_de.qm qt_fr.qm

## automatic assembly, no need to change
LANGUAGE_FILES = \${EXTRA_DIST_TR} \${${PACKAGE_NAME//-/_}_TR_FILES}

MAINTAINERCLEANFILES = makefile.in
EOF
    to --condition AX_USE_CXX src/main.cxx <<EOF
${CHEADER}#include <${PACKAGE_NAME}.hxx>
#include <QApplication>
#include <QCommandLineParser>
#include <iostream>

int main(int argc, char *argv[]) try {
  QApplication a(argc, argv);
  QCommandLineParser parser;
  parser.addHelpOption();
  parser.process(a);
  QStringList scripts(parser.positionalArguments());
  ${PackageName} w;
  w.show();
  return a.exec();
 } catch (std::exception &x) {
  std::cerr<<"**** error: "<<x.what()<<std::endl;
  return 1;
 }
EOF
    to --condition AX_USE_CXX src/${PACKAGE_NAME}.hxx <<EOF
${CHEADER}#ifndef ${PackageName^^}_HXX
#define ${PackageName^^}_HXX

#include <QMainWindow>
#include <ui_${PACKAGE_NAME}.hxx>

/// Main Window
/** Main window for ${PACKAGE_NAME} */
class ${PackageName}: public QMainWindow, protected Ui::${PackageName} {
    Q_OBJECT;
  public:
    explicit ${PackageName}(QWidget *parent = 0): QMainWindow(parent) {
      setupUi(this);
    }
    virtual ~${PackageName}() {}
};

#endif
EOF
    to --condition AX_USE_CXX src/${PACKAGE_NAME}.ui <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>${PackageName}</class>
 <widget class="QMainWindow" name="${PackageName}">
  <property name="geometry">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>800</width>
    <height>600</height>
   </rect>
  </property>
  <property name="windowTitle">
   <string>${PackageName}</string>
  </property>
  <widget class="QWidget" name="centralwidget"/>
  <widget class="QMenuBar" name="menubar">
   <property name="geometry">
    <rect>
     <x>0</x>
     <y>0</y>
     <width>800</width>
     <height>22</height>
    </rect>
   </property>
  </widget>
  <widget class="QStatusBar" name="statusbar"/>
 </widget>
 <resources/>
 <connections/>
</ui>
EOF
    to --condition AX_USE_CXX src/languages.qrc <<EOF
<RCC>
    <qresource prefix="/language">
        <file>${PACKAGE_NAME}_de.qm</file>
        <file>${PACKAGE_NAME}_fr.qm</file>
        <file>${PACKAGE_NAME}_it.qm</file>
        <file>${PACKAGE_NAME}_en.qm</file>
    </qresource>
</RCC>
EOF
fi
to --condition AX_USE_CXX src/version.hxx <<EOF
/*! @file

    @id \$Id\$
*/
//       1         2         3         4         5         6         7         8
// 45678901234567890123456789012345678901234567890123456789012345678901234567890

#include <string>

namespace NAMESPACE {
  /// get package string which consists of package name and package version
  std::string package_string();
  /// get package name
  std::string package_name();
  /// get package version
  std::string version();
  /// get code build date
  std::string build_date();
  /// get author, i.e. copyright holder
  std::string author();
  /// get short package description (1st line of README)
  std::string description();
  /// get long package description (starting at 3rd line in README)
  std::string readme();
  /// get package logo file name
  std::string logo();
  /// get package icon file name
  std::string icon();
  /// used for <code>what filename</code>
  extern const std::string WHAT;
  /// used for <code>ident filename</code>
  extern const std::string IDENT;
}
EOF
to --condition AX_USE_CXX src/version.cxx <<EOF
/*! @file

    @id $Id\$
*/
//       1         2         3         4         5         6         7         8
// 45678901234567890123456789012345678901234567890123456789012345678901234567890

#include <string>

namespace NAMESPACE {
  std::string package_string() {
    return PACKAGE_STRING;
  }
  std::string package_name() {
    return PACKAGE_NAME;
  }
  std::string version() {
    return PACKAGE_VERSION;
  }
  std::string build_date() {
    return BUILD_DATE;
  }
  std::string author() {
    return AUTHOR;
  }
  std::string description() {
    return DESCRIPTION;
  }
  std::string readme() {
    return README;
  }
  std::string logo() {
    return PACKAGE_LOGO;
  }
  std::string icon() {
    return PACKAGE_ICON;
  }
  const std::string WHAT("#(@) " PACKAGE_STRING);
  const std::string IDENT("\$Id: " PACKAGE_STRING);
}
EOF
to --condition AX_USE_SCRIPTS scripts/makefile.am <<EOF
${HEADER}dist_bin_SCRIPTS =

MAINTAINERCLEANFILES = makefile.in
EOF
echo "${HEADER}MAINTAINERCLEANFILES = makefile.in" | to --condition AX_USE_DOXYGEN doc/makefile.am
if testtag AX_BUILD_TEST; then
    to test/runtests.sh < ${0%/*}/test/runtests.sh
fi
to --condition 'AX_BUILD_TEST|AX_USE_CPPUNIT' test/makefile.am <<EOF
${HEADER}$(if testtag AX_USE_CXX; then
cat <<EOF2
AM_CPPFLAGS = -I\${top_srcdir}/src -I\${top_builddir}/src
AM_LDFLAGS = -L\${abs_top_builddir}/src/.libs
$(if testtag AX_USE_LIBTOOL; then
cat <<EOF3
LDADD = -l${PACKAGE_NAME#lib}
EOF3
fi)
EOF2
fi)

TESTS =

MAINTAINERCLEANFILES = makefile.in
EOF
to --condition AX_BUILD_EXAMPLES examples/makefile.am <<EOF
${HEADER}AM_CPPFLAGS = -I\${top_srcdir}/src -I\${top_builddir}/src
AM_LDFLAGS = -L\${abs_top_builddir}/src/.libs
LDADD = -l${PACKAGE_NAME#lib}

MAINTAINERCLEANFILES = makefile.in
EOF
to --condition AX_BUILD_HTML html/makefile.am <<EOF
${HEADER}EXTRA_DIST = \${www_DATA}

wwwdir = \${pkgdatadir}/html
www_DATA = 

MAINTAINERCLEANFILES = makefile.in
EOF
if testtag AX_USE_DOXYGEN; then
    if ! checkfile doc/doxyfile.in || \
        contains doc/doxyfile.in "${rebuildfiles[@]}"; then
        run doxygen -g doc/doxyfile.in
        if test $exists -eq 0; then
            if test -n "${VCS}" -a $novcs -eq 0 && ! contains "doc/doxyfile" "${excludevcs[@]}"; then
                run ${VCS} add doc/doxyfile.in
                if test "${VCS}" = "svn"; then
                    run svn propset svn:keywords "Id" doc/doxyfile.in
                fi
            fi
        fi
        doxyreplace PROJECT_NAME "@PACKAGE_NAME@"
        doxyreplace PROJECT_NUMBER "@PACKAGE_VERSION@"
        doxyreplace PROJECT_BRIEF "@DESCRIPTION@"
        doxyreplace PROJECT_LOGO "@top_srcdir@/@PACKACE_LOGO@"
        doxyreplace INLINE_INHERITED_MEMB YES
        doxyreplace MULTILINE_CPP_IS_BRIEF YES
        doxyreplace TAB_SIZE 2
        doxyreplace ALIASES '"id=\\par File-ID\\n"'
        doxyadd ALIASES '"copy=\\par Copyright\\n"'
        doxyadd ALIASES '"license=\\par License\\n"'
        doxyadd ALIASES '"classmutex=\\par Reentrant:\\nAccess is locked with class static mutex @c "'
        doxyadd ALIASES '"instancemutex=\\par Reentrant:\\nAccess is locked with per instance mutex @c "'
        doxyadd ALIASES '"mutex=\\par Reentrant:\\nAccess is locked with mutex @c "'
        doxyadd ALIASES '"api=\\xrefitem api \\"API Call\\" \\"\\""'
        doxyreplace ENABLE_PREPROCESSING YES
        doxyreplace MACRO_EXPANSION YES
        doxyadd PREDEFINED '"NAMESPACE=@PACKAGE_NAME@"'
        doxyreplace BUILTIN_STL_SUPPORT YES
        doxyreplace DISTRIBUTE_GROUP_DOC YES
        doxyreplace EXTRACT_ALL YES
        doxyreplace EXTRACT_PACKAGE YES
        doxyreplace EXTRACT_PRIVATE YES
        doxyreplace EXTRACT_STATIC YES
        doxyreplace EXTRACT_LOCAL_CLASSES YES
        doxyreplace EXTRACT_LOCAL_METHODS YES
        doxyreplace EXTRACT_ANON_NSPACES YES
        doxyreplace SHOW_GROUPED_MEMB_INC YES
        doxyreplace SORT_MEMBERS_CTORS_1ST YES
        doxyreplace WARN_IF_UNDOCUMENTED NO
        doxyreplace WARN_LOGFILE doxygen.errors
        doxyreplace INPUT "@top_srcdir@/src"
        if testtag AX_USE_SCRIPTS; then
            doxyadd INPUT "@top_srcdir@/scripts"
        fi
        if testtag AX_BUILD_HTML; then
            doxyadd INPUT "@top_srcdir@/html"
        fi
        if testtag AX_BUILD_TEST AX_USE_CPPUNIT; then
            doxyadd INPUT "@top_srcdir@/test"
        fi
        doxyreplace FILE_PATTERNS '*.c *.cc *.cxx *.cpp *.c++ *.java *.ii *.ixx *.ipp *.i++ *.inl *.idl *.ddl *.odl *.h *.hh *.hxx *.hpp *.h++ *.cs *.d *.php *.php4 *.php5 *.phtml *.inc *.m *.markdown *.md *.mm *.dox *.py *.f90 *.f *.for *.tcl *.vhd *.vhdl *.ucf *.qsf *.as *.js *.wt *.sql'
        doxyreplace RECURSIVE YES
        doxyreplace EXCLUDE_PATTERNS "moc_* uic_* qrc_*"
        if testtag AX_BUILD_EXAMPLES; then
            doxyreplace EXAMPLE_PATH @top_srcdir@/examples
        fi
        doxyreplace EXAMPLE_RECURSIVE YES
        doxyreplace FILTER_PATTERNS '*.wt=doxygen-webtester.sed *.sql=@top_srcdir@/sql-to-dot.sed'
        doxyreplace SOURCE_BROWSER YES
        doxyreplace INLINE_SOURCES YES
        doxyreplace GENERATE_TESTLIST YES
        doxyreplace GENERATE_TREEVIEW NO
        doxyreplace SEARCHENGINE NO
        doxyreplace GENERATE_HTML YES
        doxyreplace GENERATE_LATEX NO
        doxyreplace LATEX_BATCHMODE YES
        doxyreplace LATEX_HIDE_INDICES YES
        doxyreplace COMPACT_RTF YES
        doxyreplace RTF_HYPERLINKS YES
        doxyreplace GENERATE_TAGFILE "@PACKAGE_NAME@.doxytag"
        doxyreplace HIDE_UNDOC_RELATIONS NO
        doxyreplace HAVE_DOT YES
        doxyreplace CLASS_GRAPH YES
        doxyreplace TEMPLATE_RELATIONS YES
        doxyreplace DOT_IMAGE_FORMAT svg
        doxyreplace INTERACTIVE_SVG NO
        doxyreplace DOT_TRANSPARENT YES
    fi
fi
if testtag AX_USE_DEBIAN_PACKAGING; then
    checkdir debian
    to debian/changelog.in <<EOF
@PACKAGE@ (@PACKAGE_VERSION@~@DISTRO@.@BUILD_NUMBER@) @DISTRO@; urgency=low

  * Please see ChangeLog of @PACKAGE@

 -- @AUTHOR@  @BUILD_DATE@
EOF
    BUILD_DEPENDS="debhelper, ${VCSDEPENDS} pkg-config, automake, libtool, autotools-dev, lsb-release $(if testtag AX_USE_DOXYGEN; then echo -n ", doxygen, graphviz, mscgen"; fi; if testtag AX_USE_CPPUNIT; then echo -n ", libcppunit-dev"; fi; if testtag AX_CXX_QT || testtag AX_CHECK_QT AX_REQUIRE_QT; then echo -n ", qt5-default | libqt4-core | libqtcore4, qt5-qmake | qt4-qmake, qtbase5-dev | libqt4-dev, qtbase5-dev-tools | qt4-dev-tools, qttools5-dev-tools | qt4-dev-tools, qttools5-dev-tools | qt4-dev-tools"; fi)"
    to debian/control.in <<EOF
Source: @PACKAGE_NAME@
Priority: extra
Maintainer: @AUTHOR@
Build-Depends: ${BUILD_DEPENDS}

Package: @PACKAGE_NAME@
Section: $(if testtag AX_USE_LIBTOOL; then echo  "libs"; fi)
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: @DESCRIPTION@
@README_DEB@
$(      if testtag AX_USE_LIBTOOL; then
            cat <<EOF2

Package: @PACKAGE_NAME@-dev
Section: libdevel
Architecture: any
Depends: @PACKAGE_NAME@ (= \${binary:Version}), ${BUILD_DEPENDS}
Description: @DESCRIPTION@ - Development Package
@README_DEB@
EOF2
          fi)
EOF
    to debian/docs <<EOF
NEWS
README
EOF
    to --condition AX_USE_LIBTOOL debian/${PACKAGE_NAME}.install <<EOF
usr/lib/lib*.so.*
EOF
    to --condition AX_USE_LIBTOOL debian/${PACKAGE_NAME}-dev.install <<EOF
usr/include/*
usr/lib/lib*.a
usr/lib/lib*.so
usr/lib/pkgconfig/*
usr/lib/*.la
usr/share/${PACKAGE_NAME}
usr/share/doc/${PACKAGE_NAME}/html
EOF
    to --mode "u=rwx,g=rwx,o=rx" debian/rules <<EOF
${HEADER}%:
	dh \$@
EOF
    echo 7 | to debian/compat
fi
to ${PACKAGE_NAME}.desktop.in <<EOF
[Desktop Entry]
Type=Application
Name=${PACKAGE_NAME}
GenericName=${PACKAGE_NAME}
Comment=@DESCRIPTION@
Icon=@prefix@/share/@PACKAGE_NAME@/@PACKAGE_ICON@
Exec=${PACKAGE_NAME} %u
Terminal=false
Categories=Qt;Utility;
EOF
to --condition AX_USE_RPM_PACKAGING ${PACKAGE_NAME}.spec.in <<EOF
Summary: @DESCRIPTION@
Name: @PACKAGE_NAME@
Version: @VERSION@
Release: @BUILD_NUMBER@%{?dist}
License: LGPL
Group: $(if testtag AX_USE_LIBTOOL; then
  echo Development/Libraries/C++;
else
  echo Applications/...;
fi)
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: gnupg, ${VCSDEPENDS} make, automake, autoconf, rpm-build$(
    if testtag AX_USE_DOXYGEN; then
      echo -n ", doxygen";
    fi)
%if 0%{?fedora} != 20
$(if testtag AX_USE_DOXYGEN; then echo -n "BuildRequires: graphviz"; fi)
%endif
%if 0%{?fedora} || 0%{?rhel} || 0%{?rhl} || 0%{?centos} || 0%{?centos_ver} || 0%{?centos_version}
BuildRequires: pkgconfig, redhat-lsb$(
    if testtag AX_USE_CPPUNIT; then
      echo -n ", cppunit-devel";
    fi)
%if ! ( 0%{?centos} || 0%{?centos_ver} || 0%{?centos_version} )
$(if testtag AX_USE_DOXYGEN; then echo -n "BuildRequires: mscgen"; fi)
$(if testtag AX_REQUIRE_QT || testtag AX_CHECK_QT AX_REQUIRE_QT; then echo -n "BuildRequires: qt5-qtbase-devel, qt5-qttools, qt5-qtwebkit-devel"; fi)
%else
$(if testtag AX_REQUIRE_QT || testtag AX_CHECK_QT AX_REQUIRE_QT; then echo -n "BuildRequires: qt-devel"; fi)
%endif
%else%if 0%{?suse_version} || 0%{?sles_version}
BuildRequires: pkg-config, lsb-release$(
    if testtag AX_USE_CPPUNIT; then
      echo -n ", libcppunit-devel";
    fi)
%if 0%{?suse_version} < 1200 ||  0%{?sles_version} < 1200
$(if testtag AX_REQUIRE_QT || testtag AX_CHECK_QT AX_REQUIRE_QT; then echo -n "BuildRequires: libqt4-devel, qt4-x11-tools, libQtWebKit-devel"; fi)
%else
$(if testtag AX_REQUIRE_QT || testtag AX_CHECK_QT AX_REQUIRE_QT; then echo -n "BuildRequires: libqt5-qtbase-devel, libqt5-qttools, libQt5WebKit5-devel"; fi)
%endif
%endif%endif

%description
@README@
$(if testtag AX_USE_LIBTOOL; then
echo
echo This package contains only the shared libraries required at runtime.
fi)


%prep
%setup -q
./configure --prefix=/usr \\
            --sysconfdir=/etc \\
            --docdir=/usr/share/doc/packages/@PACKAGE_NAME@ \\
            --libdir=/usr/%_lib

%build
make

%install
DESTDIR=\$RPM_BUILD_ROOT make install

%clean
rm -rf \$RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
$(if testtag AX_USE_LIBTOOL; then
echo '/usr/%_lib/@PACKAGE_NAME@.so.*'
else
echo '/usr/bin/*'
echo '/usr/share/applications/*'
fi)
%doc
$(if testtag AX_USE_LIBTOOL; then
  cat <<EOF2
/usr/share/doc/packages/@PACKAGE_NAME@/AUTHORS
/usr/share/doc/packages/@PACKAGE_NAME@/COPYING
/usr/share/doc/packages/@PACKAGE_NAME@/ChangeLog
/usr/share/doc/packages/@PACKAGE_NAME@/INSTALL
/usr/share/doc/packages/@PACKAGE_NAME@/NEWS
/usr/share/doc/packages/@PACKAGE_NAME@/README
EOF2
else
  echo '/usr/share/*'
fi)

$(if testtag AX_USE_LIBTOOL; then
cat <<EOF2
%package devel
Summary: @DESCRIPTION@
Group: Development/Libraries/C++
Requires: @PACKAGE_NAME@ = @VERSION@

%description devel
@README@

This Package contains all files required for developement.

%files devel
%defattr(-,root,root,-)
/usr/%_lib/@PACKAGE_NAME@.so
/usr/%_lib/@PACKAGE_NAME@.a
/usr/%_lib/@PACKAGE_NAME@.la
/usr/%_lib/pkgconfig
/usr/include/*
%doc
/usr/share/@PACKAGE_NAME@
/usr/share/doc/packages/@PACKAGE_NAME@/html
EOF2
fi)

%changelog

EOF
SUBDIRS=""
if testtag AX_USE_CXX; then
    SUBDIRS="${SUBDIRS} src"
fi
if testtag AX_BUILD_TEST AX_USE_CPPUNIT; then
    SUBDIRS="${SUBDIRS} test"
fi
if testtag AX_USE_SCRIPTS; then
    SUBDIRS="${SUBDIRS} scripts"
fi
if testtag AX_USE_DOXYGEN; then
    SUBDIRS="${SUBDIRS} doc"
fi
if testtag AX_BUILD_EXAMPLES; then
    SUBDIRS="${SUBDIRS} examples"
fi
if testtag AX_BUILD_HTML; then
    SUBDIRS="${SUBDIRS} html"
fi
for d in src test scripts doc examples html; do
    if test -d "$d" -a "${SUBDIRS//$d/}" = "${SUBDIRS}"; then
        SUBDIRS="${SUBDIRS} $d"
    fi
done
to --mode "u=rwx,g=rwx,o=rx" autogen.sh <<EOF
#!/bin/bash -e
if test -n "$VCS" -a -d .$VCS -a -e -x $(which ${VCS}2cl); then
$(case "$VCS" in
  (svn) echo "    ${VCS}2cl";;
  (git) echo "    ${VCS}2cl > ChangeLog";;
esac)
fi
aclocal
$(if testtag AX_USE_LIBTOOL; then echo libtoolize --force; fi)
automake -a
autoconf
EOF
to makefile.am<<EOF
${HEADER}SUBDIRS =${SUBDIRS}

desktopdir = \${datadir}/applications
desktop_DATA = @PACKAGE_DESKTOP@
dist_pkgdata_DATA = @PACKAGE_ICON@ ax_check_qt.m4 bootstrap.sh		\\
                    resolve-rpmbuilddeps.sh autogen.sh			\\
                    ax_cxx_compile_stdcxx_11.m4 build-in-docker.sh	\\
                    build-resource-file.sh				\\
                    ax_init_standard_project.m4				\\
                    mac-create-app-bundle.sh resolve-debbuilddeps.sh    \\
                    sql-to-dot.sed
dist_doc_DATA = AUTHORS NEWS README COPYING INSTALL ChangeLog

MAINTAINERCLEANFILES = makefile.in
EOF
to --condition AX_USE_LIBTOOL src/${PACKAGE_NAME}.pc.in <<EOF
${HEADER}prefix=@prefix@
exec_prefix=@exec_prefix@
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include
translationsdir=@datadir@/@PACKAGE_NAME@/translations

Name: @PACKAGE_NAME@
Description: @DESCRIPTION@
Version: @VERSION@
Libs: -L\${libdir} -l${PACKAGE_NAME#lib} @LDFLAGS@
Cflags: -I\${includedir} @CPPFLAGS@
Requires: @PKG_REQUIREMENTS@
EOF

#### Cleanup If Makefile Exists ####
if test -f makefile; then
    run --no-check make distclean
fi

#### Bootstrap Before Configure ####
run --no-check vcs2cl
run aclocal
if testtag AX_USE_LIBTOOL; then run libtoolize --force; fi
run automake -a
run autoconf

#### Run Configure If User Requires ####
if test "$configure" -eq 1; then
    ./configure $*
fi

#### Run Make If User Requires ####
if test "$build" -eq 1; then
    make $buildtarget
fi

#### Build In Docker If User Requires ####
if test "$docker" -eq 1; then
    ./build-in-docker.sh
fi
