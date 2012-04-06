#include "globalproperties.h"
#include "guisettings.h"
#include "inputcontextwrapper.h"

#include <QTimer>
#include <QDateTime>
#include <QScreen>
#include <QPixmap>
#include <QDeclarativeView>
#include <QtDeclarative>


GlobalProperties::GlobalProperties()
{
	wrapper = new InputContextWrapper(this);
	main_widget = NULL;
	qmlRegisterUncreatableType<GuiSettings>("BtExperience", 1, 0, "GuiSettings", "");
	settings = new GuiSettings(this);

	updateTime();
	// We emit a signal every second to update the time.
	QTimer *secs_timer = new QTimer(this);
	connect(secs_timer, SIGNAL(timeout()), this, SIGNAL(lastTimePressChanged()));
	secs_timer->start(1000);
}

QString GlobalProperties::getBasePath() const
{
	return QString("gui/skins/default/");
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

GuiSettings *GlobalProperties::getGuiSettings() const
{
	return settings;
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

void GlobalProperties::setMainWidget(QDeclarativeView *_viewport)
{
	main_widget = _viewport;
}

QImage GlobalProperties::takeScreenshot(QRect rect)
{
	QWidget *viewport = main_widget->viewport();

	if (!viewport)
		viewport = main_widget;

	return QPixmap::grabWidget(viewport, rect.isValid() ? rect : main_widget->rect()).toImage();
}
