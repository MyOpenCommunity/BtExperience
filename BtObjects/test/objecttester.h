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

private:
	QObject *obj;
	QList<QSignalSpy *> sl;
};

#endif // OBJECTTESTER_H
