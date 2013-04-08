#include "watchdog.h"
#include "bt_global_config.h"

#include <QFile>

#include <fcntl.h> // S_*


namespace
{
	void rearmWDT()
	{
		if (!QFile::exists(FILE_WDT))
		{
			int fd = creat(FILE_WDT,S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
			if (fd != -1)
			{
				close(fd);
			}
		}
	}
}


Watchdog::Watchdog(QObject *parent) : QObject(parent)
{
	connect(&timer, SIGNAL(timeout()), this, SLOT(rearm()));
}

void Watchdog::start(int interval)
{
	timer.start(interval);
}

void Watchdog::stop()
{
	timer.stop();
}

void Watchdog::rearm()
{
	rearmWDT();
}
