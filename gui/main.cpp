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


#if defined(BT_MALIIT)
// QGraphicsProxyWidget::paint() uses QWidget::render() which seems to render the masked
// region of a widget at coordinates (0, 0) rather than using the original coordinates
//
// just a temporary workaround until the Maliit surfaces branch lands
class KeyboardHost : public QGraphicsProxyWidget
{
	Q_OBJECT

public:
	KeyboardHost(QWidget *keyboard)
	{
		setWidget(keyboard);

		connect(qApp->inputContext(), SIGNAL(inputMethodAreaChanged(QRect)),
			this, SLOT(setKeyboardRect(QRect)));
	}

protected:
	virtual void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
	{
		painter->translate(0, rect.top());

		QGraphicsProxyWidget::paint(painter, option, widget);
	}

private slots:
	void setKeyboardRect(QRect _rect)
	{
		rect = _rect;
	}

private:
	QRect rect;
};

#include "main.moc"
#endif

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

	QmlApplicationViewer viewer;

	qDebug() << "***** BtExperience start! *****";

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
	viewer.engine()->addImportPath(global.getBasePath());
	viewer.setMainQmlFile(QLatin1String(global.getBasePath().append("main.qml").toLatin1()));
	global.setMainWidget(&viewer);

#if defined(BT_MALIIT)
	QWidget *im_widget = Maliit::InputMethod::instance()->widget();

	if (!im_widget)
		qFatal("Maliit initialization failed");

	im_widget->resize(global.getMainWidth(), global.getMainHeight());
	im_widget->hide();

	im_widget->setParent(NULL);

	QGraphicsProxyWidget *wid = new KeyboardHost(im_widget);

	viewer.scene()->addItem(wid);

	wid->setFocusPolicy(Qt::NoFocus);
	wid->setZValue(1200);
#endif

#if defined(Q_WS_X11) || defined(Q_WS_MAC)
	viewer.resize(global.getMainWidth(), global.getMainHeight());
	viewer.showExpanded();
#else
	viewer.showFullScreen();
#endif

	return app.exec();
}
