#ifndef FOLDERLISTMODEL_H
#define FOLDERLISTMODEL_H

#include "objectinterface.h"
#include "generic_functions.h" // EntryInfo

#include <QAbstractListModel>

class TreeBrowser;
class DirectoryBrowserMemento;
class FolderListModelMemento;
class PagedTreeBrowser;
class XmlDevice;


// TODO add interface to set new file data
class FileObject : public ObjectInterface
{
	Q_OBJECT

	/*!
		\brief Physical path for the file.

		This is the path to use when playing the file. It is the same as
		\ref logicalPath when the file is on the file system, it's different
		when the file is read from an UPnP server.
	*/
	Q_PROPERTY(QString path READ getPath CONSTANT)

	/*!
		\brief User friendly path of a file.

		The logical path can be used when there's the need to know the path of the
		file which is somewhat user friendly; for example, UPnP paths usually are like
		http://mediaserverip/custom/path while the logical path in this case would
		be ["mediaserver name", "path", "to", "file"].
	*/
	Q_PROPERTY(QVariantList logicalPath READ getLogicalPath CONSTANT)
	Q_PROPERTY(FileType fileType READ getFileType NOTIFY loadingComplete)
	Q_PROPERTY(QVariantMap metadata READ getMetadata NOTIFY loadingComplete)
	Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingComplete)
	Q_ENUMS(FileType)

public:
	FileObject(QObject *parent = 0);
	FileObject(const EntryInfo &entry, QVariantList path, QObject *parent = 0);

	enum FileType
	{
		Unknown   = 0x01, /*!< Unknown filetype */
		Directory = 0x02, /*!< Directory */
		Audio     = 0x04, /*!< Audio filetype */
		Video     = 0x08, /*!< Video filetype */
		Image     = 0x10, /*!< Image filetype */
		All       = Unknown | Directory | Audio | Video | Image
	};

	virtual QString getName() const;

	QString getPath() const;
	QVariantList getLogicalPath() const;
	FileType getFileType() const;
	QVariantMap getMetadata() const;
	bool isLoading() const;
	EntryInfo getEntryInfo() const;

	void setFileInfo(const EntryInfo &entry, QVariantList path);

signals:
	void loadingComplete();

private:
	EntryInfo entry;
	QVariantList logical_path;
	bool loading;
};

/*!
	\brief List model for paged navigation on filesystem and UPnP

	Example use:

	DirectoryListModel {
		id: files
		rootPath: ['media', 'video', 'tv'] // UNIX path "/media/video/tv"
		range: [0, 6] // obtain range from paginator
	}

	The interface is similar \ref ObjectModel, but it only implements a range filter
	for pagination.

	The objects returned by \ref getObject() are \a FileObject instances.
*/
class TreeBrowserListModelBase : public QAbstractListModel
{
	Q_OBJECT

	/*!
		\brief Sets and gets he root path for navigation

		Each element in the list is a level in the file system tree, for example:
		\c [] (the empty list) is the root path \c "/", and the list
		\c ["usr", "local", "media"] is the path \c "/usr/local/media".
	*/
	Q_PROPERTY(QVariantList rootPath READ getRootPath WRITE setRootPath NOTIFY rootPathChanged)

	/*!
		\brief Whether the current directory is the root directory
	*/
	Q_PROPERTY(bool isRoot READ isRoot NOTIFY isRootChanged)

	/*!
		\brief Current directory path

		Each element in the list is a level in the file system tree, for example:
		\c [] (the empty list) is the root path \c "/", and the list
		\c ["usr", "local", "media"] is the path \c "/usr/local/media".
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
	Q_PROPERTY(int count READ getCount NOTIFY countChanged)

public:
	TreeBrowserListModelBase(TreeBrowser *browser, QObject *parent = 0);
	~TreeBrowserListModelBase();

	// see comment in MediaModel
	virtual QVariant data(const QModelIndex &index, int role) const
	{
		Q_UNUSED(index)
		Q_UNUSED(role)
		return QVariant();
	}

	/*!
		\brief Returns the specified item

		Row must be in the range <tt>[0 .. rangeCount - 1]</tt>
	*/
	Q_INVOKABLE virtual ObjectInterface *getObject(int row) = 0;

	virtual void setRootPath(QVariantList path);
	virtual QVariantList getRootPath() const;

	bool isRoot() const;

	QVariantList getCurrentPath() const;

	void setFilter(int mask);
	int getFilter() const;

	bool isLoading() const;

	QVariantList getRange() const;
	virtual void setRange(QVariantList range);

	virtual int getCount() const = 0;

	virtual FolderListModelMemento *clone();
	virtual void restore(FolderListModelMemento *m);

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
	void countChanged();

	// error conditions
	void directoryChangeError();
	void emptyDirectory();

protected slots:
	virtual void directoryChanged();

protected:
	virtual void setLoadingIfAsynchronous();
	virtual void startLoadingItems();

	void resetCurrentRange();
	void setCurrentRange(QVariantList range);
	QVariantList getCurrentRange() const;

	void setLoading(bool loading);
	void setCurrentPath(QVariantList cp);

	TreeBrowser *browser;
	int min_range, max_range;

private slots:
	void resetLoadingFlag() { setLoading(false); }

private:
	int filter;
	bool loading;
	QString pending_dirchange;
	QVariantList current_path;
	QHash<QString, QVariantList> page_position;
};


class FolderListModel : public TreeBrowserListModelBase
{
	Q_OBJECT

public:
	FolderListModel(TreeBrowser *browser, QObject *parent = 0);

	virtual ObjectInterface *getObject(int row);
	virtual int rowCount(const QModelIndex &parent) const;
	virtual int getCount() const;

	void setRange(QVariantList range);

protected slots:
	virtual void directoryChanged();

private slots:
	void gotFileList(EntryInfoList list);

private:
	QList<FileObject *> item_list;
};


class PagedFolderListModel : public TreeBrowserListModelBase
{
	Q_OBJECT

public:
	PagedFolderListModel(PagedTreeBrowser *browser, QObject *parent = 0);

	virtual ObjectInterface *getObject(int row);
	virtual int rowCount(const QModelIndex &parent) const;
	virtual int getCount() const;

	virtual void setRange(QVariantList range);
	virtual void setRootPath(QVariantList path);
	virtual QVariantList getRootPath() const;
	void setFilter(int mask);

	virtual void restore(FolderListModelMemento *m);

protected:
	virtual void setLoadingIfAsynchronous();

protected slots:
	void directoryChanged();
	void contextChanged();

private slots:
	void gotFileList(EntryInfoList list);
	void changeRootDirectory();

protected:
	PagedTreeBrowser *browser;

private:
	virtual void startLoadingItems();
	void resetInternalState();

	// item_list is a cache of recently-used objects, starting at index
	// start_index
	QList<FileObject *> item_list;
	// the i-th item in item_list is the (start_index + i)-th item in the directory
	int start_index;
	// index of the first item requested to the UPnP server
	int current_index;
	// the total number of items in the directory
	int item_count;
	int discard_operations;

	// when min_range and max_range are set, we always have:
	// start_index <= min_range <= current_index <= max_range
};

class FolderListModelMemento
{
friend class TreeBrowserListModelBase;
public:
	~FolderListModelMemento();

	QVariantList getRootPath() const { return root_path; }

private:
	DirectoryBrowserMemento *tm;
	QVariantList root_path, current_path;
	QHash<QString, QVariantList> page_position;
	int filter;
};

class DirectoryListModel : public FolderListModel
{
	Q_OBJECT

public:
	DirectoryListModel(QObject *parent = 0);
};


class UPnPListModel : public PagedFolderListModel
{
	Q_OBJECT

public:
	UPnPListModel(QObject *parent = 0);
	static XmlDevice *getXmlDevice();

private:
	static XmlDevice *xml_device;
};

#endif // FOLDERLISTMODEL_H
