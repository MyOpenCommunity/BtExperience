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

#ifndef OBJECTTESTER_H
#define OBJECTTESTER_H

#include <QList>

class QObject;
class QSignalSpy;

typedef QList<const char *> SignalList;

class ObjectTester
{
public:
	ObjectTester(QObject *_obj, SignalList l);
	/**
	 * Convenience ctor for only one signal.
	 */
	ObjectTester(QObject *_obj, const char *sig);
	~ObjectTester();
	void checkSignalCount(const char *sig, int sig_count);

	/**
	 * Checks that all signals defined in ctor are emitted once.
	 */
	void checkSignals();

	/**
	 * Checks that none of the signals defined in ctor are emitted.
	 */
	void checkNoSignals();

	/**
	 * Clear signal state
	 */
	void clearSignals();

	/**
	 * Wait until a signal is available or timeout expires (calls processEvents())
	 * returns \a false if timeout expires, \a true if a signal is available.
	 *
	 * Note that if a signal has already been received, the function returns immediatly.
	 */
	bool waitForSignal(int milliseconds);

	/**
	 * Wait until a new signal is received or timeout expires (calls processEvents())
	 * returns \a false if timeout expires, \a true if a signal is received.
	 */
	bool waitForNewSignal(int milliseconds);

private:
	QObject *obj;
	QList<QSignalSpy *> sl;
};

#endif // OBJECTTESTER_H
