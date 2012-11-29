#include "shared_functions.h"

QTime addHours(QTime old_val, int new_hour)
{
	int diff = new_hour - old_val.hour();
	QTime t = old_val.addSecs(diff * 60 * 60);
	return t;
}

QTime addMinutes(QTime old_val, int new_minute)
{
	int diff = new_minute - old_val.minute();
	return old_val.addSecs(diff * 60);
}
