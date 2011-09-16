#include <QtGui/QApplication>
#include <QtOpenGL/QGLWidget>

#include "qmlapplicationviewer.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QmlApplicationViewer viewer;

    QGLFormat f = QGLFormat::defaultFormat();
    f.setSampleBuffers(true);
    f.setSamples(4);

    QGLWidget *w = new QGLWidget(f);
    viewer.setViewport(w);
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
