#include "objecttester.h"

#include <QSignalSpy>
#include <QtTest>

ObjectTester::ObjectTester(QObject *_obj, SignalList l)
{
	obj = _obj;
	foreach (const char *sig, l)
		sl << new QSignalSpy(obj, sig);
}

ObjectTester::~ObjectTester()
{
	foreach(QSignalSpy *spy, sl)
		delete spy;
}

void ObjectTester::checkSignalCount(const char *sig, int sig_count)
{
	// look for signal
	QSignalSpy *spy;
	foreach(spy, sl)
	{
		if (QMetaObject::normalizedSignature(sig) == spy->signal())
			break;
	}

	QCOMPARE(spy->count(), sig_count);
}

void ObjectTester::checkSignals()
{
	foreach (const QSignalSpy *spy, sl)
		QCOMPARE(spy->count(), 1);
}


