/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef XMLOBJECT_H
#define XMLOBJECT_H

#include "xml_functions.h"

#include <QHash>
#include <QVariant>


/*!
	\ingroup Core
	\brief Helper class for configuration parsing

	\verbatim
	QList<ObjectPair> parseThing(const QDomNode &obj)
	{
		XmlObject v(obj);

		foreach (const QDomNode &ist, getChildren(obj, "ist"))
		{
			v.setIst(ist);
			QString where = v.value("where");
			Thing::Type type = v.intValue<Thing::Type>("type");
			int count = v.intValue("count");

			// ...
		}
		// ...
	}
	\endverbatim
*/
class XmlObject
{
public:
	XmlObject(const QDomNode &_obj)
	{
		obj = _obj;
	}

	void setIst(const QDomNode &_ist)
	{
		ist = _ist;
	}

	QString value(const QString &name) const
	{
		return getAttribute(ist, name, objValue(name).toString());
	}

	int intValue(const QString &name) const
	{
		return getIntAttribute(ist, name, objIntValue(name).toInt());
	}

	double doubleValue(const QString &name) const
	{
		return getDoubleAttribute(ist, name, objDoubleValue(name).toDouble());
	}

	QTime timeValue(const QString &name) const
	{
		return getTimeAttribute(ist, name, objTimeValue(name).toTime());
	}

	template<class T>
	T intValue(const QString &name) const
	{
		return static_cast<T>(intValue(name));
	}

private:
	QVariant objValue(const QString &name) const
	{
		if (cache.contains(name))
			return cache.value(name);

		return cache[name] = getAttribute(obj, name);
	}

	QVariant objIntValue(const QString &name) const
	{
		if (cache.contains(name))
			return cache.value(name);

		return cache[name] = getIntAttribute(obj, name);
	}

	QVariant objDoubleValue(const QString &name) const
	{
		if (cache.contains(name))
			return cache.value(name);

		return cache[name] = getDoubleAttribute(obj, name);
	}

	QVariant objTimeValue(const QString &name) const
	{
		if (cache.contains(name))
			return cache.value(name);

		return cache[name] = getTimeAttribute(obj, name);
	}

	mutable QHash<QString, QVariant> cache;
	QDomNode obj, ist;
};

#endif // XMLOBJECT_H
