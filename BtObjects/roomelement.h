#ifndef ROOMELEMENT_H
#define ROOMELEMENT_H

#include "objectinterface.h"

#include <QObject>
#include <QVariantList>

class RoomElement : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(ObjectInterface *btObject READ getBtObject CONSTANT)
	Q_PROPERTY(QVariantList position READ getPosition NOTIFY positionChanged)

public:
	RoomElement(ObjectInterface *obj, int _x, int _y);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdRoom;
	}

	virtual QString getObjectKey() const
	{
		return QString();
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Unassigned;
	}

	virtual QString getName() const
	{
		return btObject->getName();
	}

	ObjectInterface *getBtObject() const;
	QVariantList getPosition() const;

signals:
	void positionChanged();

private:
	ObjectInterface *btObject;
	int x, y;
};

#endif // ROOMELEMENT_H
