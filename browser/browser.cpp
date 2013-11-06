/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

#include <QtGlobal> // Q_WS_QWS

#include <QApplication>
#include <QtDeclarative>

#include <logger.h>

#include "applicationcommon.h"
#include "browserproperties.h"
#include "imagereader.h"
#include "bt_global_config.h"
#include "networkmanager.h"
#include "medialink.h"


// Start definitions required by libcommon
logger *app_logger;
int VERBOSITY_LEVEL;

char *Prefix = const_cast<char*>("<BtBrowser>");

int use_ssl = false;
char *ssl_cert_key_path = NULL;
char *ssl_certificate_path = NULL;
// End definitions required by libcommon

QHash<GlobalField, QString> *bt_global::config;

void registerTypes(const char *uri)
{
	qmlRegisterType<ImageReader>(uri, 1, 0, "ImageReader");
	qmlRegisterUncreatableType<MediaLink>(uri, 1, 0, "MediaLink", "unable to create a MediaLink instance");
}

int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
	ApplicationCommon qml_application;

	qml_application.initialize();

	qDebug() << "***** BtBrowser start! *****";

	registerTypes("BtExperience");
	BrowserProperties global(app_logger);
	if (argc > 1)
		global.setUrlString(argv[1]);
	ImageReader::setBasePath(global.getBasePath());
	qml_application.start(&global, "browsermain.qml", new NetworkAccessManagerFactory(&global), false);

	return app.exec();
}
