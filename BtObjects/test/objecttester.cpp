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

#include "objecttester.h"

#include <QSignalSpy>
#include <QtTest>
#include <QDateTime>

namespace
{
	int signalTotals(QList<QSignalSpy *> spies)
	{
		int total = 0;

		foreach(QSignalSpy *spy, spies)
			total += spy->size();

		return total;
	}
}

ObjectTester::ObjectTester(QObject *_obj, SignalList l)
{
	obj = _obj;
	foreach (const char *sig, l)
		sl << new QSignalSpy(obj, sig);
}

ObjectTester::ObjectTester(QObject *_obj, const char *sig)
{
	obj = _obj;
	sl << new QSignalSpy(obj, sig);
}

ObjectTester::~ObjectTester()
{
	foreach(QSignalSpy *spy, sl)
		delete spy;
}

bool ObjectTester::waitForSignal(int milliseconds)
{
	if (signalTotals(sl))
	{
		clearSignals();

		return true;
	}

	return waitForNewSignal(milliseconds);
}

bool ObjectTester::waitForNewSignal(int milliseconds)
{
	qint64 start = QDateTime::currentMSecsSinceEpoch();
	int total = signalTotals(sl);

	while (QDateTime::currentMSecsSinceEpoch() - start < milliseconds && signalTotals(sl) == total)
		QCoreApplication::processEvents();

	bool ok = signalTotals(sl) != total;

	clearSignals();

	return ok;
}

void ObjectTester::checkSignalCount(const char *sig, int sig_count)
{
	// look for signal
	QSignalSpy *spy;
	foreach(spy, sl)
	{
		QByteArray ba = QMetaObject::normalizedSignature(sig);
		if (ba.right(ba.size() - 1) == spy->signal())
			break;
	}

	QCOMPARE(spy->count(), sig_count);
	spy->clear();
}

void ObjectTester::checkSignals()
{
	foreach (QSignalSpy *spy, sl)
	{
		if (spy->count() != 1)
		{
			QString msg = QString("The signal %1 is emitted %2 times").arg(spy->signal().data()).arg(spy->count());
			QFAIL(qPrintable(msg));
		}
		spy->clear();
	}

}

void ObjectTester::checkNoSignals()
{
	foreach (QSignalSpy *spy, sl)
		QCOMPARE(spy->count(), 0);
}

void ObjectTester::clearSignals()
{
	foreach (QSignalSpy *spy, sl)
		spy->clear();
}
