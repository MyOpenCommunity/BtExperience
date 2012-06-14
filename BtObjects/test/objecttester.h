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
