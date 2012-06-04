#ifndef UIIMAPPER_H
#define UIIMAPPER_H

#include <QObject>
#include <QHash>


/*!
	\ingroup Core
	\brief Maps Uii with the corresponding object
*/
class UiiMapper : public QObject
{
	Q_OBJECT

public:
	/*!
		\brief Add a new mapping, calls qFatal() if it's a duplicate
	*/
	void insert(int uii, QObject *value);

	/*!
		\brief Remove an object from the mapping

		Mappings are automatically removed when the object is destroyed (using
		the \c destroyed() signal).
	*/
	void remove(QObject *value);

	/*!
		\brief Look up an object with type V in the map

		Look up the object in the map and convert it using \c qbject_cast, returns
		the object pointer on success, \c 0 if the object is not contained in the map
		or is not the correct type.
	*/
	template<class V>
	V *value(int uii) const
	{
		return qobject_cast<V *>(value(uii));
	}

	/*!
		\brief Look up an object in the map

		Returns \c 0 if the Uii is not in the map.
	*/
	QObject *value(int uii) const
	{
		return items.value(uii);
	}

private slots:
	void elementDestroyed(QObject *obj);

private:
	QHash<int, QObject *> items;
};

#endif // UIIMAPPER_H
