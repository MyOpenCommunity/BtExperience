#include "qmlcache.h"

#include <QDebug>


QMLCache::QMLCache(QObject *parent)
	: QObject(parent)
{
}

QVariant QMLCache::getQMLValue(int key)
{
	// if an original value has not been stored then no QML value is possible
	if (!keys.contains(key))
		return QVariant();

	return values[key];
}

bool QMLCache::setQMLValue(int key, QVariant value)
{
	// if an original value has not been stored then no QML value is possible
	if (!keys.contains(key))
		return false;

	if (values[key] != value)
	{
		values[key] = value;
		emit qmlValueChanged(key, value);
	}

	return true;
}

void QMLCache::setOriginalValue(int key, QVariant original_value)
{
	if (!keys.contains(key))
		keys.insert(key);

	values[key] = original_values[key] = original_value;
}

void QMLCache::reset()
{
	QSet<int> changed_keys;

	// stores what values changed since last apply
	QHashIterator<int, QVariant> it(original_values);
	while (it.hasNext())
	{
		it.next();
		int k = it.key();
		if (original_values[k] != values[k])
			changed_keys.insert(k);
	}

	// resets QML cache
	values = original_values;

	// emits changed signals
	QSetIterator<int> its(changed_keys);
	while (its.hasNext())
	{
		int k = its.next();
		emit qmlValueChanged(k, values[k]);
	}
}

void QMLCache::apply()
{
	QSet<int> changed_keys;

	// stores what values changed since last apply
	QHashIterator<int, QVariant> it(original_values);
	while (it.hasNext())
	{
		it.next();
		int k = it.key();
		if (original_values[k] != values[k])
			changed_keys.insert(k);
	}

	// applies new values
	original_values = values;

	// emits changed signals
	QSetIterator<int> its(changed_keys);
	while (its.hasNext())
	{
		int k = its.next();
		emit qmlValueChanged(k, values[k]);
	}

	// emits persist request
	emit persistItemRequested();
}
