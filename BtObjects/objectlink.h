#ifndef OBJECTLINK_H
#define OBJECTLINK_H

#include "iteminterface.h"

#include <QPoint>

class ObjectInterface;


class ObjectLink : public ItemInterface
{
	Q_OBJECT
	Q_PROPERTY(ObjectInterface *btObject READ getBtObject CONSTANT)
	Q_PROPERTY(QPoint position READ getPosition NOTIFY positionChanged)

public:
	ObjectLink(ObjectInterface *obj, int _x, int _y);

	virtual QString getName() const;

	ObjectInterface *getBtObject() const;
	QPoint getPosition() const;

signals:
	void positionChanged();

private:
	ObjectInterface *bt_object;
	int x, y;
};

#endif // OBJECTLINK_H
