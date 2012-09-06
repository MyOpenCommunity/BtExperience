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
	v->setRenderHint(QPainter::TextAntialiasing, true);
	v->setRenderHint(QPainter::SmoothPixmapTransform, true);
}
#endif


// Sets a language on the GUI; the GUI must be restarted for changes to have effect
void setLanguage(QString language)
{
	// language must be in the form it, en, ...
	static QTranslator *actual_translator = 0;
	// removes actual translation
	if (actual_translator)
	{
		QCoreApplication::instance()->removeTranslator(actual_translator);
		actual_translator = 0;
	}
	// computes new translation file name
	QFileInfo path = qApp->applicationDirPath();

#ifdef Q_WS_MAC
	path = QFileInfo(QDir(path.absoluteFilePath()), "../Resources");
#endif

	QString lf = QFileInfo(QDir(path.canonicalFilePath()),
			       QString("gui/locale/bt_experience_%1").arg(language.toAscii().constData())).absoluteFilePath();

	// tries to install new translation
	actual_translator = new QTranslator();
	if (actual_translator->load(lf))
		QCoreApplication::instance()->installTranslator(actual_translator);
	else
	{
		actual_translator = 0;
		qWarning() << "File " << lf << " not found for language " << language;
	}
}

// Sets a skin on the GUI; the GUI must be restarted for changes to have effect
void setSkin (QString skin)
{
        // computes new skin file name
        QFileInfo path = qApp->applicationDirPath();

#ifdef Q_WS_MAC
        path = QFileInfo(QDir(path.absoluteFilePath()), "../Resources");
#endif

        QString sf;
        sf = QFileInfo(QDir(path.canonicalFilePath()),
                       QString("gui/locale/%1").arg(skin.toAscii().constData())).absoluteFilePath();
}

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
		setLanguage(global->getGuiSettings()->getLanguageString());
                setSkin(global->getGuiSettings()->getSkinString());

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


int main(int argc, char *argv[])
{
	QApplication app(argc, argv);

	setupLogger("/var/tmp/BTicino.log");
	VERBOSITY_LEVEL = 3;

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

	GlobalProperties global;
	ImageReader::setBasePath(global.getBasePath());
	QObject::connect(last_click, SIGNAL(updateTime()), &global, SLOT(updateTime()));
	BootManager boot_manager(&global);
	return app.exec();
}

#include "main.moc"
