#ifndef ROOMELEMENT_H
#define ROOMELEMENT_H

#include "objectinterface.h"

#include <QObject>
#include <QPoint>

class RoomElement : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(ObjectInterface *btObject READ getBtObject CONSTANT)
	Q_PROPERTY(QPoint position READ getPosition NOTIFY positionChanged)

public:
	RoomElement(QString _room_name, ObjectInterface *obj, int _x, int _y);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdRoom;
	}

	virtual QString getObjectKey() const
	{
		return room_name;
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Unassigned;
	}

	virtual QString getName() const
	{
		return bt_object->getName();
	}

	ObjectInterface *getBtObject() const;
	QPoint getPosition() const;

signals:
	void positionChanged();

private:
	QString room_name;
	ObjectInterface *bt_object;
	int x, y;
};

#endif // ROOMELEMENT_H
