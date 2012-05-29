#include "objectlink.h"
#include "objectinterface.h"


ObjectLink::ObjectLink(ObjectInterface *obj, int _x, int _y)
{
	bt_object = obj;
	x = _x;
	y = _y;
}

QString ObjectLink::getName() const
{
	return bt_object->getName();
}

ObjectInterface *ObjectLink::getBtObject() const
{
	return bt_object;
}

QPoint ObjectLink::getPosition() const
{
	return QPoint(x, y);
}
