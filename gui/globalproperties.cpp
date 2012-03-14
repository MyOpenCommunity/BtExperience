#include "globalproperties.h"
#include "inputcontextwrapper.h"

#include <QTimer>
#include <QDateTime>
#include <QScreen>


GlobalProperties::GlobalProperties()
{
	wrapper = new InputContextWrapper(this);

	updateTime();
	// We emit a signal every second to update the time.
	QTimer *secs_timer = new QTimer(this);
	connect(secs_timer, SIGNAL(timeout()), this, SIGNAL(lastTimePressChanged()));
	secs_timer->start(1000);
}

int GlobalProperties::getMainWidth() const
{
#ifdef Q_WS_QWS
	return QScreen::instance()->width();
#else
	return MAIN_WIDTH;
#endif
}

int GlobalProperties::getMainHeight() const
{
#ifdef Q_WS_QWS
	return QScreen::instance()->height();
#else
	return MAIN_HEIGHT;
#endif
}

QObject *GlobalProperties::getInputWrapper() const
{
	return wrapper;
}

int GlobalProperties::getLastTimePress() const
{
	return last_press.secsTo(QDateTime::currentDateTime());
}

void GlobalProperties::updateTime()
{
	last_press = QDateTime::currentDateTime();
}
