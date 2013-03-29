#include "applicationcommon.h"

#include <QtGlobal> // Q_WS_QWS

#if defined(Q_WS_QWS) && !defined(__arm__)
// assume that QWS on PC is using QVFb and does not support OpenGL
#define USE_OPENGL 0
#else
#define USE_OPENGL 1
#endif

#if defined(Q_WS_QWS)
#include <QScreen>
#include <QWSServer>
#endif

#include <QtGui/QApplication>
#if USE_OPENGL
#include <QtOpenGL/QGLWidget>
#endif
#include <QDeclarativeContext>
#include <QtDeclarative>

#ifdef BT_MALIIT
#include <QGraphicsProxyWidget>
#include <maliit/inputmethod.h>
#endif

#include <logger.h>

#include "qmlapplicationviewer.h"
#include "eventfilters.h"
#include "globalpropertiescommon.h"
#include "xml_functions.h"
#include "signalshandler.h"

#define VERBOSITY_LEVEL_DEFAULT 0x1F


#if USE_OPENGL
void setupOpenGL(QDeclarativeView *v)
{
	QGLFormat f = QGLFormat::defaultFormat();
	f.setSampleBuffers(false);

	QGLWidget *w = new QGLWidget(f);
	v->setViewport(w);
	v->setViewportUpdateMode(QGraphicsView::FullViewportUpdate);
	v->setRenderHint(QPainter::TextAntialiasing, true);
	v->setRenderHint(QPainter::SmoothPixmapTransform, true);

	v->setAttribute(Qt::WA_OpaquePaintEvent);
	v->setAttribute(Qt::WA_NoSystemBackground);
	v->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
	v->viewport()->setAttribute(Qt::WA_NoSystemBackground);
}
#endif


// The struct that contains the general configuration values
struct GeneralConfig
{
	int verbosity_level; // the verbosity used to print in the log file
	QString log_file;    // the log file in stack_open.xml
	// TODO: other fields (reconnection time, log file)
};


void messageHandler(QtMsgType type, const char *msg)
{
	switch (type)
	{
	case QtDebugMsg:
		app_logger->debug(LOG_NOTICE, (char *) msg);
		break;

	case QtWarningMsg:
		app_logger->debug(LOG_INFO | LOG_NOTICE, (char *) msg);
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


static void loadGeneralConfig(GeneralConfig &general_config)
{
#define MY_FILE_CFG_DEFAULT "cfg/stack_open.xml"
#define MY_FILE_LOG_DEFAULT "/var/tmp/BTicino.log"

	general_config.verbosity_level = VERBOSITY_LEVEL_DEFAULT;
	general_config.log_file = MY_FILE_LOG_DEFAULT;

	if (QFile::exists(MY_FILE_CFG_DEFAULT))
	{
		QFile fh(MY_FILE_CFG_DEFAULT);
		QDomDocument qdom_config;
		if (qdom_config.setContent(&fh))
		{
			QDomNode el = getElement(qdom_config, "root/sw");
			if (!el.isNull())
			{
				QDomElement v = getElement(el, "BtExperience/logverbosity");
				if (!v.isNull())
					general_config.verbosity_level = v.text().toInt(0, 16);

				QDomElement l = getElement(el, "logfile");
				if (!l.isNull())
					general_config.log_file = l.text();
			}
		}
	}
}


ApplicationCommon::ApplicationCommon()
{
	SignalsHandler *sh = installSignalsHandler();

	connect(sh, SIGNAL(signalReceived(int)), this, SLOT(handleSignal(int)));
}

ApplicationCommon::~ApplicationCommon()
{
	// We need to destroy the viewer before exit from the event loop to avoid
	// a warning message 'QGLContext::makeCurrent(): Cannot make invalid context current.'
	viewer->disconnect();
	delete viewer;
}

void ApplicationCommon::initialize()
{
	GeneralConfig general_config;
	loadGeneralConfig(general_config);
	setupLogger(general_config.log_file);
	VERBOSITY_LEVEL = general_config.verbosity_level;
	// the default value for startDragDistance is 4 pixel; we resistive
	// touches this is too low, when a user tries to click a minimal noise
	// "transforms" the click in flick. To avoid such spurious flicks we
	// set the value to 35, this gives us a better signal/noise ratio.
	qApp->setStartDragDistance(35);

#if defined(BT_MALIIT)
	QProcessEnvironment env = QProcessEnvironment::systemEnvironment();

	if (env.contains("QT_IM_MODULE"))
	{
		// In the Maliit code this is marked as a workaround for Lighthouse/QWS;
		// however when embedding Maliit into the application this is required to avoid
		// an initialization loop: creatinginput context creates the host widget, which
		// is inputmethod-enabled and tries to create the input method
		QString module = env.value("QT_IM_MODULE");

		QInputContext *ic = QInputContextFactory::create(module, qApp);

		if (!ic)
			qFatal("Unable to create input context for '%s'", module.toUtf8().data());

		qApp->setInputContext(ic);

		// see comment on InputMethodEventFilter
		qApp->installEventFilter(new InputMethodEventFilter);
	}
#endif
}

void ApplicationCommon::start(GlobalPropertiesCommon *g, QString qml_file, QDeclarativeNetworkAccessManagerFactory *f, bool visible)
{
	global = g;
	viewer = new QmlApplicationViewer;
#if USE_OPENGL
	setupOpenGL(viewer);
#endif

	viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

	viewer->engine()->rootContext()->setContextProperty("global", global);
	viewer->engine()->addImportPath(global->getBasePath());
	viewer->engine()->setNetworkAccessManagerFactory(f);
	viewer->setMainQmlFile(QLatin1String(global->getBasePath().append(qml_file).toLatin1()));
	global->setMainWidget(viewer);

#if defined(BT_MALIIT)
	if (!Maliit::InputMethod::instance()->widget())
		qFatal("Maliit initialization failed");

	addMaliitSurfaces(viewer->scene(), Maliit::InputMethod::instance()->widget());
#if !USE_OPENGL
	viewer->setViewportUpdateMode(QGraphicsView::FullViewportUpdate);
#endif
#endif

#if defined(Q_WS_X11) || defined(Q_WS_MAC)
	viewer->resize(global->getMainWidth(), global->getMainHeight());
	if (visible)
		viewer->showExpanded();
#else
	viewer->setWindowFlags(Qt::FramelessWindowHint);
	if (visible)
		viewer->showFullScreen();
#endif
}

void ApplicationCommon::handleSignal(int signal_number)
{
	if (signal_number == SIGUSR2)
	{
		qDebug("Received signal SIGUSR2");
//		emit systemTimeChanged();
	}
	else if (signal_number == SIGTERM)
	{
		qDebug("Terminating on SIGTERM");
		qApp->quit();
	}
}

void ApplicationCommon::addMaliitSurfaces(QGraphicsScene *scene, QWidget *root)
{
	foreach (QObject *c, root->children())
	{
		QGraphicsView *view = qobject_cast<QGraphicsView *>(c);
		if (!view)
			continue;

		view->setParent(0);

		QGraphicsProxyWidget *wid = new QGraphicsProxyWidget;

		wid->setWidget(view);
		wid->setFocusPolicy(Qt::NoFocus);

		scene->addItem(wid);

		addMaliitSurfaces(scene, view);
	}
}
