#ifndef ALARMCLOCK_H
#define ALARMCLOCK_H


#include "iteminterface.h"


class MediaDataModel;


bool parseAlarmClocks(QString file_path, MediaDataModel *alarmClocks);
bool saveAlarmClocks(QString file_path, MediaDataModel *alarmClocks);


/*!
	\brief An alarm clock setting
*/
class AlarmClock : public ItemInterface
{
	Q_OBJECT

public:
	AlarmClock(QObject *parent = 0);

};

#endif // ALARMCLOCK_H
