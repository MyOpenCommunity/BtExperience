#include "uiimapper.h"

#include <QDebug>

void UiiMapper::insert(int uii, QObject *value)
{
	if (items.contains(uii))
		qFatal("Duplicate uii %d", uii);

	connect(value, SIGNAL(destroyed(QObject*)),
		this, SLOT(elementDestroyed(QObject*)));

	if (uii >= next_uii)
		next_uii = uii + 1;

	items.insert(uii, value);
}

void UiiMapper::remove(QObject *value)
{
	int uii = findUii(value);
	if (uii == -1)
	{
		qWarning() << "Try to remove an object not in the list:" << value;
		return;
	}

	items.remove(uii);
}

int UiiMapper::findUii(QObject *value) const
{
	QHashIterator<int, QObject *> iter(items);
	while (iter.hasNext())
	{
		iter.next();
		if (iter.value() == value)
			return iter.key();
	}
	return -1;
}

void UiiMapper::elementDestroyed(QObject *obj)
{
	remove(obj);
}
