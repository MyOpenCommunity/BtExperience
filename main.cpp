#include <QtGui/QApplication>
#include <QtOpenGL/QGLWidget>
#include <QDeclarativeContext>
#include <QtDeclarative>

#include "qmlapplicationviewer.h"
#include "objectlistmodel.h"
#include "lightobjects.h"
#include "thermalobjects.h"

#include "openclient.h"
#include "frame_classes.h"
#include "main.h"
#include "device.h"
#include "devices_cache.h"
#include "lighting_device.h"

#include <logger.h>


logger *app_logger;


void startCore()
{
    bt_global::config = new QHash<GlobalField, QString>();
    (*bt_global::config)[TS_NUMBER] = QString::number(0);

    ClientWriter::setDelay((*bt_global::config)[TS_NUMBER].toInt() * TS_NUMBER_FRAME_DELAY);

    QHash<int, Clients> clients;
    QHash<int, ClientReader*> monitors;

    monitors[MAIN_OPENSERVER] = new ClientReader(Client::MONITOR);
    clients[MAIN_OPENSERVER].command = new ClientWriter(Client::COMMAND);
    clients[MAIN_OPENSERVER].request = new ClientWriter(Client::REQUEST);

    ClientReader *client_supervisor = new ClientReader(Client::SUPERVISOR);
    client_supervisor->forwardFrame(monitors[MAIN_OPENSERVER]);
    clients[MAIN_OPENSERVER].supervisor = client_supervisor;

    FrameReceiver::setClientsMonitor(monitors);
    FrameSender::setClients(clients);
}

void createObjects(ObjectListModel &objmodel)
{
    objmodel.appendRow(new Light("lampada scrivania", bt_global::add_device_to_cache(new LightingDevice("13"))));
    objmodel.appendRow(new Light("lampadario soggiorno", bt_global::add_device_to_cache(new LightingDevice("1"))));
    objmodel.appendRow(new Dimmer("faretti soggiorno", bt_global::add_device_to_cache(new DimmerDevice("29", PULL))));
    objmodel.appendRow(new Light("lampada da terra soggiorno", bt_global::add_device_to_cache(new LightingDevice("2"))));
    objmodel.appendRow(new Light("abat jour", bt_global::add_device_to_cache(new LightingDevice("3"))));
    objmodel.appendRow(new Light("abat jour", bt_global::add_device_to_cache(new LightingDevice("4"))));
    objmodel.appendRow(new Light("lampada studio", bt_global::add_device_to_cache(new LightingDevice("5"))));
    objmodel.appendRow(new ThermalControlUnit("Impianto termico 1", 22, ThermalControlUnit::SummerMode));
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    startCore();
    QmlApplicationViewer viewer;

    qmlRegisterType<CustomListModel>("bticino", 1, 0, "CustomListModel");
    qmlRegisterUncreatableType<ObjectInterface>("bticino", 1, 0, "ObjectInterface",
        "unable to create an ObjectInterface instance");

    QGLFormat f = QGLFormat::defaultFormat();
    f.setSampleBuffers(true);
    f.setSamples(4);

    ObjectListModel objmodel;
    createObjects(objmodel);

    device::initDevices();
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
