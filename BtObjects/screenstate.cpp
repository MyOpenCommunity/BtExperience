#include "screenstate.h"
#include "generic_functions.h"

#include <QMouseEvent>
#include <QTimer>
#include <QCoreApplication>

#include <QDebug>

#define FREEZE_INTERVAL 200
#define SCREENSAVER_TIME 50
#define FREEZE_TIME      10

namespace
{
	const char *descriptions[ScreenState::StateCount + 1] =
	{
		"Invalid",
		"ScreenOff",
		"Screensaver",
		"Normal",
		"Freeze",
		"ForcedNormal",
		"PasswordCheck",
		"Calibration",
	};

	// TODO move this to gui module
	void setBrightness(int value)
	{
		qDebug() << "Setting brightness to" <<  value;
	#if !defined(BT_HARDWARE_X11)
		smartExecute("i2cset", QStringList() << "-y" << "2" << "0x38" << "0x04" << "0x" + QString::number(value, 16));
	#endif
	}

	void setMonitorEnabled(int value)
	{
		qDebug() << "Writing" <<  value << "to /sys/devices/platform/omapdss/display0/enabled";

	#if !defined(BT_HARDWARE_X11)
		QFile display_device("/sys/devices/platform/omapdss/display0/enabled");

		display_device.open(QFile::WriteOnly);
		display_device.write(qPrintable(QString::number(value)));
		display_device.close();
	#endif
	}
}


ScreenState::ScreenState(QObject *parent) : QObject(parent)
{
	current_state = Invalid;
	normal_brightness = 100;
	for (int i = 0; i < StateCount; ++i)
		states[i] = false;

	screensaver_timer = new QTimer();
	screensaver_timer->setSingleShot(true);
	screensaver_timer->setInterval(SCREENSAVER_TIME * 1000);
	connect(screensaver_timer, SIGNAL(timeout()), this, SLOT(startFreeze()));

	freeze_tick = 0;
	freeze_timer = new QTimer();
	freeze_timer->setInterval(FREEZE_INTERVAL);
	connect(freeze_timer, SIGNAL(timeout()), this, SLOT(freezeTick()));

	qApp->installEventFilter(this);
}

ScreenState::~ScreenState()
{
	qApp->removeEventFilter(this);
}

ScreenState::State ScreenState::getState() const
{
	return current_state;
}

void ScreenState::disableState(State state)
{
	states[state] = false;

	if (state == current_state)
		updateState();
}

void ScreenState::enableState(State state)
{
	states[state] = true;

	if (state > current_state)
		updateState();
	if (state != Freeze)
		disableState(Freeze);
}

void ScreenState::updateState()
{
	State new_state = Invalid;
	int i;

	for (i = StateCount - 1; i >= 0; --i)
	{
		if (states[i])
		{
			new_state = static_cast<State>(i);
			break;
		}
	}

	Q_ASSERT_X(i >= 0, "ScreenState::updateState", "Normal state not set in screen state machine");

	if (new_state == current_state)
		return;

	updateScreenState(current_state, new_state);
}

void ScreenState::updateScreenState(State old_state, State new_state)
{
	qDebug() << "Leaving state" << descriptions[old_state + 1];

	switch (old_state)
	{
	case Freeze:
		freeze_timer->stop();
		break;
	case ScreenOff:
		setMonitorEnabled(true);
		break;
	default:
		qWarning("Add code to leave old state");
		break;
	case Invalid:
		setMonitorEnabled(true);
		break;
	}

	qDebug() << "Entering state" << descriptions[new_state + 1];

	switch (new_state)
	{
	case Freeze:
		freeze_tick = 0;
		freeze_timer->start();
		break;
	case ScreenOff:
		setMonitorEnabled(false);
		break;
	case Normal:
	case ForcedNormal:
	case PasswordCheck:
	case Calibration:
		setBrightness(normal_brightness);
		break;
	default:
		qWarning("Add code to enter new state");
		break;
	case Invalid:
		Q_ASSERT_X(false, "ScreenState::updateScreenState", "Entering invalid screen state");
		break;
	}

	current_state = new_state;

	// manage screensaver timer
	if (current_state == Normal || current_state == PasswordCheck)
	{
		if (!screensaver_timer->isActive())
			screensaver_timer->start();
	}
	else
		screensaver_timer->stop();;

	emit stateChanged(old_state, new_state);
}

void ScreenState::startFreeze()
{
	enableState(Freeze);
}

void ScreenState::freezeTick()
{
	const int max_ticks = FREEZE_TIME * 1000 / FREEZE_INTERVAL;

	++freeze_tick;
	if (freeze_tick >= max_ticks)
	{
		// TODO screensaver
		disableState(Normal);
		disableState(Freeze);
		disableState(PasswordCheck);
	}
	else
		setBrightness(normal_brightness - normal_brightness * freeze_tick / max_ticks);
}

bool ScreenState::updatePressTime()
{
	switch (current_state)
	{
	case Normal:
		screensaver_timer->start();
		return false;
	case ForcedNormal:
	case PasswordCheck:
	case Calibration:
		return false;
	case Freeze:
		disableState(Freeze);
		return true;
	case Screensaver:
	case ScreenOff:
		// TODO password check
		enableState(Normal);
		disableState(Screensaver);
		return true;
	default:
		return false;
	}
}

bool ScreenState::eventFilter(QObject *obj, QEvent *ev)
{
	Q_UNUSED(obj);

	// Save last click time
	if (ev->type() == QEvent::MouseButtonPress ||
	    ev->type() == QEvent::MouseButtonRelease ||
	    ev->type() == QEvent::MouseButtonDblClick)
		return updatePressTime();

	return false;
}
