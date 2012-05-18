#include "globalproperties.h"
#include "guisettings.h"
#include "inputcontextwrapper.h"
#include "notelistmodel.h"

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

	// TODO we need a better implementation for this
	qmlRegisterUncreatableType<NoteListModel>("BtExperience", 1, 0, "NoteListModel", "");
	noteListModel = new NoteListModel(this);

	updateTime();
	// We emit a signal every second to update the time.
	QTimer *secs_timer = new QTimer(this);
	connect(secs_timer, SIGNAL(timeout()), this, SIGNAL(lastTimePressChanged()));
	secs_timer->start(1000);
}

QString GlobalProperties::getBasePath() const
{
	QFileInfo path = qApp->applicationDirPath();

#ifdef Q_WS_MAC
	path = QFileInfo(QDir(path.absoluteFilePath()), "../Resources");
#endif

	// use canonicalFilePath to resolve symlinks, otherwise some files
	// will be loaded with the symlinked path and some with the canonical
	// path, and this confuses the code that handles ".pragma library"
	return QFileInfo(QDir(path.absoluteFilePath()), "gui/skins/default/")
		   .canonicalFilePath() + "/";
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

// TODO waiting for better implementation
NoteListModel *GlobalProperties::getNoteListModel() const
{
	return noteListModel;
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
	emit lastTimePressChanged();
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
