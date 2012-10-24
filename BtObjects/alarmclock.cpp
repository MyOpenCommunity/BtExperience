#include "alarmclock.h"
#include "mediamodel.h"
#include "xml_functions.h"


#include <QFile>
#include <QtDebug>


bool parseAlarmClocks(QString file_path, MediaDataModel *alarmClocks)
{
	QFile fh(file_path);
	QDomDocument document;

	if (!fh.exists() || !document.setContent(&fh))
	{
		qWarning("The settings file %s does not seem a valid xml file", qPrintable(file_path));

		return false;
	}

	return true;
}

bool saveAlarmClocks(QString file_path, MediaDataModel *alarmClocks)
{
	return true;
}

AlarmClock::AlarmClock(QObject *parent)
	: ItemInterface(parent)
{
}
