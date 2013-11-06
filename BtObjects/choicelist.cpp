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

#include "choicelist.h"

#include <QDebug>


void ChoiceList::add(int value)
{
	values.append(value);
	if (choice < 0)
		choice = 0;
}

int ChoiceList::value() const
{
	return values.at(choice);
}

int ChoiceList::value(int def) const
{
	return choice == -1 ? def : value();
}

void ChoiceList::next()
{
	if (++choice >= values.size())
		choice = 0;
}

void ChoiceList::previous()
{
	if (--choice < 0)
		choice = values.size() - 1;
}

QVariantList ChoiceList::getValues() const
{
	QVariantList result;
	foreach (int choice, values) {
		result.append(choice);
	}
	return result;
}

int ChoiceList::size() const
{
	return values.size();
}
