#include "objectlink.h"
#include "objectinterface.h"


ObjectLink::ObjectLink(ObjectInterface *obj, MediaType type, int x, int y) :
	LinkInterface(-1, type, QPoint(x, y))
{
	bt_object = obj;

	connect(bt_object, SIGNAL(nameChanged()), this, SLOT(objectNameChanged()));
	connect(this, SIGNAL(positionChanged(QPointF)), this, SIGNAL(persistItem()));
}

QString ObjectLink::getName() const
{
	return bt_object->getName();
}

ObjectInterface *ObjectLink::getBtObject() const
{
	return bt_object;
}

void ObjectLink::objectNameChanged()
{
	emit nameChanged(getName());
}
