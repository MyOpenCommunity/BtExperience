#include <QtGlobal> // Q_WS_QWS

#if defined(Q_WS_QWS)
#include <QWSServer>
#endif

#include <QApplication>
#include <QtDeclarative>

#include <logger.h>

#include "applicationcommon.h"
#include "eventfilters.h"
#include "globalproperties.h"
#include "imagereader.h"
#include "watchdog.h"
#include "browserprocess.h"

#define WATCHDOG_INTERVAL 5000


// Start definitions required by libcommon
logger *app_logger;
int VERBOSITY_LEVEL;

char *Prefix = const_cast<char*>("<BtExperience>");

int use_ssl = false;
char *ssl_cert_key_path = NULL;
char *ssl_certificate_path = NULL;
// End definitions required by libcommon


int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
	ApplicationCommon qml_application;

#ifdef Q_WS_QWS
	QWSServer::instance()->setBackground(QColor("black"));
#endif

	qml_application.initialize();

	qDebug() << "***** BtExperience start! *****";

	qmlRegisterType<ImageReader>("BtExperience", 1, 0, "ImageReader");
	qmlRegisterType<BrowserProcess>("BtExperience", 1, 0, "BrowserProcess");

	LastClickTime *last_click = new LastClickTime;
	// To receive all the events, even if there is some qml elements which manage
	// their, we have to install the event filter in the QApplication
	app.installEventFilter(last_click);

	//Set user-agent of the application in order to see the Mobile version of the web sites
	app.setApplicationName(QString("Nokia"));
	app.setApplicationVersion(QString("Mobile"));
	GlobalProperties global(app_logger);
	ImageReader::setBasePath(global.getBasePath());
	QObject::connect(last_click, SIGNAL(maxTravelledDistanceOnLastMove(QPoint)), &global, SLOT(setMaxTravelledDistanceOnLastMove(QPoint)));
	qml_application.start(&global, "main.qml", 0);

	Watchdog *watchdog = new Watchdog;
	watchdog->start(WATCHDOG_INTERVAL);

	return app.exec();
}
