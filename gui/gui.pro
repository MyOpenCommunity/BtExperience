TARGET = BtExperience

!mac {
    # Add more folders to ship with the application, here
    folder_01.source = skins/default
    folder_01.target = skins
    DEPLOYMENTFOLDERS = folder_01
}

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH = ./skins/default

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

include(../config.pri)

INCLUDEPATH += ./common_files
LIBS += -lssl

maliit {
    CONFIG += link_pkgconfig
    PKGCONFIG += maliit-1.0
    DEFINES += BT_MALIIT
}

QT += opengl


# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += \
    main.cpp \
    eventfilters.cpp \
    globalproperties.cpp \
    guisettings.cpp \
    imagereader.cpp \
    inputcontextwrapper.cpp

DESTDIR = ..

HEADERS += \
    eventfilters.h \
    globalproperties.h \
    guisettings.h \
    imagereader.h \
    inputcontextwrapper.h

TRANSLATIONS += linguist-ts/bt_experience_it.ts

mac {
    APP_DIR = $${DESTDIR}/$${TARGET}.app/Contents

    QMAKE_POST_LINK += ln -sf ../../../gui $${APP_DIR}/Resources/gui &&
    QMAKE_POST_LINK += mkdir -p $${APP_DIR}/MacOS/BtObjects &&
    QMAKE_POST_LINK += cp -L ../BtObjects/libbtobjects.dylib $${APP_DIR}/MacOS/BtObjects/ &&
    QMAKE_POST_LINK += cp -L ../BtObjects/qmldir $${APP_DIR}/MacOS/BtObjects/ &&
    QMAKE_POST_LINK += cp -L common_files/lib/x86/libcommon.dylib.0 $${APP_DIR}/MacOS/ &&
    QMAKE_POST_LINK += install_name_tool -change libcommon.dylib.0 @executable_path/libcommon.dylib.0 $${APP_DIR}/MacOS/BtObjects/libbtobjects.dylib &&
    QMAKE_POST_LINK += install_name_tool -change libcommon.dylib.0 @executable_path/libcommon.dylib.0 $${APP_DIR}/MacOS/BtExperience.x86 && 
    QMAKE_POST_LINK += true
}
