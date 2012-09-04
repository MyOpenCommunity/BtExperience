/*
 * BTouch - Graphical User Interface to control MyHome System
 *
 * Copyright (C) 2010 BTicino S.p.A.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */


#include "test_filebrowser.h"
#include "objecttester.h"
#include "folderlistmodel.h"
#include "treebrowser.h"

#include <QtTest>

#define ASYNC_DELAY 100


class MockTreeBrowser : public TreeBrowser
{
	Q_OBJECT

public:
	virtual void setRootPath(const QStringList &_root_path)
	{
		current_path = root_path = _root_path;
	}

	virtual QStringList getRootPath()
	{
		return root_path;
	}

	virtual void enterDirectory(const QString &name)
	{
		if (name.length() != 1 || name[0] < 'a' || name[0] > 'e')
		{
			emit directoryChangeError();

			return;
		}

		current_path.append(name);
		emit directoryChanged();
	}

	virtual void exitDirectory()
	{
		if (isRoot())
			return;

		current_path.pop_back();
		emit directoryChanged();
	}

	virtual void getFileList()
	{
		EntryInfoList res;

		for (int i = 0; i < 26; ++i)
		{
			EntryInfo entry;

			if (i < 5)
				entry.type = EntryInfo::DIRECTORY;
			else if (i & 1)
				entry.type = EntryInfo::AUDIO;
			else
				entry.type = EntryInfo::VIDEO;

			entry.name = 'a' + i;
			entry.path = "/" + current_path.join("/") + "/" + entry.name;

			res.append(entry);
		}

		emit listReceived(res);
	}

	virtual bool isRoot()
	{
		return current_path.length() == root_path.length();
	}

	virtual QString pathKey()
	{
		// not used by TreeBrowserListModel
		return QString();
	}

	virtual void setContext(const QStringList &context)
	{
		// not used by TreeBrowserListModel
	}

	virtual void reset()
	{
		// not used by TreeBrowserListModel
	}

private:
	QStringList root_path;
	QStringList current_path;
};


class MockPagedTreeBrowser : public PagedTreeBrowser
{
	Q_OBJECT

public:
	virtual void setRootPath(const QStringList &_root_path)
	{
		current_path = root_path = _root_path;
	}

	virtual QStringList getRootPath()
	{
		return root_path;
	}

	virtual void enterDirectory(const QString &name)
	{
		if (name.length() != 1 || name[0] < 'a' || name[0] > 'e')
		{
			QTimer::singleShot(ASYNC_DELAY, this, SIGNAL(directoryChangeError()));

			return;
		}

		pending_directory = name;
		QTimer::singleShot(ASYNC_DELAY, this, SLOT(directoryChangeComplete()));
	}

	virtual void exitDirectory()
	{
		if (isRoot())
			return;

		pending_directory = "";
		QTimer::singleShot(ASYNC_DELAY, this, SLOT(directoryChangeComplete()));
	}

	virtual void getFileList()
	{
		range_start = 0;
		range_end = 26;

		QTimer::singleShot(ASYNC_DELAY, this, SLOT(fileListComplete()));
	}

	virtual bool isRoot()
	{
		return current_path.length() == root_path.length();
	}

	virtual QString pathKey()
	{
		// not used by TreeBrowserListModel
		return QString();
	}

	virtual void setContext(const QStringList &context)
	{
		// not used by TreeBrowserListModel
	}

	virtual void reset()
	{
		// not used by TreeBrowserListModel
	}

	// TODO implement
	virtual void getPreviousFileList()
	{
		// not used by TreeBrowserListModel
	}

	virtual void getNextFileList()
	{
		range_start = range_end;
		range_end = range_start + 4;

		QTimer::singleShot(ASYNC_DELAY, this, SLOT(fileListComplete()));
	}

	virtual int getNumElements()
	{
		return 26;
	}

	virtual int getStartingElement()
	{
		return range_start;
	}

	virtual void getFileList(int starting_element)
	{
		range_start = starting_element - 1;
		range_end = range_start + 4;

		QTimer::singleShot(ASYNC_DELAY, this, SLOT(fileListComplete()));
	}

private slots:
	void directoryChangeComplete()
	{
		if (!pending_directory.isNull())
		{
			if (pending_directory.isEmpty())
				current_path.pop_back();
			else
				current_path.append(pending_directory);
		}

		pending_directory = QString();

		emit directoryChanged();
	}

	void fileListComplete()
	{
		EntryInfoList res;

		for (int i = range_start; i < range_end; ++i)
		{
			EntryInfo entry;

			if (i < 5)
				entry.type = EntryInfo::DIRECTORY;
			else if (i & 1)
				entry.type = EntryInfo::AUDIO;
			else
				entry.type = EntryInfo::VIDEO;

			entry.name = 'a' + i;
			entry.path = "/" + current_path.join("/") + "/" + entry.name;

			res.append(entry);
		}

		emit listReceived(res);
	}

private:
	QStringList root_path;
	QStringList current_path;
	QString pending_directory;
	int range_start, range_end;
};

#include "test_filebrowser.moc"


namespace
{
	void enterDirectoryAndWait(TreeBrowserListModelBase *obj, QString dir, bool async)
	{
		QSignalSpy spy(obj, SIGNAL(loadingChanged()));

		obj->enterDirectory(dir);

		QCOMPARE(obj->isLoading(), async);
		QCOMPARE(spy.count(), async ? 1 : 0);

		while (obj->isLoading())
			qApp->processEvents();

		QCOMPARE(spy.count(), async ? 2 : 0);
	}

	void enterDirectoryAndWait(TreeBrowser *dev, QString dir, const char *signal = SIGNAL(directoryChanged()))
	{
		QSignalSpy spy(dev, signal);

		dev->enterDirectory(dir);

		while (spy.count() == 0)
			qApp->processEvents();
	}

	void exitDirectoryAndWait(TreeBrowserListModelBase *obj, bool async)
	{
		QSignalSpy spy(obj, SIGNAL(loadingChanged()));

		obj->exitDirectory();

		QCOMPARE(obj->isLoading(), async);
		QCOMPARE(spy.count(), async ? 1 : 0);

		while (obj->isLoading())
			qApp->processEvents();

		QCOMPARE(spy.count(), async ? 2 : 0);
	}

	void exitDirectoryAndWait(TreeBrowser *dev, const char *signal = SIGNAL(directoryChanged()))
	{
		QSignalSpy spy(dev, signal);

		dev->exitDirectory();

		while (spy.count() == 0)
			qApp->processEvents();
	}

	void setRangeAndWait(TreeBrowserListModelBase *obj, QVariantList range)
	{
		obj->setRange(range);

		while (obj->isLoading())
			qApp->processEvents();
	}
}


void TestTreeBrowserListModelBase::initObjects(TreeBrowserListModelBase *_obj, TreeBrowser *_dev)
{
	obj = _obj;
	dev = _dev;

	obj->setRootPath(QVariantList() << "a");
	dev->setRootPath(QStringList() << "a");

	QVERIFY(!obj->isLoading());
}

void TestTreeBrowserListModelBase::cleanup()
{
	delete obj;
	delete dev;
}

void TestTreeBrowserListModelBase::testSetFilter()
{
	ObjectTester t(obj, SIGNAL(filterChanged()));

	obj->setFilter(FileObject::Audio);

	t.checkSignals();
	QCOMPARE(obj->getFilter(), int(FileObject::Audio));

	obj->setFilter(FileObject::Audio);

	t.checkNoSignals();
}

void TestTreeBrowserListModelBase::testSetRange()
{
	ObjectTester t(obj, SIGNAL(rangeChanged()));

	obj->setRange(QVariantList() << 3 << 4);

	t.checkSignals();
	QCOMPARE(obj->getRange(), QVariantList() << 3 << 4);

	obj->setRange(QVariantList() << 3 << 4);

	t.checkNoSignals();
	QCOMPARE(obj->getRange(), QVariantList() << 3 << 4);

	obj->setRange(QVariantList() << "a" << 5);

	t.checkNoSignals();
	QCOMPARE(obj->getRange(), QVariantList() << 3 << 4);

	obj->setRange(QVariantList() << 4 << "a");

	t.checkNoSignals();
	QCOMPARE(obj->getRange(), QVariantList() << 3 << 4);

	obj->setRange(QVariantList() << "4" << "5");

	t.checkSignals();
	QCOMPARE(obj->getRange(), QVariantList() << 4 << 5);
}

void TestTreeBrowserListModelBase::testIsRoot()
{
	QVERIFY(obj->isRoot());
	QVERIFY(dev->isRoot());

	enterDirectoryAndWait(obj, "c", isAsync());
	enterDirectoryAndWait(dev, "c");

	QVERIFY(!obj->isRoot());
	QVERIFY(!dev->isRoot());

	exitDirectoryAndWait(obj, isAsync());
	exitDirectoryAndWait(dev);

	QVERIFY(obj->isRoot());
	QVERIFY(dev->isRoot());

	obj->exitDirectory();
	dev->exitDirectory();

	QCOMPARE(obj->isLoading(), false);
	QVERIFY(obj->isRoot());
	QVERIFY(dev->isRoot());
}

void TestTreeBrowserListModelBase::testNavigation()
{
	ObjectTester t(obj, SIGNAL(currentPathChanged()));

	enterDirectoryAndWait(obj, "c", isAsync());

	t.checkSignals();
	QCOMPARE(obj->getCurrentPath(), obj->getRootPath() << "c");

	enterDirectoryAndWait(obj, "b", isAsync());

	t.checkSignals();
	QCOMPARE(obj->getCurrentPath(), obj->getRootPath() << "c" << "b");

	enterDirectoryAndWait(obj, "f", isAsync());

	t.checkNoSignals();
	QCOMPARE(obj->getCurrentPath(), obj->getRootPath() << "c" << "b");

	exitDirectoryAndWait(obj, isAsync());

	t.checkSignals();
	QCOMPARE(obj->getCurrentPath(), obj->getRootPath() << "c");
}

void TestTreeBrowserListModelBase::testListItems()
{
	ObjectTester t(obj, SIGNAL(modelReset()));
	FileObject *file;

	enterDirectoryAndWait(obj, "c", isAsync());

	// here reset() is called a different number of times for sync(1) and async(2) folder model
	// (and it's correct this way) but we do not care to test it here, so we just reset the
	// signal count
	t.clearSignals();

	setRangeAndWait(obj, QVariantList() << 0 << 8);

	t.checkSignalCount(SIGNAL(modelReset()), reset_counter);
	t.clearSignals();

	QCOMPARE(obj->getCount(), 26);
	QCOMPARE(obj->rowCount(), 8);

	file = qobject_cast<FileObject *>(obj->getObject(6));
	while (file->isLoading())
		qApp->processEvents();

	QCOMPARE(qobject_cast<FileObject *>(obj->getObject(6))->getLogicalPath(),
		 obj->getRootPath() << "c" << "g");

	enterDirectoryAndWait(obj, "b", isAsync());

	t.checkSignalCount(SIGNAL(modelReset()), reset_counter);
	QCOMPARE(obj->getCount(), 26);
	QCOMPARE(obj->rowCount(), 8);

	file = qobject_cast<FileObject *>(obj->getObject(6));
	while (file->isLoading())
		qApp->processEvents();

	QCOMPARE(qobject_cast<FileObject *>(obj->getObject(6))->getLogicalPath(),
		 obj->getRootPath() << "c" << "b" << "g");
}

void TestTreeBrowserListModelBase::testRange()
{
	ObjectTester t(obj, SIGNAL(modelReset()));

	enterDirectoryAndWait(obj, "c", isAsync());

	// see comment in TestTreeBrowserListModelBase::testListItems
	t.clearSignals();

	setRangeAndWait(obj, QVariantList() << 4 << 8);

	t.checkSignalCount(SIGNAL(modelReset()), range_reset_counter);
	t.clearSignals();

	QCOMPARE(obj->getCount(), 26);
	QCOMPARE(obj->rowCount(), 4);
	QCOMPARE(qobject_cast<FileObject *>(obj->getObject(0))->getLogicalPath(),
		obj->getRootPath() << "c" << "e");

	setRangeAndWait(obj, QVariantList() << 8 << 12);

	t.checkSignalCount(SIGNAL(modelReset()), range_reset_counter);
	t.clearSignals();

	QCOMPARE(obj->getCount(), 26);
	QCOMPARE(obj->rowCount(), 4);
	QCOMPARE(qobject_cast<FileObject *>(obj->getObject(0))->getLogicalPath(),
		 obj->getRootPath() << "c" << "i");

	setRangeAndWait(obj, QVariantList() << 24 << 28);

	t.checkSignalCount(SIGNAL(modelReset()), range_reset_counter);
	t.clearSignals();

	QCOMPARE(obj->getCount(), 26);
	QCOMPARE(obj->rowCount(), 2);
	QCOMPARE(qobject_cast<FileObject *>(obj->getObject(0))->getLogicalPath(),
		 obj->getRootPath() << "c" << "y");
}


void TestFolderListModel::init()
{
	TreeBrowser *browser = new MockTreeBrowser();

	initObjects(new FolderListModel(browser), new MockTreeBrowser);
	range_reset_counter = reset_counter = 1;
}

void TestFolderListModel::testSetRoot()
{
	ObjectTester t(obj, SIGNAL(rootPathChanged()));

	obj->setRootPath(QVariantList() << "q");

	t.checkSignals();
	QCOMPARE(obj->getRootPath(), QVariantList() << "q");

	obj->setRootPath(QVariantList() << "q");

	t.checkNoSignals();
}


void TestPagedFolderListModel::init()
{
	PagedTreeBrowser *browser = new MockPagedTreeBrowser();

	initObjects(new PagedFolderListModel(browser), new MockPagedTreeBrowser);
	reset_counter = 4;
	range_reset_counter = 3;
}


void TestFileObject::testGetters()
{
	EntryInfo entry("name", EntryInfo::AUDIO, "/path/to/name");
	FileObject fo(entry, QVariantList() << "path" << "to");

	QCOMPARE(fo.isLoading(), false);
	QCOMPARE(fo.getName(), QString("name"));
	QCOMPARE(fo.getLogicalPath(), QVariantList() << "path" << "to" << "name");
	QCOMPARE(fo.getFileType(), FileObject::Audio);
}
