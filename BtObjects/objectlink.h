#ifndef OBJECTLINK_H
#define OBJECTLINK_H

#include "iteminterface.h"

#include <QPoint>

class ObjectInterface;


/*!
	\ingroup Core
	\brief Link to a MyHome object, for use in a room
*/
class ObjectLink : public ItemInterface
{
	Q_OBJECT

	/*!
		\brief The MyHome object instance
	*/
	Q_PROPERTY(ObjectInterface *btObject READ getBtObject CONSTANT)

	/*!
		\brief Absolute position for screen display
	*/
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
