#include <QtGlobal> // Q_WS_QWS

#include <QApplication>
#include <QtDeclarative>
#include <QSocketNotifier>

#include <logger.h>

#include "eventfilters.h"
#include "applicationcommon.h"
#include "globalpropertiescommon.h"
#include "imagereader.h"
#include "main.h"

#include <stdio.h>
#include <fcntl.h>
#include <time.h>


// Start definitions required by libcommon
logger *app_logger;
int VERBOSITY_LEVEL;

char *Prefix = const_cast<char*>("<BtBrowser>");

int use_ssl = false;
char *ssl_cert_key_path = NULL;
char *ssl_certificate_path = NULL;
// End definitions required by libcommon

QHash<GlobalField, QString> *bt_global::config;


class BrowserProperties : public GlobalPropertiesCommon
{
	Q_OBJECT

	Q_PROPERTY(QString url READ getUrl WRITE setUrl NOTIFY urlChanged)

public:
	BrowserProperties(logger *log);

	void setUrl(QString url);
	QString getUrl() const;

public slots:
	void quit();
	void updateClick();

signals:
	void urlChanged();

private slots:
	void readInput();

private:
	void parseLine(QString line);

	QString url;
	QString input;
};


BrowserProperties::BrowserProperties(logger *log) : GlobalPropertiesCommon(log)
{
	QSocketNotifier *stdin = new QSocketNotifier(0, QSocketNotifier::Read, this);

	connect(stdin, SIGNAL(activated(int)), this, SLOT(readInput()));
	fcntl(0, F_SETFL, (long)O_NONBLOCK);
}

void BrowserProperties::setUrl(QString _url)
{
	if (url == _url)
		return;
	url = _url;
	emit urlChanged();
}

QString BrowserProperties::getUrl() const
{
	return url;
}

void BrowserProperties::quit()
{
	qApp->quit();
}

void BrowserProperties::updateClick()
{
	printf("last_click: %ld\n", time(NULL));
}

void BrowserProperties::readInput()
{
	char buf[30];

	for (;;)
	{
		int rd = read(0, buf, sizeof(buf) - 1);

		if (rd <= 0)
			break;
		buf[rd] = 0;

		input.append(buf);
	}

	QStringList lines = input.split("\n");

	// put back incomplete last line
	input = lines.back();
	lines.pop_back();

	foreach (QString line, lines)
		parseLine(line);
}

void BrowserProperties::parseLine(QString line)
{
	if (line.startsWith("set_visible "))
	{
		bool visible = line.split(" ")[1].toInt();

		if (visible)
#if defined(Q_WS_X11) || defined(Q_WS_MAC)
			main_widget->show();
#else
			main_widget->showFullScreen();
#endif
		else
			main_widget->hide();

		printf("visible: %d\n", int(visible));
	}
	else if (line.startsWith("load_url "))
	{
		QString url = line.split(" ")[1];

		setUrl(url);
	}
	else if (line == "ping")
		printf("pong\n");
}


int main(int argc, char *argv[])
{
	QApplication app(argc, argv);
	ApplicationCommon qml_application;

	qml_application.initialize();

	qDebug() << "***** BtBrowser start! *****";

	qmlRegisterType<ImageReader>("BtExperience", 1, 0, "ImageReader");

	LastClickTime *last_click = new LastClickTime;
	// To receive all the events, even if there is some qml elements which manage
	// their, we have to install the event filter in the QApplication
	app.installEventFilter(last_click);

	//Set user-agent of the application in order to see the Mobile version of the web sites
	app.setApplicationName(QString("Nokia"));
	app.setApplicationVersion(QString("Mobile"));

	BrowserProperties global(app_logger);
	if (argc > 1)
		global.setUrl(argv[1]);
	ImageReader::setBasePath(global.getBasePath());
	QObject::connect(last_click, SIGNAL(updateTime()), &global, SLOT(updateClick()));
	qml_application.start(&global, "browsermain.qml", false);

	return app.exec();
}

#include "browser.moc"
