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

#ifndef GENERIC_FUNCTIONS_H
#define GENERIC_FUNCTIONS_H

#include <QStringList>

/*!
	\ingroup Core
	\brief A wrapper around the QProcess::execute that shows the time elapsed in DEBUG mode.
	Executes the program and then waits to it for finishing before returning.
*/
bool smartExecute_synch(const QString &program, QStringList args = QStringList());

/*!
	\ingroup Core
	\brief A wrapper around the QProcess::execute that shows the time elapsed in DEBUG mode.
*/
bool smartExecute(const QString &program, QStringList args = QStringList());

/*!
	\ingroup Core
	\brief A \em silent wrapper around the QProcess::execute.
	Shows the time elapsed in DEBUG mode and appends some extra args to the process
	in order to silent its output & error messages.
*/
bool silentExecute(const QString &program, QStringList args = QStringList());


#endif // GENERIC_FUNCTIONS_H
