#include "objectinterface.h"


int ObjectInterface::getObjectId() const
{
	return -1;
}

QString ObjectInterface::getObjectKey() const
{
	return QString();
}

QString ObjectInterface::getName() const
{
	return name;
}

void ObjectInterface::setName(const QString &n)
{
	if (n == name)
		return;

	name = n;
	emit nameChanged();
}

