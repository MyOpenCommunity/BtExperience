#include "folderlistmodel.h"
#include "treebrowser.h"

#include <QtDebug>


namespace
{
	QStringList fromVariantList(const QVariantList &list)
	{
		QStringList res;

		foreach (const QVariant &v, list)
			res.append(v.toString());

		return res;
	}

	QVariantList toVariantList(const QStringList &list)
	{
		QVariantList res;

		foreach (const QString &s, list)
			res.append(s);

		return res;
	}

	void clearList(QList<ObjectInterface *> &list)
	{
		foreach (QObject *obj, list)
			obj->deleteLater();

		list.clear();
	}
}

FileObject::FileObject(const EntryInfo &_entry, QVariantList _path, QObject *parent) :
	ObjectInterface(parent),
	entry(_entry),
	path(_path)
{
	path << entry.name;
	loading = false;
}

QString FileObject::getName() const
{
	return entry.name;
}

QVariantList FileObject::getPath() const
{
	return path;
}

FileObject::FileType FileObject::getFileType() const
{
	return static_cast<FileType>(entry.type);
}

QVariantMap FileObject::getMetadata() const
{
	QVariantMap result;

	foreach (QString key, entry.metadata)
		result[key] = entry.metadata[key];

	return result;
}

bool FileObject::isLoading() const
{
	return loading;
}


TreeBrowserListModelBase::TreeBrowserListModelBase(TreeBrowser *_browser, QObject *parent) :
	QAbstractListModel(parent)
{
	browser = _browser;
	min_range = max_range = -1;
	filter = 0;

	connect(this, SIGNAL(currentPathChanged()), this, SLOT(directoryChanged()));
	connect(browser, SIGNAL(directoryChanged()), this, SIGNAL(currentPathChanged()));
	connect(browser, SIGNAL(directoryChangeError()), this, SIGNAL(directoryChangeError()));
	connect(browser, SIGNAL(emptyDirectory()), this, SIGNAL(emptyDirectory()));
}

TreeBrowserListModelBase::~TreeBrowserListModelBase()
{
	delete browser;
}

void TreeBrowserListModelBase::setRootPath(QVariantList _path)
{
	QStringList path = fromVariantList(_path);
	QVariantList old_current = current_path;

	if (path == browser->getRootPath())
		return;

	bool root = browser->isRoot();

	browser->setRootPath(path);
	current_path = _path;

	if (root != browser->isRoot())
		emit isRootChanged();
	emit rootPathChanged();
	if (old_current != current_path)
		emit currentPathChanged();
}

QVariantList TreeBrowserListModelBase::getRootPath() const
{
	return toVariantList(browser->getRootPath());
}

bool TreeBrowserListModelBase::isRoot() const
{
	return browser->isRoot();
}

void TreeBrowserListModelBase::enterDirectory(QString name)
{
	pending_dirchange = name;
	browser->enterDirectory(name);
}

void TreeBrowserListModelBase::exitDirectory()
{
	// intentionally not the null string, see directoryChanged()
	pending_dirchange = "";
	browser->exitDirectory();
}

QVariantList TreeBrowserListModelBase::getCurrentPath() const
{
	return current_path;
}

void TreeBrowserListModelBase::setFilter(int mask)
{
	if (mask == filter)
		return;

	browser->setFilter(mask);
	filter = mask;
	emit filterChanged();
}

int TreeBrowserListModelBase::getFilter() const
{
	return filter;
}

void TreeBrowserListModelBase::directoryChanged()
{
	if (!pending_dirchange.isNull())
	{
		if (pending_dirchange.isEmpty())
			current_path.pop_back();
		else
			current_path << pending_dirchange;
	}

	pending_dirchange = QString();

	browser->getFileList();
}

QVariantList TreeBrowserListModelBase::getRange() const
{
	return QVariantList() << min_range << max_range;
}

void TreeBrowserListModelBase::setRange(QVariantList range)
{
	if (range.length() != 2)
	{
		qDebug() << "TreeBrowserListModelBase::setRange: the range must be a couple of int [min, max)";
		return;
	}

	bool min_ok, max_ok;
	int min = range.at(0).toInt(&min_ok);
	int max = range.at(1).toInt(&max_ok);

	if (!min_ok || !max_ok)
	{
		qDebug() << "TreeBrowserListModelBase::setRange: one of [min, max) is not an integer";
		return;
	}

	if (min_range == min && max_range == max)
		return;

	min_range = min;
	max_range = max;

	emit rangeChanged();
	// assumes ranges do not overlap, so there is no point in trying to minimize reloads
	reset();
}


FolderListModel::FolderListModel(TreeBrowser *browser, QObject *parent) :
	TreeBrowserListModelBase(browser, parent)
{
	connect(browser, SIGNAL(listReceived(EntryInfoList)), this, SLOT(gotFileList(EntryInfoList)));
}

ObjectInterface *FolderListModel::getObject(int row)
{
	int index = min_range == -1 ? row : min_range + row;

	if (index >= item_list.size())
		return NULL;

	return item_list[index];
}

int FolderListModel::rowCount(const QModelIndex &parent) const
{
	if (min_range != -1 && max_range != -1)
		return qMin(max_range, getSize()) - min_range;

	return item_list.size();
}

int FolderListModel::getSize() const
{
	return item_list.size();
}

void FolderListModel::gotFileList(EntryInfoList list)
{
	int size = getSize();

	clearList(item_list);

	foreach (const EntryInfo &entry, list)
		item_list.append(new FileObject(entry, getCurrentPath(), this));

	if (size != getSize())
		emit sizeChanged();
	reset();
}


// TODO invalidate/reconstruct item_list when range changes, request only displayed files
//      and update the FileObject when the response is received
PagedFolderListModel::PagedFolderListModel(UPnpClientBrowser *_browser, QObject *parent) :
	TreeBrowserListModelBase(_browser, parent)
{
	start_index = 0;
	browser = _browser;
}

ObjectInterface *PagedFolderListModel::getObject(int row)
{
	int index = min_range == -1 ? row : min_range + row;

	// outside the cached items, just return NULL for now
	if (index < start_index || index >= start_index + item_list.size())
		return NULL;

	return item_list[min_range - start_index  + row];
}

int PagedFolderListModel::rowCount(const QModelIndex &parent) const
{
	if (min_range != -1 && max_range != -1)
		return qMin(max_range, getSize()) - min_range;

	return browser->getNumElements();
}

int PagedFolderListModel::getSize() const
{
	return browser->getNumElements();
}


DirectoryListModel::DirectoryListModel(QObject *parent) :
	FolderListModel(new DirectoryTreeBrowser, parent)
{
}
