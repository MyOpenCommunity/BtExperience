#ifndef XMLOBJECT_H
#define XMLOBJECT_H

#include "xml_functions.h"

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

	mutable QHash<QString, QVariant> cache;
	QDomNode obj, ist;
};

#endif // XMLOBJECT_H
