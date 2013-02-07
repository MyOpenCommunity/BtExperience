#include <QtGlobal> // Q_WS_QWS

#include <QApplication>
#include <QtDeclarative>

#include <logger.h>

#include "applicationcommon.h"
#include "browserproperties.h"
#include "imagereader.h"
#include "main.h"
#include "networkmanager.h"


// Start definitions required by libcommon
logger *app_logger;
int VERBOSITY_LEVEL;

char *Prefix = const_cast<char*>("<BtBrowser>");

int use_ssl = false;
char *ssl_cert_key_path = NULL;
char *ssl_certificate_path = NULL;
// End definitions required by libcommon

QHash<GlobalField, QString> *bt_global::config;

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
	ApplicationCommon qml_application;

	qml_application.initialize();

	qDebug() << "***** BtBrowser start! *****";

	qmlRegisterType<ImageReader>("BtExperience", 1, 0, "ImageReader");

	BrowserProperties global(app_logger);
	if (argc > 1)
		global.setUrlString(argv[1]);
	ImageReader::setBasePath(global.getBasePath());
	qml_application.start(&global, "browsermain.qml", new NetworkAccessManagerFactory(&global), false);

	return app.exec();
}
