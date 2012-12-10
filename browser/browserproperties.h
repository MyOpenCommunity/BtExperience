#ifndef BROWSERPROPERTIES_H
#define BROWSERPROPERTIES_H

#include "globalpropertiescommon.h"

#include <QObject>

class BtNetworkAccessManager;
class QNetworkReply;

class BrowserProperties : public GlobalPropertiesCommon
{
	Q_OBJECT

	Q_PROPERTY(QString url READ getUrl WRITE setUrl NOTIFY urlChanged)

public:
	BrowserProperties(logger *log);

	void setUrl(QString url);
	QString getUrl() const;
	Q_INVOKABLE void setSslAuthentication(const QString &user, const QString &pass);
	Q_INVOKABLE void abortConnection();

public slots:
	void quit();
	void updateClick();
	void credentialsRequired(BtNetworkAccessManager *, QNetworkReply *);

signals:
	void urlChanged();
	void authenticationRequired();

private slots:
	void readInput();

private:
	void parseLine(QString line);

	QString url;
	QString input;
	BtNetworkAccessManager *access_manager;
};

#endif // BROWSERPROPERTIES_H
