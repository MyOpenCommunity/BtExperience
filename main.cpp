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
#include "thermal_device.h"
#include "probe_device.h"

#include <logger.h>

#define MAIN_WIDTH 1024
#define MAIN_HEIGHT 600

#define OBJECTS_NAMESPACE "BtObjects"

// Start definitions required by libcommon
logger *app_logger;
int VERBOSITY_LEVEL;

char *Prefix = const_cast<char*>("<BtExperience>");

int use_ssl = false;
char *ssl_cert_key_path = NULL;
char *ssl_certificate_path = NULL;
// End definitions required by libcommon

QHash<GlobalField, QString> *bt_global::config;


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

ControlledProbeDevice *getProbeDevice(QString probe_where)
{
    return bt_global::add_device_to_cache(new ControlledProbeDevice(probe_where, "0", probe_where,
                                            ControlledProbeDevice::CENTRAL_99ZONES, ControlledProbeDevice::NORMAL));
}

void createObjects(ObjectListModel &objmodel)
{
    objmodel.appendRow(new Light("lampada scrivania", "13", bt_global::add_device_to_cache(new LightingDevice("13"))));
    objmodel.appendRow(new Light("lampadario soggiorno", "1", bt_global::add_device_to_cache(new LightingDevice("1"))));
    objmodel.appendRow(new Dimmer("faretti soggiorno", "29", bt_global::add_device_to_cache(new DimmerDevice("29", PULL))));
    objmodel.appendRow(new Light("lampada da terra soggiorno","2",  bt_global::add_device_to_cache(new LightingDevice("2"))));
    objmodel.appendRow(new Light("abat jour", "3", bt_global::add_device_to_cache(new LightingDevice("3"))));
    objmodel.appendRow(new Light("abat jour", "4", bt_global::add_device_to_cache(new LightingDevice("4"))));
    objmodel.appendRow(new Light("lampada studio", "5", bt_global::add_device_to_cache(new LightingDevice("5"))));
    objmodel.appendRow(new ThermalControlUnit99Zones(QString::fromLocal8Bit("unità centrale"), "", bt_global::add_device_to_cache(new ThermalDevice99Zones("0"))));
    objmodel.appendRow(new ThermalControlledProbe("zona giorno", "1", getProbeDevice("5")));
    objmodel.appendRow(new ThermalControlledProbe("zona notte", "2", getProbeDevice("2")));
    objmodel.appendRow(new ThermalControlledProbe("zona taverna", "3", getProbeDevice("3")));
    objmodel.appendRow(new ThermalControlledProbe("zona studio", "4", getProbeDevice("4")));
}

void messageHandler(QtMsgType type, const char *msg)
{
    switch (type) {
    case QtDebugMsg:
        app_logger->debug(LOG_NOTICE, (char *) msg);
        break;

    case QtWarningMsg:
        app_logger->debug(LOG_INFO, (char *) msg);
        break;
    case QtCriticalMsg:
        fprintf(stderr, "%s Critical: %s\n", Prefix, msg);
        break;
    case QtFatalMsg:
    default:
        fprintf(stderr, "%s FATAL %s\n", Prefix, msg);
        // deliberately core dump
        abort();
    }
}

void setupLogger(QString log_file)
{
    app_logger = new logger(log_file.toAscii().data(), true);

    setvbuf(stdout, (char *)NULL, _IONBF, 0);
    setvbuf(stderr, (char *)NULL, _IONBF, 0);

    qInstallMsgHandler(messageHandler);
}


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    setupLogger("/var/tmp/BTicino.log");
    VERBOSITY_LEVEL = 3;
    startCore();
    QmlApplicationViewer viewer;

    qmlRegisterType<CustomListModel>(OBJECTS_NAMESPACE, 1, 0, "CustomListModel");
    qmlRegisterUncreatableType<ObjectInterface>(OBJECTS_NAMESPACE, 1, 0, "ObjectInterface",
        "unable to create an ObjectInterface instance");
    qmlRegisterUncreatableType<ThermalControlUnit99Zones>(OBJECTS_NAMESPACE, 1, 0, "ThermalControlUnit99Zones",
        "unable to create an ThermalControlUnit99Zones instance");

    qmlRegisterUncreatableType<ThermalControlledProbe>(OBJECTS_NAMESPACE, 1, 0, "ThermalControlledProbe",
        "unable to create an ThermalControlledProbe instance");

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
    viewer.engine()->rootContext()->setContextProperty("main_width", MAIN_WIDTH);
    viewer.engine()->rootContext()->setContextProperty("main_height", MAIN_HEIGHT);
    viewer.setMainQmlFile(QLatin1String("qml/bt_experience/main.qml"));

#ifdef Q_WS_X11
    viewer.resize(MAIN_WIDTH, MAIN_HEIGHT);
    viewer.showExpanded();
#else
    viewer.showFullScreen();
#endif

    return app.exec();
}
