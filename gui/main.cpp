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
#include <QDomDocument>

#ifdef BT_MALIIT
#include <QGraphicsProxyWidget>
#include <maliit/inputmethod.h>
#endif

#include <logger.h>

#include "qmlapplicationviewer.h"
#include "eventfilters.h"
#include "globalproperties.h"
#include "guisettings.h"
#include "imagereader.h"
#include "xml_functions.h"


#define VERBOSITY_LEVEL_DEFAULT 0x1F


// Start definitions required by libcommon
logger *app_logger;
int VERBOSITY_LEVEL;

char *Prefix = const_cast<char*>("<BtExperience>");

int use_ssl = false;
char *ssl_cert_key_path = NULL;
char *ssl_certificate_path = NULL;
// End definitions required by libcommon


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


#if USE_OPENGL
void setupOpenGL(QDeclarativeView *v)
{
	QGLFormat f = QGLFormat::defaultFormat();
	f.setSampleBuffers(true);
	f.setSamples(4);

	QGLWidget *w = new QGLWidget(f);
	v->setViewport(w);
	v->setViewportUpdateMode(QGraphicsView::FullViewportUpdate);
	v->setRenderHint(QPainter::TextAntialiasing, true);
	v->setRenderHint(QPainter::SmoothPixmapTransform, true);
}
#endif


// Manage the boot (or reboot) of the gui part
class BootManager : public QObject
{
	Q_OBJECT
public:
	BootManager(GlobalProperties *g)
	{
		global = g;
		connect(global, SIGNAL(requestReboot()), SLOT(reboot()));
		boot();
	}

	~BootManager()
	{
		// We need to destroy the viewer before exit from the event loop to avoid
		// a warning message 'QGLContext::makeCurrent(): Cannot make invalid context current.'
		viewer->disconnect();
		delete viewer;
	}

	void boot()
	{
		viewer = new QmlApplicationViewer;
	#if USE_OPENGL
		setupOpenGL(viewer);
	#endif

		viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

		viewer->engine()->rootContext()->setContextProperty("global", global);
		viewer->engine()->addImportPath(global->getBasePath());
		viewer->setMainQmlFile(QLatin1String(global->getBasePath().append("main.qml").toLatin1()));
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
		if (!viewer_pos.isNull())
			viewer->move(viewer_pos);
		viewer->resize(global->getMainWidth(), global->getMainHeight());
		viewer->showExpanded();
#else
		viewer->showFullScreen();
#endif
	}

public slots:
	void reboot()
	{
#if defined(Q_WS_X11) || defined(Q_WS_MAC)
		viewer_pos = viewer->pos();
#endif
		viewer->deleteLater();
		boot();
	}

private:
	void addMaliitSurfaces(QGraphicsScene *scene, QWidget *root)
	{
		foreach (QObject *c, root->children()) {
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

	QmlApplicationViewer *viewer;
	GlobalProperties *global;
	QPoint viewer_pos;
};

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


int main(int argc, char *argv[])
{
	QApplication app(argc, argv);

	GeneralConfig general_config;
	loadGeneralConfig(general_config);
	setupLogger(general_config.log_file);
	VERBOSITY_LEVEL = general_config.verbosity_level;

	QProcessEnvironment env = QProcessEnvironment::systemEnvironment();

#if defined(BT_MALIIT)
	if (env.contains("QT_IM_MODULE"))
	{
		// In the Maliit code this is marked as a workaround for Lighthouse/QWS;
		// however when embedding Maliit into the application this is required to avoid
		// an initialization loop: creatinginput context creates the host widget, which
		// is inputmethod-enabled and tries to create the input method
		QString module = env.value("QT_IM_MODULE");

		unsetenv("QT_IM_MODULE");

		QInputContext *ic = QInputContextFactory::create(module, &app);

		if (!ic)
			qFatal("Unable to create input context for '%s'", module.toUtf8().data());

		app.setInputContext(ic);

		// see comment on InputMethodEventFilter
		app.installEventFilter(new InputMethodEventFilter);
	}
#endif


	qDebug() << "***** BtExperience start! *****";

	qmlRegisterType<ImageReader>("BtExperience", 1, 0, "ImageReader");

	LastClickTime *last_click = new LastClickTime;
	// To receive all the events, even if there is some qml elements which manage
	// their, we have to install the event filter in the QApplication
	app.installEventFilter(last_click);

	//Set user-agent of the application in order to see the Mobile version of the web sites
	app.setApplicationName(QString("Nokia"));
	app.setApplicationVersion(QString("Mobile"));

	GlobalProperties global(app_logger);
	ImageReader::setBasePath(global.getBasePath());
	QObject::connect(last_click, SIGNAL(updateTime()), &global, SLOT(updateTime()));
	QObject::connect(last_click, SIGNAL(maxTravelledDistanceOnLastMove(QPoint)), &global, SLOT(maxTravelledDistanceOnLastMove(QPoint)));
	BootManager boot_manager(&global);
	return app.exec();
}

#include "main.moc"
