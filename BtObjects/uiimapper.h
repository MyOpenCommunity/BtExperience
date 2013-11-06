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
	UiiMapper() { next_uii = 1; }

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
	 * \brief Reserve a UII value for future use.
	 *
	 * This will influence the value of nextUii().
	 */
	void reserveUii(int uii);

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

	/*!
		\brief Find the uii corresponding to the given object.

		Returns \c -1 if the Object is not in the map.
	*/
	int findUii(QObject *value) const;

	int nextUii() const
	{
		return next_uii;
	}

	/*!
	 * \brief setUiiMapper
	 * Helper function to store a reference to UiiMapper that can be used
	 * to create BtObjects outside of btobjectsplugin
	 * \param map the reference to store
	 */
	static void setUiiMapper(UiiMapper *map);

	/*!
	 * \brief getUiiMapper
	 * Helper function to retrieve the UiiMapper instance
	 * \return the UiiMapper instance
	 */
	static UiiMapper *getUiiMapper();

private slots:
	void elementDestroyed(QObject *obj);

private:
	QHash<int, QObject *> items;
	int next_uii;
	static UiiMapper *uii_map;
};

#endif // UIIMAPPER_H
