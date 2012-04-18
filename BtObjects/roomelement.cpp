#include "roomelement.h"
#include "objectinterface.h"

RoomElement::RoomElement(ObjectInterface *obj, int _x, int _y)
{
	btObject = obj;
	x = _x;
	y = _y;
}

ObjectInterface *RoomElement::getBtObject() const
{
	return btObject;
}

QVariantList RoomElement::getPosition() const
{
	QVariantList vl;
	vl << x << y;
	return vl;
}
