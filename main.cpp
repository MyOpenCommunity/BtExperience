#include <QtGui/QApplication>
#include <QtOpenGL/QGLWidget>
#include <QDeclarativeContext>
#include <QtDeclarative>

#include <logger.h>

#include "qmlapplicationviewer.h"

// Start definitions required by libcommon
logger *app_logger;
int VERBOSITY_LEVEL;

char *Prefix = const_cast<char*>("<BtExperience>");

int use_ssl = false;
char *ssl_cert_key_path = NULL;
char *ssl_certificate_path = NULL;
// End definitions required by libcommon

#define MAIN_WIDTH 1024
#define MAIN_HEIGHT 600


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

    QmlApplicationViewer viewer;
    qDebug() << "***** BtExperience start! *****";

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
