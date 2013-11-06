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

#ifndef NOTE_H
#define NOTE_H

#include "iteminterface.h"

#include <QDateTime>

class Note;
class MediaDataModel;

bool parseNotes(QString file_path, MediaDataModel *notes);
bool saveNotes(QString file_path, MediaDataModel *notes);


/*!
	\brief An user-created note
*/
class Note : public ItemInterface
{
	Q_OBJECT

	/*!
		\brief The note text
	*/
	Q_PROPERTY(QString text READ getText WRITE setText NOTIFY textChanged)

	/*!
		\brief The datetime when the note was created
	*/
	Q_PROPERTY(QDateTime created READ getCreated CONSTANT)

	/*!
		\brief The datetime when the note was last updated
	*/
	Q_PROPERTY(QDateTime updated READ getUpdated WRITE setUpdated NOTIFY updateChanged)

public:
	Note(int profile_uii, QString text, QDateTime created = QDateTime::currentDateTime());

	QString getText() const;
	QDateTime getCreated() const;
	QDateTime getUpdated() const;

public slots:
	void setText(QString text);
	void setUpdated(QDateTime update_time);

signals:
	void textChanged(QString text);
	void updateChanged(QDateTime update_time);

private:
	QDateTime created;
	QString text;
	QDateTime updated;
};

#endif // NOTE_H
