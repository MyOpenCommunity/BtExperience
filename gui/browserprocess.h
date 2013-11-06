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

#ifndef BROWSERPROCESS_H
#define BROWSERPROCESS_H

#include <QObject>

class QProcess;
class QTimer;


class BrowserProcess : public QObject
{
	Q_OBJECT

	Q_PROPERTY(bool visible READ getVisible WRITE setVisible NOTIFY visibleChanged)

	Q_PROPERTY(bool running READ getRunning NOTIFY runningChanged)

public:
	BrowserProcess(QObject *parent = 0);

	Q_INVOKABLE void displayUrl(QString url);

	void clearHistory();
	void setHistorySize(int size);
	void setPersistentHistory(bool persistent);

	void setVisible(bool visible);
	bool getVisible() const;

	bool getRunning() const;

	void setClicksBlocked(bool blocked);

signals:
	void visibleChanged();
	void runningChanged();
	void clicked();
	void aboutToHide();
	void createQuicklink(int type, QString name, QString address);

private slots:
	void terminated();
	void readStatusUpdate();
	void processStateChanged();
	void sendKeepAlive();

private:
	void startProcess();
	void sendCommand(QString command);
	void updateVisible(bool visible);

	bool visible, clear_history, persistent_history;
	int keep_alive_ticks, history_size;
	QProcess *browser;
	QTimer *keep_alive;
};

#endif // BROWSERPROCESS_H
