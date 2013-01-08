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
	Q_INVOKABLE void addSecurityException();

	// only use for browser popup objects!
	Q_INVOKABLE void destroyQmlItem(QObject *object)
	{
		object->deleteLater();
	}

public slots:
	void quit();
	void updateClick();
	void credentialsRequired(BtNetworkAccessManager *, QNetworkReply *);
	void certificatesError(BtNetworkAccessManager *, QNetworkReply *);

signals:
	void urlChanged();
	void authenticationRequired();
	void untrustedSslConnection();
	void requestComplete(bool ssl, QString host, QString organization);

protected:
	bool eventFilter(QObject *obj, QEvent *ev);

private slots:
	void readInput();

private:
	void setVisible(bool visible);
	void parseLine(QString line);

	bool clicks_blocked;
	QString url;
	QString input;
	BtNetworkAccessManager *access_manager;
};

#endif // BROWSERPROPERTIES_H
