#include <QtGui/QApplication>
#include <QtOpenGL/QGLWidget>
#include <QDeclarativeContext>
#include <QtDeclarative>

#include "qmlapplicationviewer.h"
#include "objectlistmodel.h"
#include "lightobjects.h"
#include "thermalobjects.h"


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QmlApplicationViewer viewer;

    qmlRegisterType<CustomListModel>("bticino", 1, 0, "CustomListModel");
    qmlRegisterUncreatableType<ObjectInterface>("bticino", 1, 0, "ObjectInterface",
        "unable to create an ObjectInterface instance");

    QGLFormat f = QGLFormat::defaultFormat();
    f.setSampleBuffers(true);
    f.setSamples(4);

    ObjectListModel objmodel;
    objmodel.appendRow(new Light("lampada scrivania", true));
    objmodel.appendRow(new Light("lampadario soggiorno", false));
    objmodel.appendRow(new Dimmer("faretti soggiorno", false, 50));
    objmodel.appendRow(new Light("lampada da terra soggiorno", false));
    objmodel.appendRow(new Light("abat jour", true));
    objmodel.appendRow(new Light("abat jour", true));
    objmodel.appendRow(new Light("lampada studio", true));
    objmodel.appendRow(new ThermalControlUnit("Impianto termico 1", 22, ThermalControlUnit::SummerMode));

    CustomListModel::setSource(&objmodel);

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
