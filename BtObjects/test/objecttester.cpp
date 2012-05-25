#include "objecttester.h"

#include <QSignalSpy>
#include <QtTest>

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
