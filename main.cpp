#include <QtGui/QApplication>
#include <QtOpenGL/QGLWidget>

#include "qmlapplicationviewer.h"

int main(int argc, char *argv[])
{
    qDebug("Paint engine opengl 1!");
    QGL::setPreferredPaintEngine(QPaintEngine::OpenGL);
    QApplication app(argc, argv);

    QmlApplicationViewer viewer;
    viewer.setViewport(new QGLWidget);
    viewer.setViewportUpdateMode(QGraphicsView::FullViewportUpdate);
    viewer.setRenderHint(QPainter::Antialiasing, true);
    viewer.setRenderHint(QPainter::SmoothPixmapTransform, true);
    viewer.setRenderHint(QPainter::HighQualityAntialiasing, true);
    viewer.setRenderHint(QPainter::TextAntialiasing, true);

    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setMainQmlFile(QLatin1String("qml/bt_experience/main.qml"));

#ifdef Q_WS_X11
    viewer.showExpanded();
#else
    viewer.showFullScreen();
#endif

    return app.exec();
}
