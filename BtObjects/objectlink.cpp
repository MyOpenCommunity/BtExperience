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

#include "objectlink.h"
#include "objectinterface.h"


namespace
{
	ObjectLink::MediaType getMediaTypeFromObjectInterface(ObjectInterface *obj)
	{
		int oid = obj->getObjectId();

		if (oid == ObjectInterface::IdIpRadio)
			return ObjectLink::WebRadio;

		// TODO not sure if all the following are "good" cameras, old code was this way
		if (oid == ObjectInterface::IdExternalPlace ||
			oid == ObjectInterface::IdSurveillanceCamera ||
			oid == ObjectInterface::IdInternalIntercom ||
			oid == ObjectInterface::IdExternalIntercom ||
			oid == ObjectInterface::IdSwitchboard)
			return ObjectLink::Camera;

		if (oid == ObjectInterface::IdSimpleScenario ||
			oid == ObjectInterface::IdScenarioModule ||
			oid == ObjectInterface::IdScenarioPlus ||
			oid == ObjectInterface::IdAdvancedScenario ||
			oid == ObjectInterface::IdScheduledScenario)
			return ObjectLink::Scenario;

		return ObjectLink::BtObject;
	}
}

ObjectLink::ObjectLink(ObjectInterface *obj, int x, int y, int container_uii) :
		LinkInterface(container_uii, getMediaTypeFromObjectInterface(obj), QPoint(x, y))
{
	bt_object = obj;
	obj->enableObject();

	connect(bt_object, SIGNAL(nameChanged()), this, SLOT(objectNameChanged()));
	connect(this, SIGNAL(positionChanged(QPointF)), this, SIGNAL(persistItem()));
}

QString ObjectLink::getName() const
{
	return bt_object->getName();
}

void ObjectLink::setName(QString new_value)
{
	bt_object->setName(new_value);
}

ObjectInterface *ObjectLink::getBtObject() const
{
	bt_object->initializeObject();

	return bt_object;
}

void ObjectLink::objectNameChanged()
{
	emit nameChanged(getName());
}
