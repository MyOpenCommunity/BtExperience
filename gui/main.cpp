#include <QtGlobal> // Q_WS_QWS

#if defined(Q_WS_QWS) && !defined(__arm__)
// assume that QWS on PC is using QVFb and does not support OpenGL
#define USE_OPENGL 0
#else
#define USE_OPENGL 1
#endif

#if defined(Q_WS_QWS)
#include <QScreen>
#endif

#include <QtGui/QApplication>
#if USE_OPENGL
#include <QtOpenGL/QGLWidget>
#endif
#include <QDeclarativeContext>
#include <QtDeclarative>

#include <logger.h>

#include "qmlapplicationviewer.h"
#include "inputcontextwrapper.h"
#include "eventfilters.h"

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
	switch (type)
	{
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

	qmlRegisterType<QInputContext>();

	QmlApplicationViewer viewer;
	qDebug() << "***** BtExperience start! *****";

	QProcessEnvironment env = QProcessEnvironment::systemEnvironment();

	if (env.contains("QT_IM_MODULE"))
	{
#if (defined(Q_WS_QPA) || defined(Q_WS_QWS)) && (QT_VERSION < 0x050000)
		// Workaround for Lighthouse/QWS, copied from Maliit PlainQT example app
		app.setInputContext(QInputContextFactory::create(env.value("QT_IM_MODULE"), &app));
#endif

		// see comment on InputMethodEventFilter above
		viewer.installEventFilter(new InputMethodEventFilter);
	}

#if USE_OPENGL
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
#endif

	viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
#ifdef Q_WS_QWS
	viewer.engine()->rootContext()->setContextProperty("main_width", QScreen::instance()->width());
	viewer.engine()->rootContext()->setContextProperty("main_height", QScreen::instance()->height());
#else
	viewer.engine()->rootContext()->setContextProperty("main_width", MAIN_WIDTH);
	viewer.engine()->rootContext()->setContextProperty("main_height", MAIN_HEIGHT);
#endif
	viewer.engine()->rootContext()->setContextProperty("input_context", new InputContextWrapper);
	viewer.setMainQmlFile(QLatin1String("gui/skins/default/main.qml"));

#ifdef Q_WS_X11
	viewer.resize(MAIN_WIDTH, MAIN_HEIGHT);
	viewer.showExpanded();
#else
	viewer.showFullScreen();
#endif

	return app.exec();
}
