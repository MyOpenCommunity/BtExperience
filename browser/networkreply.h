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

#ifndef NETWORKREPLY_H
#define NETWORKREPLY_H

#include <QNetworkReply>


/*
	Wrapper arount QNetworkReply

	Forwards most methods to the wrapped reply, and provides default error
	content in case of network errors.

	Note that some methods in QNetworkReply (such as sslConfiguration/setSslConfiguration)
	are not virtual.
*/
class BtNetworkReply : public QNetworkReply
{
	Q_OBJECT

public:
	BtNetworkReply(QObject *parent, QNetworkReply *reply);
	~BtNetworkReply();

	// must be used to access SSL configuration (accessors aren't virtual)
	QNetworkReply *originalReply() const { return reply; }

	// QNetworkReply methods
	virtual void abort();
	virtual void close();
	virtual bool isSequential() const;

	virtual void setReadBufferSize(qint64 size);

	// QIODevice methods
	virtual qint64 bytesAvailable() const;

	virtual qint64 bytesToWrite() const;
	virtual bool canReadLine() const;

	virtual bool waitForReadyRead(int msecs);
	virtual bool waitForBytesWritten(int msecs);

	virtual qint64 readData(char *data, qint64 maxlen);

public slots:
	virtual void ignoreSslErrors();

	void updateMetaData();
	void handleError(QNetworkReply::NetworkError error_code);
	void handleRead();

private:
	void copyHeader(QNetworkRequest::KnownHeaders header);
	void copyAttribute(QNetworkRequest::Attribute attribute);

	QNetworkReply *reply;
	QByteArray buffer;
};

#endif
