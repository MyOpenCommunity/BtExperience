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

#include "shared_functions.h"

QTime addHours(QTime old_val, int new_hour)
{
	int diff = new_hour - old_val.hour();
	QTime t = old_val.addSecs(diff * 60 * 60);
	return t;
}

QTime addMinutes(QTime old_val, int new_minute)
{
	int diff = new_minute - old_val.minute();
	return old_val.addSecs(diff * 60);
}
