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
#include "eventfilters.h"
#include "globalproperties.h"


// Start definitions required by libcommon
logger *app_logger;
int VERBOSITY_LEVEL;

char *Prefix = const_cast<char*>("<BtExperience>");

int use_ssl = false;
char *ssl_cert_key_path = NULL;
char *ssl_certificate_path = NULL;
// End definitions required by libcommon


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


#if USE_OPENGL
void setupOpenGL(QDeclarativeView *v)
{
	QGLFormat f = QGLFormat::defaultFormat();
	f.setSampleBuffers(true);
	f.setSamples(4);

	QGLWidget *w = new QGLWidget(f);
	v->setViewport(w);
	v->setViewportUpdateMode(QGraphicsView::FullViewportUpdate);
	v->setRenderHint(QPainter::Antialiasing, true);
	v->setRenderHint(QPainter::SmoothPixmapTransform, true);
	v->setRenderHint(QPainter::HighQualityAntialiasing, true);
	v->setRenderHint(QPainter::TextAntialiasing, true);
}
#endif

// TODO Copied&pasted from ts_3_5.x11, must be readapted.
// The template path to find the language file.
#define LANGUAGE_FILE_TMPL "%s/gui/linguist-ts/bt_experience_%s"

void installTranslator(QApplication &a, QString language_suffix)
{
	QString language_file;
	language_file.sprintf(LANGUAGE_FILE_TMPL,
						  QDir::currentPath().toAscii().constData(),
						  language_suffix.toAscii().constData());
	QTranslator *translator = new QTranslator();
	if (translator->load(language_file))
	{
		a.installTranslator(translator);
	}
	else
		qWarning() << "File " << language_file << " not found for language " << language_suffix;
}

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);

	// TODO pass gui language; I hardcoded Italian for now
	// pay attention to the fact that the translator MUST be installed before doing anything else
	installTranslator(app, "it");

	setupLogger("/var/tmp/BTicino.log");
	VERBOSITY_LEVEL = 3;


	QmlApplicationViewer viewer;
	qDebug() << "***** BtExperience start! *****";

	QProcessEnvironment env = QProcessEnvironment::systemEnvironment();

	if (env.contains("QT_IM_MODULE"))
	{
#if (defined(Q_WS_QPA) || defined(Q_WS_QWS)) && (QT_VERSION < 0x050000)
		// Workaround for Lighthouse/QWS, copied from Maliit PlainQT example app
		QInputContext *ic = QInputContextFactory::create(env.value("QT_IM_MODULE"), &app);

		if (!ic)
			qFatal("Unable to create input context for '%s'", env.value("QT_IM_MODULE").toUtf8().data());

		app.setInputContext(ic);
#endif

		// see comment on InputMethodEventFilter
		app.installEventFilter(new InputMethodEventFilter);
	}

	LastClickTime *last_click = new LastClickTime;
	// To receive all the events, even if there is some qml elements which manage
	// their, we have to install the event filter in the QApplication
	app.installEventFilter(last_click);

#if USE_OPENGL
	setupOpenGL(&viewer);
#endif

	viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

	GlobalProperties global;
	QObject::connect(last_click, SIGNAL(updateTime()), &global, SLOT(updateTime()));
	viewer.engine()->rootContext()->setContextProperty("global", &global);
	viewer.setMainQmlFile(QLatin1String("gui/skins/default/main.qml"));
	global.setMainWidget(&viewer);

#ifdef Q_WS_X11
	viewer.resize(global.getMainWidth(), global.getMainHeight());
	viewer.showExpanded();
#else
	viewer.showFullScreen();
#endif

	return app.exec();
}
