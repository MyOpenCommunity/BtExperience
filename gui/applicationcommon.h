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

#ifndef APPLICATIONCOMMON_H
#define APPLICATIONCOMMON_H

#include <QObject>

class GlobalPropertiesCommon;
class QmlApplicationViewer;
class QGraphicsScene;
class QDeclarativeNetworkAccessManagerFactory;


// Manage the boot (or reboot) of the gui part
class ApplicationCommon : public QObject
{
	Q_OBJECT

public:
	ApplicationCommon();
	~ApplicationCommon();

	void initialize();
	void start(GlobalPropertiesCommon *g, QString qml_file, QDeclarativeNetworkAccessManagerFactory *f, bool visible = true);

public slots:
	void handleSignal(int signal_number);

private:
	void addMaliitSurfaces(QGraphicsScene *scene, QWidget *root);

	QmlApplicationViewer *viewer;
	GlobalPropertiesCommon *global;
};

#endif // APPLICATIONCOMMON_H
