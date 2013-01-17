#include "folderlistmodel.h"
#include "treebrowser.h"

#include <QtDebug>


namespace
{
	PagedFolderListModel *activeModel = 0;
}

XmlDevice *UPnPListModel::xml_device = NULL;


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

	void clearList(QList<FileObject *> &list)
	{
		foreach (QObject *obj, list)
			obj->deleteLater();

		list.clear();
	}
}


FileObject::FileObject(QObject *parent) :
	ObjectInterface(parent)
{
	loading = true;
}

FileObject::FileObject(const EntryInfo &_entry, QVariantList _path, QObject *parent) :
	ObjectInterface(parent),
	entry(_entry),
	logical_path(_path)
{
	logical_path << entry.name;
	loading = false;
}

QString FileObject::getName() const
{
	return entry.name;
}

QString FileObject::getPath() const
{
	return entry.path;
}

QVariantList FileObject::getLogicalPath() const
{
	return logical_path;
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

EntryInfo FileObject::getEntryInfo() const
{
	return entry;
}

void FileObject::setFileInfo(const EntryInfo &_entry, QVariantList _path)
{
	QString old_name = entry.name;
	entry = _entry;
	logical_path = _path << _entry.name;
	loading = false;

	// we could use a more fine-grained signal, but there is little point in optimizing,
	// since it's only emitted once per object
	emit loadingComplete();
	if (old_name != entry.name)
		emit nameChanged();
}


TreeBrowserListModelBase::TreeBrowserListModelBase(TreeBrowser *_browser, QObject *parent) :
	QAbstractListModel(parent)
{
	browser = _browser;
	min_range = max_range = -1;
	filter = 0;
	loading = false;

	connect(this, SIGNAL(currentPathChanged()), this, SLOT(directoryChanged()));
	connect(browser, SIGNAL(directoryChanged()), this, SIGNAL(currentPathChanged()));
	connect(browser, SIGNAL(directoryChangeError()), this, SIGNAL(directoryChangeError()));
	connect(browser, SIGNAL(emptyDirectory()), this, SIGNAL(emptyDirectory()));
	connect(browser, SIGNAL(isRootChanged()), this, SIGNAL(isRootChanged()));

	// in case of success, the flag is reset after reloading the file list
	connect(browser, SIGNAL(directoryChangeError()), this, SLOT(resetLoadingFlag()));
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

	browser->setRootPath(path);
	current_path = _path;
	emit rootPathChanged();
	if (old_current != current_path)
		emit currentPathChanged();
	browser->getFileList();
}

QVariantList TreeBrowserListModelBase::getRootPath() const
{
	return toVariantList(browser->getRootPath());
}

bool TreeBrowserListModelBase::isRoot() const
{
	return browser->isRoot();
}

void TreeBrowserListModelBase::setLoadingIfAsynchronous()
{
	setLoading(false);
}

void TreeBrowserListModelBase::setLoading(bool _loading)
{
	if (loading == _loading)
		return;

	loading = _loading;
	emit loadingChanged();
}

void TreeBrowserListModelBase::setCurrentPath(QVariantList cp)
{
	if (current_path != cp)
	{
		current_path = cp;
		emit currentPathChanged();
	}
}

bool TreeBrowserListModelBase::isLoading() const
{
	return loading;
}

void TreeBrowserListModelBase::enterDirectory(QString name)
{
	setLoadingIfAsynchronous();

	pending_dirchange = name;
	browser->enterDirectory(name);
}

void TreeBrowserListModelBase::exitDirectory()
{
	if (isRoot())
		return;

	setLoadingIfAsynchronous();

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

	// TODO should reload?
	browser->setFilter(mask);
	filter = mask;
	browser->getFileList();
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
}


FolderListModel::FolderListModel(TreeBrowser *browser, QObject *parent) :
	TreeBrowserListModelBase(browser, parent)
{
	connect(browser, SIGNAL(listReceived(EntryInfoList)), this, SLOT(gotFileList(EntryInfoList)));

	connect(browser, SIGNAL(listRetrieveError()), this, SLOT(resetLoadingFlag()));
}

ObjectInterface *FolderListModel::getObject(int row)
{
	int index = min_range == -1 ? row : min_range + row;

	if (index >= item_list.size())
		return NULL;

	return item_list[index];
}

void FolderListModel::setRange(QVariantList range)
{
	int min = min_range, max = max_range;

	TreeBrowserListModelBase::setRange(range);

	if (min != min_range || max != max_range)
		reset();
}

int FolderListModel::rowCount(const QModelIndex &parent) const
{
	Q_UNUSED(parent);

	if (min_range != -1 && max_range != -1)
		return qMin(max_range, getCount()) - min_range;

	return item_list.size();
}

int FolderListModel::getCount() const
{
	return item_list.size();
}

void FolderListModel::gotFileList(EntryInfoList list)
{
	int size = getCount();

	clearList(item_list);

	foreach (const EntryInfo &entry, list)
		item_list.append(new FileObject(entry, getCurrentPath(), this));

	if (size != getCount())
		emit countChanged();
	reset();

	setLoading(false);
}

void FolderListModel::directoryChanged()
{
	TreeBrowserListModelBase::directoryChanged();

	browser->getFileList();
}


// TODO keep a cache of recently-viewed entries and pre-fetch the next pages
PagedFolderListModel::PagedFolderListModel(PagedTreeBrowser *_browser, QObject *parent) :
	TreeBrowserListModelBase(_browser, parent)
{
	activeModel = this;
	start_index = item_count = current_index = 0;
	browser = _browser;
	pending_operation = discard_pending = false;

	connect(browser, SIGNAL(listReceived(EntryInfoList)), this, SLOT(gotFileList(EntryInfoList)));

	connect(browser, SIGNAL(listRetrieveError()), this, SLOT(resetLoadingFlag()));
	connect(browser, SIGNAL(rootDirectoryEntered()), this, SLOT(changeRootDirectory()));
}

void PagedFolderListModel::setLoadingIfAsynchronous()
{
	setLoading(true);
}

ObjectInterface *PagedFolderListModel::getObject(int row)
{
	int index = min_range == -1 ? row : min_range + row;

	// outside the cached items, just return NULL for now
	if (index < start_index || index >= start_index + item_list.size())
		return NULL;

	return item_list[min_range - start_index  + row];
}

void PagedFolderListModel::requestFirstPage()
{
	setLoading(true);

	// ignore the result of the current operation, if in progress
	discard_pending = pending_operation;

	resetInternalState();

	// if no pending operation, request the first page, otherwise wait for
	// the current operation to complete
	if (!pending_operation)
	{
		browser->getFileList(current_index + 1);
		pending_operation = true;
	}

	reset();
}

void PagedFolderListModel::resetInternalState()
{
	// prepare the item list cache
	clearList(item_list);
	for (int i = min_range; i < max_range; ++i)
		item_list.append(new FileObject(this));

	start_index = current_index = min_range;
}

void PagedFolderListModel::setRange(QVariantList range)
{
	int min = min_range, max = max_range;

	TreeBrowserListModelBase::setRange(range);

	// only request data if the user set the page range, to avoid requesting the full list
	if ((min != min_range || max != max_range) && (min_range != -1 && max_range != -1))
		requestFirstPage();
}

void PagedFolderListModel::setRootPath(QVariantList path)
{
	Q_UNUSED(path);

	// do nothing, not supported for UPnP
}

QVariantList PagedFolderListModel::getRootPath() const
{
	return QVariantList();
}

void PagedFolderListModel::setFilter(int mask)
{
	activeModel = this;
	start_index = item_count = current_index = 0;
	pending_operation = discard_pending = false;

	TreeBrowserListModelBase::setFilter(mask);
}

int PagedFolderListModel::rowCount(const QModelIndex &parent) const
{
	Q_UNUSED(parent);

	if (min_range != -1 && max_range != -1)
		return qMin(max_range, getCount()) - min_range;

	return getCount();
}

int PagedFolderListModel::getCount() const
{
	return item_count;
}

void PagedFolderListModel::directoryChanged()
{
	pending_operation = false;

	TreeBrowserListModelBase::directoryChanged();

	// assume the range size is the same when navigating, and request the
	// first page
	if (min_range != -1 && max_range != -1)
	{
		max_range -= min_range;
		min_range = 0;
	}

	// here we can't optimize and wait for the range to be set, because the list size
	// is received with the page list message
	requestFirstPage();
}

void PagedFolderListModel::gotFileList(EntryInfoList list)
{
	if (this != activeModel)
		return;

	pending_operation = false;

	// update list size
	item_count = 0;
	if (item_count != browser->getNumElements())
	{
		item_count = browser->getNumElements();
		reset();
		emit countChanged();
	}

	// update the data in item list
	if (!discard_pending && min_range != max_range)
	{
		foreach (const EntryInfo &entry, list)
		{
			item_list[current_index - start_index]->setFileInfo(entry, getCurrentPath());
			++current_index;
			if (current_index - start_index >= item_list.size())
				break;
		}
	}

	// if we need more entries, request them, otherwise signal completion
	if (current_index < qMin(max_range, getCount()))
	{
		browser->getFileList(current_index + 1);
		pending_operation = true;
	}
	else
	{
		setLoading(false);
		reset();
		emit countChanged();
	}

	discard_pending = false;
}

void PagedFolderListModel::changeRootDirectory()
{
	resetInternalState();
}


DirectoryListModelMemento::~DirectoryListModelMemento()
{
	delete tm;
}


DirectoryListModel::DirectoryListModel(QObject *parent) :
	FolderListModel(new DirectoryTreeBrowser, parent)
{
}

DirectoryListModelMemento *DirectoryListModel::clone()
{
	DirectoryListModelMemento *m = new DirectoryListModelMemento;
	DirectoryTreeBrowser *b = static_cast<DirectoryTreeBrowser *>(browser);
	m->tm = b->clone();
	m->filter = getFilter();
	m->range = getRange();
	m->root_path = getRootPath();
	m->current_path = getCurrentPath();
	return m;
}

void DirectoryListModel::restore(DirectoryListModelMemento *m)
{
	DirectoryTreeBrowser *b = static_cast<DirectoryTreeBrowser *>(browser);
	b->restore(m->tm);
	setRootPath(m->root_path);
	setCurrentPath(m->current_path);
	setRange(m->range);
	setFilter(m->filter);
}


UPnPListModel::UPnPListModel(QObject *parent) :
	PagedFolderListModel(new UPnpClientBrowser(getXmlDevice()), parent)
{
}

XmlDevice *UPnPListModel::getXmlDevice()
{
	if (xml_device == NULL)
		xml_device = new XmlDevice;

	return xml_device;
}
