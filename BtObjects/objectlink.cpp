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
