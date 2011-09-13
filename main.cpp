#include <QtGui/QApplication>
#include <QtOpenGL/QGLWidget>

#include "qmlapplicationviewer.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QmlApplicationViewer viewer;
    viewer.setViewport(new QGLWidget);
    viewer.setViewportUpdateMode(QGraphicsView::FullViewportUpdate);

    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
        viewer.setMainQmlFile(QLatin1String("qml/bt_experience/main.qml"));

#ifdef Q_WS_X11
    viewer.showExpanded();
#else
    viewer.showFullScreen();
#endif

    return app.exec();
}
