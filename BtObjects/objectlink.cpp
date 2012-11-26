#include "objectlink.h"
#include "objectinterface.h"


namespace
{
	ObjectLink::MediaType getMediaTypeFromObjectInterface(ObjectInterface *obj)
	{
		int oid = obj->getObjectId();

		if (oid == ObjectInterface::IdIpRadio)
			return ObjectLink::WebRadio;

		return ObjectLink::Camera;
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

ObjectInterface *ObjectLink::getBtObject() const
{
	bt_object->initializeObject();

	return bt_object;
}

void ObjectLink::objectNameChanged()
{
	emit nameChanged(getName());
}
