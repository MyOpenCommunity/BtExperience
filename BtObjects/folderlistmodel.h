#ifndef FOLDERLISTMODEL_H
#define FOLDERLISTMODEL_H

#include "objectinterface.h"
#include "generic_functions.h" // EntryInfo

#include <QAbstractListModel>

class TreeBrowser;
class UPnpClientBrowser;


// TODO add interface to set new file data
class FileObject : public ObjectInterface
{
	Q_OBJECT

	Q_PROPERTY(QVariantList path READ getPath CONSTANT)
	Q_PROPERTY(FileType fileType READ getFileType CONSTANT)
	Q_PROPERTY(QVariantMap metadata READ getMetadata CONSTANT)
	Q_PROPERTY(bool isLoading READ isLoading CONSTANT)
	Q_ENUMS(FileType)

public:
	FileObject(const EntryInfo &entry, QVariantList path, QObject *parent = 0);

	enum FileType
	{
		Unknown   = 0x01, /*!< Unknown filetype */
		Directory = 0x02, /*!< Directory */
		Audio     = 0x04, /*!< Audio filetype */
		Video     = 0x08, /*!< Video filetype */
		Image     = 0x10, /*!< Image filetype */
	};

	virtual int getObjectId() const { return -1; }

	virtual QString getObjectKey() const { return QString(); }

	virtual ObjectCategory getCategory() const { return Unassigned; }

	virtual QString getName() const;

	QVariantList getPath() const;
	FileType getFileType() const;
	QVariantMap getMetadata() const;
	bool isLoading() const;

private:
	EntryInfo entry;
	QVariantList path;
	bool loading;
};


/*!
	\brief List model for paged navigation on filesystem and UPnP

	Example use:

	DirectoryListModel {
		id: files
		rootPath: ['media', 'video', 'tv']
		range: [0, 6] // obtain range from paginator
	}

	The interface is similar \a FilterListModel, but it only implements a range filter
	for pagination.

	The objects returned by \a getObject() are \a FileObject instances.
*/
class TreeBrowserListModelBase : public QAbstractListModel
{
	Q_OBJECT

	/*!
		\brief Sets and gets he root path for navigation
	*/
	Q_PROPERTY(QVariantList rootPath READ getRootPath WRITE setRootPath NOTIFY rootPathChanged)

	/*!
		\brief Whether the current directory is the root directory
	*/
	Q_PROPERTY(bool isRoot READ isRoot NOTIFY isRootChanged)

	/*!
		\brief Current directory path
	*/
	Q_PROPERTY(QVariantList currentPath READ getCurrentPath NOTIFY currentPathChanged)

	// TODO use a list rather than a bitmask?
	Q_PROPERTY(int filter READ getFilter WRITE setFilter NOTIFY filterChanged)

	/*!
		\brief Set to \c true when an asynchronous operation is in progress
	*/
	Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingChanged)

	/*!
		\brief Sets and gets the currently-displayed range (use with Paginator object)
	*/
	Q_PROPERTY(QVariantList range READ getRange WRITE setRange NOTIFY rangeChanged)

	/*!
		\brief Gets total number of items in the model
	*/
	Q_PROPERTY(int size READ getSize NOTIFY sizeChanged)

public:
	TreeBrowserListModelBase(TreeBrowser *browser, QObject *parent = 0);
	~TreeBrowserListModelBase();

	// see comment in ObjectListModel
	virtual QVariant data(const QModelIndex &index, int role) const
	{
		Q_UNUSED(index)
		Q_UNUSED(role)
		return QVariant();
	}

	Q_INVOKABLE virtual ObjectInterface *getObject(int row) = 0;

	void setRootPath(QVariantList path);
	QVariantList getRootPath() const;

	bool isRoot() const;

	QVariantList getCurrentPath() const;

	void setFilter(int mask);
	int getFilter() const;

	virtual bool isLoading() const { return false; }

	QVariantList getRange() const;
	void setRange(QVariantList range);

	virtual int getSize() const = 0;

public slots:
	/*!
		\brief Navigate into a directory

		Emits \a directoryChangeError() on failure.  On success, automatically loads
		the files for the new directory.
	*/
	void enterDirectory(QString name);

	/*!
		\brief Navigate out of a directory

		Emits \a directoryChangeError() on failure.  On success, automatically loads
		the files for the new directory.

		If the current path is the root directory, returns without doing anything.
	*/
	void exitDirectory();

signals:
	void rootPathChanged();
	void isRootChanged();
	void currentPathChanged();
	void filterChanged();
	void loadingChanged();
	void rangeChanged();
	void sizeChanged();

	// error conditions
	void directoryChangeError();
	void emptyDirectory();

private slots:
	void directoryChanged();

protected:
	TreeBrowser *browser;
	int min_range, max_range;

private:
	int filter;
	QString pending_dirchange;
	QVariantList current_path;
};


class FolderListModel : public TreeBrowserListModelBase
{
	Q_OBJECT

public:
	FolderListModel(TreeBrowser *browser, QObject *parent = 0);

	virtual ObjectInterface *getObject(int row);
	virtual int rowCount(const QModelIndex &parent) const;
	virtual int getSize() const;

private slots:
	void gotFileList(EntryInfoList list);

private:
	QList<ObjectInterface *> item_list;
};


class PagedFolderListModel : public TreeBrowserListModelBase
{
	Q_OBJECT

public:
	PagedFolderListModel(UPnpClientBrowser *browser, QObject *parent = 0);

	virtual ObjectInterface *getObject(int row);
	virtual int rowCount(const QModelIndex &parent) const;
	virtual int getSize() const;

private:
	UPnpClientBrowser *browser;

	// item_list is a cache of recently-used objects, starting at index
	// start_index
	int start_index;
	QList<ObjectInterface *> item_list;
};


class DirectoryListModel : public FolderListModel
{
	Q_OBJECT

public:
	DirectoryListModel(QObject *parent = 0);
};

#endif // FOLDERLISTMODEL_H
