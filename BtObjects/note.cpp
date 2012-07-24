#include "note.h"
#include "mediamodel.h"
#include "xml_functions.h"

#include <QFile>
#include <QtDebug>

#define DATE_FORMAT_AS_STRING "yyyy/MM/dd HH:mm"


bool parseNotes(QString file_path, MediaDataModel *notes)
{
	QFile fh(file_path);
	QDomDocument document;

	if (!fh.exists() || !document.setContent(&fh))
	{
		qWarning("The notes file %s does not seem a valid xml file", qPrintable(file_path));

		return false;
	}

	foreach (const QDomNode &note_node, getChildren(document.documentElement(), "note"))
	{
		QDateTime creation = QDateTime::fromString(getAttribute(note_node, "created"), DATE_FORMAT_AS_STRING);
		QDateTime update = QDateTime::fromString(getAttribute(note_node, "updated"), DATE_FORMAT_AS_STRING);
		Note *note = new Note(getIntAttribute(note_node, "profile"), getAttribute(note_node, "text"), creation);

		note->setUpdated(update);
		notes->append(note);
	}

	return true;
}

bool saveNotes(QString file_path, MediaDataModel *notes)
{
	QDomDocument document;
	QDomNode root = document.createElement("notes");

	document.appendChild(root);

	for (int i = 0; i < notes->getCount(); ++i)
	{
		Note *note = static_cast<Note *>(notes->getObject(i));
		QDomElement note_node = document.createElement("note");

		note_node.setAttribute("profile", note->getContainerId());
		note_node.setAttribute("text", note->getText());
		note_node.setAttribute("created", note->getCreated().toString(DATE_FORMAT_AS_STRING));
		note_node.setAttribute("updated", note->getUpdated().toString(DATE_FORMAT_AS_STRING));

		root.appendChild(note_node);
	}

	bool saved_ok = saveXml(document, file_path);

	if (!saved_ok)
		qWarning() << "Error saving notes file" << file_path;
	else
		qDebug() << "Notes file saved";

	return saved_ok;
}


Note::Note(int profile_id, QString _text, QDateTime _created)
{
	setContainerId(profile_id);

	connect(this, SIGNAL(updateChanged(QDateTime)), this, SIGNAL(persistItem()));

	text = _text;
	created = _created;
	updated = _created;
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
