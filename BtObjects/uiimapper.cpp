#include "uiimapper.h"


void UiiMapper::insert(int uii, QObject *value)
{
	connect(value, SIGNAL(destroyed(QObject*)),
		this, SLOT(elementDestroyed(QObject*)));

	items.insert(uii, value);
}

void UiiMapper::remove(QObject *value)
{
	QMutableHashIterator<int, QObject *> iter(items);
	while (iter.hasNext())
	{
		iter.next();
		if (iter.value() == value)
		{
			iter.remove();
			// we are removing only one item
			break;
		}
	}
}

void UiiMapper::elementDestroyed(QObject *obj)
{
	remove(obj);
}
