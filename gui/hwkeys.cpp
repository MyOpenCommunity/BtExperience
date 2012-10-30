#include "hwkeys.h"

#include <QSocketNotifier>

#include <fcntl.h>
#include <linux/input.h>

#define EVENT_PATH "/dev/input/event0"

#define EV_PRESSED 1
#define EV_RELEASED 0

#define KEY_COUNT 4

namespace
{
	const int key_map[KEY_COUNT] = {KEY_1, KEY_2, KEY_3, KEY_4};
}


HwKeys::HwKeys(QObject *parent) : QObject(parent)
{
#if defined(BT_HARDWARE_X11)
	handle = 0;
#else
	handle = open(EVENT_PATH, O_RDONLY | O_SYNC);
	if (handle < 0)
		qFatal("Unable to open %s for reading", EVENT_PATH);

	QSocketNotifier *n = new QSocketNotifier(handle, QSocketNotifier::Read, this);

	connect(n, SIGNAL(activated(int)), this, SLOT(handleKeyEvent()));
#endif
}

HwKeys::~HwKeys()
{
	if (handle >= 0)
		close(handle);
}

void HwKeys::handleKeyEvent()
{
	struct input_event ev;
	int ret = read(handle, &ev, sizeof(ev));

	if (ret == -1)
		return;

	if (ev.type != EV_KEY || (ev.value != EV_RELEASED && ev.value != EV_PRESSED))
		return;

	int index = -1;
	for (int i = 0; i < KEY_COUNT; ++i)
	{
		if (key_map[i] == ev.code)
		{
			index = i;
			break;
		}
	}

	if (index == -1)
		return;

	qDebug("Hardware key %d %s", index, ev.value == EV_PRESSED ? "pressed" : "released");

	if (ev.value == EV_PRESSED)
		emit pressed(index);
	else
		emit released(index);
}
