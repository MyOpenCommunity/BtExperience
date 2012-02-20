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
	~ObjectTester();
	void checkSignalCount(const char *sig, int sig_count);

private:
	QObject *obj;
	QList<QSignalSpy *> sl;
};

#endif // OBJECTTESTER_H
