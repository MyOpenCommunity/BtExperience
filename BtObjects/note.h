#ifndef NOTE_H
#define NOTE_H

#include "iteminterface.h"

#include <QDateTime>


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
	Note(int profile_id, QString text);

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
