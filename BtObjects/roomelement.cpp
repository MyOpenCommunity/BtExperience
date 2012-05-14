#include "roomelement.h"
#include "objectinterface.h"

RoomElement::RoomElement(QString _room_name, ObjectInterface *obj, int _x, int _y)
{
	room_name = _room_name;
	bt_object = obj;
	x = _x;
	y = _y;
}

ObjectInterface *RoomElement::getBtObject() const
{
	return bt_object;
}

QPoint RoomElement::getPosition() const
{
	return QPoint(x, y);
}
