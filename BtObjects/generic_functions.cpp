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

#include "generic_functions.h"

#include <QProcess>
#include <QTime>

#include <QtDebug>

bool smartExecute_synch(const QString &program, QStringList args)
{
	QProcess process;
	bool ret;
#if DEBUG
	QTime t;
	t.start();
	ret = process.execute(program, args);
	qDebug() << "Executed:" << program << args.join(" ") << "in:" << t.elapsed() << "ms";

	if (!process.waitForFinished())
		return false;
#else
	ret = process.execute(program, args);
	qDebug() << "Executing:" << program << args.join(" ");

	if (!process.waitForFinished())
		return false;
#endif
	return ret;
}

bool smartExecute(const QString &program, QStringList args)
{
#if DEBUG
	QTime t;
	t.start();
	bool ret = QProcess::execute(program, args);
	qDebug() << "Executed:" << program << args.join(" ") << "in:" << t.elapsed() << "ms";
	return ret;
#else
	qDebug() << "Executing:" << program << args.join(" ");
	return QProcess::execute(program, args);
#endif
}

bool silentExecute(const QString &program, QStringList args)
{
	args << "> /dev/null" << "2>&1";
	return smartExecute(program, args);
}
