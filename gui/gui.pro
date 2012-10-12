TARGET = BtExperience

# This is required for QtCreator to display the files in the project tree
# the real deployment is performed below using plain copy commands
folder_01.sources = skins/default
DEPLOYMENT += folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH = ./skins/default

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

include(../config.pri)

INCLUDEPATH += ./common_files
INCLUDEPATH += ../BtObjects ../BtObjects/ts ../BtObjects/devices
DEPENDPATH += ../BtObjects ../BtObjects/ts ../BtObjects/devices
LIBS += -lssl -L../bin/$${HARDWARE}/BtObjects -lbtobjects

!mac {
    # '\$\$' outputs $$ to the Makefile, make transforms $$ into a single $, then you need a backslash for the shell
    LIBS += -Wl,-rpath=\\'\$\$'ORIGIN:\\'\$\$'ORIGIN/BtObjects
}

maliit {
    CONFIG += link_pkgconfig
    PKGCONFIG += maliit-1.0 maliit-settings-1.0
    DEFINES += BT_MALIIT
}

QT += opengl xml

DESTDIR = ../bin/$${HARDWARE}

isEmpty(PREFIX) {
    target.path = $${OUT_PWD}/../dist/$${HARDWARE}
} else {
    target.path = $${PREFIX}
}

target.commands += mkdir -p $${target.path}/gui $${target.path}/gui/locale $${target.path}/BtObjects &&
target.commands += cp -LR $${PWD}/skins $${target.path}/gui/ &&
# the ls check below is to account for the case when there are no .qm files
target.commands += (if ls $${PWD}/locale/*.qm 2>/dev/null; then cp -LR $${PWD}/locale/*.qm $${target.path}/gui/locale; else true; fi) &&
target.commands += cp -L $${PWD}/../layout.xml $${target.path}/ &&
target.commands += cp -L $${PWD}/../archive.xml $${target.path}/ &&
target.commands += cp -L $${PWD}/../conf.xml $${target.path}/ &&
target.commands += cp -L $${PWD}/../BtObjects/qmldir $${target.path}/BtObjects/ &&
target.commands += cp -L $${DESTDIR}/$${TARGET} $${target.path}/ &&
!isArm() {
    target.commands += cp -L $${PWD}/common_files/lib/x86/libcommon.so.0 $${target.path}/ &&
}
target.commands += true
# The target above is created and added to INSTALLS in qmlapplicationviewer.pri, so we don't re-add
# it here
# INSTALLS += target

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += \
    main.cpp \
    audiostate.cpp \
    eventfilters.cpp \
    globalproperties.cpp \
    guisettings.cpp \
    imagereader.cpp \
    inputcontextwrapper.cpp \
    player.cpp \
    ringtonemanager.cpp

HEADERS += \
    audiostate.h \
    eventfilters.h \
    globalproperties.h \
    guisettings.h \
    imagereader.h \
    inputcontextwrapper.h \
    player.h \
    ringtonemanager.h

TRANSLATIONS += locale/bt_experience_it.ts

mac {
    APP_DIR = $${DESTDIR}/$${TARGET}.app/Contents
    CONFIG(debug, debug|release) {
        DEBUG_SUFFIX = _debug
    } else {
        DEBUG_SUFFIX = _release
    }

    QMAKE_POST_LINK += mkdir -p $${APP_DIR}/MacOS/BtObjects $${APP_DIR}/Resources/gui &&
    QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/skins $${APP_DIR}/Resources/gui/ &&
    QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/locale $${APP_DIR}/Resources/gui/ &&
    QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/../layout.xml $${APP_DIR}/MacOS/ &&
    QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/../archive.xml $${APP_DIR}/MacOS/ &&
    QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/../conf.xml $${APP_DIR}/MacOS/ &&
    QMAKE_POST_LINK += cp -L $${DESTDIR}/BtObjects/libbtobjects$${DEBUG_SUFFIX}.dylib $${APP_DIR}/MacOS/BtObjects/libbtobjects.dylib &&
    QMAKE_POST_LINK += cp -L $${PWD}/../BtObjects/qmldir $${APP_DIR}/MacOS/BtObjects/ &&
    QMAKE_POST_LINK += cp -L $${PWD}/common_files/lib/x86/libcommon.dylib.0 $${APP_DIR}/MacOS/ &&
    QMAKE_POST_LINK += install_name_tool -change libcommon.dylib.0 @executable_path/libcommon.dylib.0 $${APP_DIR}/MacOS/BtObjects/libbtobjects.dylib &&
    QMAKE_POST_LINK += install_name_tool -change libcommon.dylib.0 @executable_path/libcommon.dylib.0 $${APP_DIR}/MacOS/$${TARGET} &&
    QMAKE_POST_LINK += true
} else {
    QMAKE_POST_LINK += mkdir -p $${DESTDIR}/gui &&
    QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/skins $${DESTDIR}/gui/ &&
    QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/locale $${DESTDIR}/gui/ &&
    QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/../layout.xml $${DESTDIR}/ &&
    QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/../archive.xml $${DESTDIR}/ &&
    QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/../conf.xml $${DESTDIR}/ &&
    QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/../BtObjects/qmldir $${DESTDIR}/BtObjects/ &&

    isArm() {
        QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/common_files/libcommon.so.0 $${DESTDIR}/ &&
    } else {
        QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/common_files/lib/x86/libcommon.so.0 $${DESTDIR}/ &&
        QMAKE_POST_LINK += $${INSTALL_CMD} $${PWD}/../extra $${DESTDIR}/ &&
    }
    QMAKE_POST_LINK += true
}
