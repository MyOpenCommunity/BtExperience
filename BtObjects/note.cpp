#include "note.h"


Note::Note(int profile_id, QString _text)
{
	setContainerId(profile_id);

	text = _text;
	created = QDateTime::currentDateTime();
	updated = QDateTime::currentDateTime();
}

void Note::setText(QString arg)
{
	if (text != arg)
	{
		text = arg;
		emit textChanged(arg);

		setUpdated(QDateTime::currentDateTime());
	}
}

QString Note::getText() const
{
	return text;
}

void Note::setCreated(QDateTime arg)
{
	if (created != arg)
	{
		created = arg;
		emit createdChanged(arg);
	}
}

QDateTime Note::getCreated() const
{
	return created;
}

void Note::setUpdated(QDateTime arg)
{
	if (updated != arg)
	{
		updated = arg;
		emit updateChanged(arg);
	}
}

QDateTime Note::getUpdated() const
{
	return updated;
}
