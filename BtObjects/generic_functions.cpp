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
