#ifndef DANGERS_H
#define DANGERS_H

#include "objectinterface.h"

#include <QObject>


/*!
	\brief Collects and notifies data about stop&go devices

	This class collects data about stop&go devices like number of device that
	are in ok state or in ko state. This information will be used to notify
	the GUI when an alarm triggers or when a device returns to normal state of
	operation.

	The object id is \a ObjectInterface::IdDangers.
*/
class Dangers : public ObjectInterface
{
	Q_OBJECT

public:
	Dangers();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdDangers;
	}

signals:

protected slots:

};

#endif // DANGERS_H
