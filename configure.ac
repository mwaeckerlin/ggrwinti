## @id $Id$
##
## This file has been added:
##  - by bootstrap.sh
##  -  on Thu, 28 April 2016 15:01:00 +0200
## Feel free to change it or even remove and rebuild it, up to your needs
##
##       1         2         3         4         5         6         7         8
## 45678901234567890123456789012345678901234567890123456789012345678901234567890

m4_define(x_package_name, ggrwinti) # project's name
m4_define(x_major, 0) # project's major version
m4_define(x_minor, 1) # project's minor version
m4_include(ax_init_standard_project.m4)
AC_INIT(x_package_name, x_version, x_bugreport, x_package_name)
AM_INIT_AUTOMAKE([1.9 tar-pax])
AX_INIT_STANDARD_PROJECT

# requirements, uncomment, what you need:
#AX_USE_CXX
#AX_USE_LIBTOOL
AX_USE_SCRIPTS
AX_USE_DOXYGEN
AX_USE_DEBIAN_PACKAGING
#AX_USE_RPM_PACKAGING
#AX_USE_CPPUNIT
#AX_BUILD_TEST
#AX_BUILD_EXAMPLES
AX_BUILD_HTML

# qt features, uncomment, what you need:
#AX_CHECK_QT([QT], [QtCore QtGui QtNetwork], [QtWidgets])
#AX_REQUIRE_QT([QT], [QtCore QtGui QtNetwork], [QtWidgets])
#AX_QT_NO_KEYWORDS

# create output
AC_OUTPUT
