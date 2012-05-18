#ifndef NOTELISTMODEL_H
#define NOTELISTMODEL_H


#include <QAbstractListModel>
#include <QDateTime>


class Note : public QObject
{
	Q_OBJECT

	/*!
		\brief The note text
	*/
	Q_PROPERTY(QString text READ getText WRITE setText NOTIFY textChanged)

	/*!
		\brief The datetime when the note was created
	*/
	Q_PROPERTY(QDateTime created READ getCreated WRITE setCreated NOTIFY createdChanged)

	/*!
		\brief The datetime when the note was last updated
	*/
	Q_PROPERTY(QDateTime updated READ getUpdated WRITE setUpdated NOTIFY updateChanged)

private:
	QDateTime created;
	QString text;
	QDateTime updated;

public:
	Note(QString text, QObject *parent);

	QString getText() const
	{
		return text;
	}

	QDateTime getCreated() const
	{
		return created;
	}

	QDateTime getUpdated() const
	{
		return updated;
	}

public slots:
	void setText(QString arg)
	{
		if (text != arg) {
			text = arg;
			updated = QDateTime::currentDateTime();
			emit textChanged(arg);
			emit updateChanged(updated);
		}
	}

	void setCreated(QDateTime arg)
	{
		if (created != arg) {
			created = arg;
			emit createdChanged(arg);
		}
	}

	void setUpdated(QDateTime arg)
	{
		if (updated != arg) {
			updated = arg;
			emit updateChanged(arg);
		}
	}

signals:
	void textChanged(QString arg);
	void createdChanged(QDateTime arg);
	void updateChanged(QDateTime arg);
};

class NoteListModel : public QAbstractListModel
{
	Q_OBJECT
	Q_PROPERTY(int count READ getCount NOTIFY countChanged)

public:
	explicit NoteListModel(QObject *parent = 0);

	Q_INVOKABLE QObject *getObject(int row) const;
	Q_INVOKABLE bool remove(int index);
	Q_INVOKABLE void append(QString note);

	virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
	virtual bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex());

	int getCount() const
	{
		return item_list.size();
	}

	// We cannot use the roles system offered by Qt models because we don't want
	// a double interface for the ObjectInterface objects.
	// In fact, we have to extract single qt objects, using the getObject method,
	// to pass them to their specific components (ex: the Light object must to
	// be passed to the Light.qml component).
	// An object extracted in that way offers a public API formed by properties,
	// public slots, Q_INVOKABLE methods and signals but the same object when
	// used inside the model's delegate exposes an API composed by the roles of
	// the model.
	// So, in order to obtain an unique API, we use the getObject method even
	// inside delegates.
	virtual QVariant data(const QModelIndex &index, int role) const
	{
		Q_UNUSED(index)
		Q_UNUSED(role)
		return QVariant();
	}

signals:
	void countChanged();

public slots:

private:
	QList<QObject*> item_list;
};

#endif // NOTELISTMODEL_H
