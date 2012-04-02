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
	// TODO use a QVariantList
	Q_PROPERTY(QString path READ getPath CONSTANT)
	Q_PROPERTY(FileType fileType READ getFileType CONSTANT)
	Q_PROPERTY(QVariantMap metadata READ getMetadata CONSTANT)
	Q_PROPERTY(bool isLoading READ isLoading CONSTANT)
	Q_ENUMS(FileType)

public:
	FileObject(const EntryInfo &entry, QObject *parent = 0);

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

	QString getPath() const;
	FileType getFileType() const;
	QVariantMap getMetadata() const;
	bool isLoading() const;

private:
	EntryInfo entry;
	bool loading;
};


class TreeBrowserListModelBase : public QAbstractListModel
{
	Q_OBJECT

	Q_PROPERTY(QVariantList rootPath READ getRootPath WRITE setRootPath NOTIFY rootPathChanged)
	Q_PROPERTY(bool isRoot READ isRoot NOTIFY isRootChanged)
	Q_PROPERTY(QVariantList currentPath READ getCurrentPath NOTIFY currentPathChanged)
	// TODO use a list rather than a bitmask?
	Q_PROPERTY(int filter READ getFilter WRITE setFilter NOTIFY filterChanged)
	Q_PROPERTY(bool isLoading READ isLoading NOTIFY loadingChanged)
	Q_PROPERTY(QVariantList range READ getRange WRITE setRange NOTIFY rangeChanged)
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
	void enterDirectory(QString name);
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
