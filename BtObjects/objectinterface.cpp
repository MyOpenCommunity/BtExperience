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

#include "objectinterface.h"
#include "xml_functions.h"

#include "device.h"


void updateObjectName(QDomNode node, ObjectInterface *item)
{
	setAttribute(node, "descr", item->getName());
}


ObjectInterface::ObjectInterface(QObject *parent) : ItemInterface(parent)
{
	connect(this, SIGNAL(nameChanged()), this, SIGNAL(persistItem()));
}

int ObjectInterface::getObjectId() const
{
	return -1;
}

QString ObjectInterface::getObjectKey() const
{
	return QString();
}

QString ObjectInterface::getName() const
{
	return name;
}

void ObjectInterface::setName(const QString &n)
{
	if (n == name)
		return;

	name = n;
	emit nameChanged();
}

void ObjectInterface::setContainerUii(int uii)
{
	ItemInterface::setContainerUii(uii);

	if (uii != -1)
		enableObject();
}


DeviceObjectInterface::DeviceObjectInterface(device *_dev, QObject *parent) :
	ObjectInterface(parent)
{
	dev = _dev;

	if (dev)
		dev->setSupportedInitMode(device::DISABLED_INIT);
}

void DeviceObjectInterface::enableObject()
{
	if (!dev || dev->getSupportedInitMode() == device::NORMAL_INIT)
		return;

	dev->setSupportedInitMode(device::DEFERRED_INIT);
}

void DeviceObjectInterface::initializeObject()
{
	if (dev)
		dev->smartInit(device::DEFERRED_INIT);
}
