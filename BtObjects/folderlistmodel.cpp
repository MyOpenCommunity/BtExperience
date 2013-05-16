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

	inline QString pathKey(QVariantList path)
	{
		QStringList temp;

		foreach (QVariant item, path)
			temp.append(item.toString());

		return temp.join("\0");
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

QUrl FileObject::getPath() const
{
	if (entry.path.startsWith("http://"))
		return QUrl::fromUserInput(entry.path);
	else
		return QUrl::fromLocalFile(entry.path);
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
	page_position.clear();
	current_path = _path;
	emit rootPathChanged();
	if (old_current != current_path)
	{
		emit currentPathChanged();
		emit serverListChanged();
	}
	startLoadingItems();
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

void TreeBrowserListModelBase::startLoadingItems()
{
	browser->getFileList();
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
		emit serverListChanged();
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

	if (browser->isRoot())
	{
		current_path.clear();
		page_position.clear();
		browser->reset();
		emit serverListChanged();
	}
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
	startLoadingItems();
	emit filterChanged();
}

int TreeBrowserListModelBase::getFilter() const
{
	return filter;
}

void TreeBrowserListModelBase::resetCurrentRange()
{
	page_position.remove(pathKey(current_path));
}

void TreeBrowserListModelBase::setCurrentRange(QVariantList range)
{
	page_position[pathKey(current_path)] = range;
}

QVariantList TreeBrowserListModelBase::getCurrentRange() const
{
	return page_position.value(pathKey(current_path), QVariantList() << -1 << -1);
}

void TreeBrowserListModelBase::directoryChanged()
{
	if (!pending_dirchange.isNull())
	{
		if (pending_dirchange.isEmpty())
		{
			resetCurrentRange();
			current_path.pop_back();
			setRange(getCurrentRange());
			emit serverListChanged();
		}
		else
		{
			current_path << pending_dirchange;
			// another correct option might be just resetting the range to (-1, -1),
			// but setting it to a range of the same size as the current one should
			// not have any adverse affect and is probably a bit more efficient
			setRange(QVariantList() << 0 << max_range - min_range);
			emit serverListChanged();
		}
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

	// always save current range even if equal to previous one (directory might have changed)
	setCurrentRange(QVariantList() << min << max);

	if (min_range == min && max_range == max)
		return;

	min_range = min;
	max_range = max;

	emit rangeChanged();
}

FolderListModelMemento *TreeBrowserListModelBase::clone()
{
	FolderListModelMemento *m = new FolderListModelMemento;
	m->tm = browser->clone();
	m->filter = getFilter();
	m->page_position = page_position;
	m->root_path = getRootPath();
	m->current_path = getCurrentPath();
	return m;
}

void TreeBrowserListModelBase::restore(FolderListModelMemento *m)
{
	browser->restore(m->tm);
	setRootPath(m->root_path);
	page_position = m->page_position;
	setCurrentPath(m->current_path);
	setRange(getCurrentRange());
	setFilter(m->filter);
}

bool TreeBrowserListModelBase::getServerList() const
{
	return current_path.size() == 0;
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

	startLoadingItems();
}


// TODO keep a cache of recently-viewed entries and pre-fetch the next pages
PagedFolderListModel::PagedFolderListModel(PagedTreeBrowser *_browser, QObject *parent) :
	TreeBrowserListModelBase(_browser, parent)
{
	activeModel = this;
	start_index = item_count = current_index = 0;
	browser = _browser;
	discard_operations = 0;

	connect(browser, SIGNAL(listReceived(EntryInfoList)), this, SLOT(gotFileList(EntryInfoList)));

	connect(browser, SIGNAL(listRetrieveError()), this, SLOT(resetLoadingFlag()));
	connect(browser, SIGNAL(rootDirectoryEntered()), this, SLOT(changeRootDirectory()));
	connect(browser, SIGNAL(contextChanged()), this, SLOT(contextChanged()));
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

void PagedFolderListModel::startLoadingItems()
{
	setLoading(true);

	// ignore the result of the current operation, if in progress
	discard_operations = browser->lastQueuedCommand();

	resetInternalState();

	// if no pending operation, request the first page, otherwise wait for
	// the current operation to complete
	browser->getFileList(current_index + 1);

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
		startLoadingItems();
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
	discard_operations = browser->lastQueuedCommand();

	TreeBrowserListModelBase::setFilter(mask);
}

void PagedFolderListModel::restore(FolderListModelMemento *m)
{
	if (item_count != 0)
	{
		item_count = 0;
		emit countChanged();
	}

	TreeBrowserListModelBase::restore(m);
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
	discard_operations = browser->lastQueuedCommand();

	if (item_count != 0)
	{
		item_count = 0;
		emit countChanged();
	}

	TreeBrowserListModelBase::directoryChanged();

	// here we can't optimize and wait for the range to be set, because the list size
	// is received with the page list message
	startLoadingItems();
}

void PagedFolderListModel::contextChanged()
{
	// here we can't optimize and wait for the range to be set, because the list size
	// is received with the page list message
	discard_operations = browser->lastQueuedCommand();
	startLoadingItems();
}

void PagedFolderListModel::gotFileList(EntryInfoList list)
{
	if (this != activeModel)
		return;
	if (browser->lastAnsweredCommand() <= discard_operations)
		return;
	// update list size
	item_count = 0;
	if (item_count != browser->getNumElements())
	{
		item_count = browser->getNumElements();
		reset();
		emit countChanged();
	}

	// update the data in item list
	if (min_range != max_range)
	{
		foreach (const EntryInfo &entry, list)
		{
			if (current_index - start_index >= item_list.size())
				break;
			item_list[current_index - start_index]->setFileInfo(entry, getCurrentPath());
			++current_index;
		}
	}

	// if we need more entries, request them, otherwise signal completion
	if (current_index < qMin(max_range, getCount()))
	{
		browser->getFileList(current_index + 1);
	}
	else
	{
		setLoading(false);
		reset();
		emit countChanged();
	}
}

void PagedFolderListModel::changeRootDirectory()
{
	resetInternalState();
}


FolderListModelMemento::~FolderListModelMemento()
{
	delete tm;
}


DirectoryListModel::DirectoryListModel(QObject *parent) :
	FolderListModel(new DirectoryTreeBrowser, parent)
{
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
