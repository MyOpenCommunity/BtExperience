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

#ifndef CHOICELIST_H
#define CHOICELIST_H

#include <QObject>
#include <QList>
#include <QVariantList>


/*!
	\ingroup Core
	\brief Manage a list of possible choices

	In some cases, not all possible values are available to the user, but only
	some of them.
	For example, all fancoil speeds are: auto, min, med, max, silent.
	A specific fancoil may be configured to have only auto, max, silent.
	This class is used to manage only those and not all the possible values.
	The class manages int values because it expects that such values are enums.
*/
class ChoiceList : public QObject
{
	Q_OBJECT

	/*!
		\brief Gets the modes list
	*/
	Q_PROPERTY(QVariantList values READ getValues CONSTANT)

public:
	ChoiceList(QObject *parent = 0) : QObject(parent), choice(-1) {}

	/*!
		\brief Add a new enumeration value to the end of the list.
	*/
	void add(int value);
	int value() const;
	int value(int def) const;
	void next();
	void previous();
	QVariantList getValues() const;
	int size() const;

private:
	QList<int> values;
	int choice;
};


#endif // CHOICELIST_H
