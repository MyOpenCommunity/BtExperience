#include "notelistmodel.h"


//*******************************************************************
//	Note implementation
//*******************************************************************

Note::Note(QString text, QObject *parent)
	: QObject(parent)
{
	this->text = text;
	this->created = QDateTime::currentDateTime();
	this->updated = QDateTime::currentDateTime();
}


//*******************************************************************
//	NoteListModel implementation
//*******************************************************************

NoteListModel::NoteListModel(QObject *parent) :
	QAbstractListModel(parent)
{
	// TODO remove on final implementation; probably we need to retrieve notes
	// from somewhere
	item_list.append(new Note("portare fuori la spazzatura", this));
	item_list.append(new Note("dentista 18/05/2012 ore 14:45", this));
	item_list.append(new Note("appunt. Sig. Mario Monti 18/05/2012 ore 17.00", this));
	item_list.append(new Note("pagare spese condominiali", this));
}

int NoteListModel::rowCount(const QModelIndex &parent) const
{
	Q_UNUSED(parent);
	return item_list.size();
}

QObject *NoteListModel::getObject(int row) const
{
	if (row < 0 || row >= item_list.size())
	{
		return 0;
	}
	return item_list.at(row);
}

bool NoteListModel::remove(int index)
{
	return removeRow(index);
}

void NoteListModel::append(QString note)
{
	beginInsertRows(QModelIndex(), 0, 0);
	item_list.insert(0, new Note(note, this));
	emit countChanged();
	endInsertRows();
}

bool NoteListModel::removeRows(int row, int count, const QModelIndex &parent)
{
	// Ensure that count is at least 1, otherwise we don't have to remove
	// anything
	if (row >= 0 && count > 0 && row + count <= item_list.size())
	{
		beginRemoveRows(parent, row, row + count - 1);
		for (int i = 0; i < count; ++i)
		{
			QObject *it = item_list.takeAt(row);
			it->disconnect();
			it->deleteLater();
		}
		endRemoveRows();
		emit countChanged();
		return true;
	}
	return false;
}
