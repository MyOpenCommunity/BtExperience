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
