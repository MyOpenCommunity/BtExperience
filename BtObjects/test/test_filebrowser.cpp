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

#include "test_filebrowser.moc"

namespace
{
	void enterDirectoryAndWait(TreeBrowserListModelBase *obj, QString dir)
	{
		obj->enterDirectory(dir);

		while (obj->isLoading())
			qApp->processEvents();
	}

	void enterDirectoryAndWait(TreeBrowser *dev, QString dir, const char *signal = SIGNAL(directoryChanged()))
	{
		QSignalSpy spy(dev, signal);

		dev->enterDirectory(dir);

		while (spy.count() == 0)
			qApp->processEvents();
	}

	void exitDirectoryAndWait(TreeBrowserListModelBase *obj)
	{
		obj->exitDirectory();

		while (obj->isLoading())
			qApp->processEvents();
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
}

void TestTreeBrowserListModelBase::cleanup()
{
	delete obj;
	delete dev;
}

void TestTreeBrowserListModelBase::testSetRoot()
{
	ObjectTester t(obj, SIGNAL(rootPathChanged()));

	obj->setRootPath(QVariantList() << "q");

	t.checkSignals();
	QCOMPARE(obj->getRootPath(), QVariantList() << "q");

	obj->setRootPath(QVariantList() << "q");

	t.checkNoSignals();
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

	enterDirectoryAndWait(obj, "c");
	enterDirectoryAndWait(dev, "c");

	QVERIFY(!obj->isRoot());
	QVERIFY(!dev->isRoot());

	exitDirectoryAndWait(obj);
	exitDirectoryAndWait(dev);

	QVERIFY(obj->isRoot());
	QVERIFY(dev->isRoot());

	obj->exitDirectory();
	dev->exitDirectory();

	QVERIFY(obj->isRoot());
	QVERIFY(dev->isRoot());
}

void TestTreeBrowserListModelBase::testNavigation()
{
	ObjectTester t(obj, SIGNAL(currentPathChanged()));

	enterDirectoryAndWait(obj, "c");

	t.checkSignals();
	QCOMPARE(obj->getCurrentPath(), QVariantList() << "a" << "c");

	enterDirectoryAndWait(obj, "b");

	t.checkSignals();
	QCOMPARE(obj->getCurrentPath(), QVariantList() << "a" << "c" << "b");

	enterDirectoryAndWait(obj, "f");

	t.checkNoSignals();
	QCOMPARE(obj->getCurrentPath(), QVariantList() << "a" << "c" << "b");

	exitDirectoryAndWait(obj);

	t.checkSignals();
	QCOMPARE(obj->getCurrentPath(), QVariantList() << "a" << "c");
}

void TestTreeBrowserListModelBase::testListItems()
{
	ObjectTester t(obj, SIGNAL(rowsInserted(QModelIndex,int,int)));

	enterDirectoryAndWait(obj, "c");

	t.checkSignals();
	QCOMPARE(obj->getSize(), 26);
	QCOMPARE(obj->rowCount(), 26);
	QCOMPARE(qobject_cast<FileObject *>(obj->getObject(6))->getPath(), QString("/a/c/g"));

	enterDirectoryAndWait(obj, "b");

	t.checkSignals();
	QCOMPARE(obj->getSize(), 26);
	QCOMPARE(obj->rowCount(), 26);
	QCOMPARE(qobject_cast<FileObject *>(obj->getObject(6))->getPath(), QString("/a/c/b/g"));
}

void TestTreeBrowserListModelBase::testRange()
{
	ObjectTester t(obj, SIGNAL(rowsInserted(QModelIndex,int,int)));

	enterDirectoryAndWait(obj, "c");
	setRangeAndWait(obj, QVariantList() << 4 << 8);

	QCOMPARE(obj->getSize(), 26);
	QCOMPARE(obj->rowCount(), 4);
	QCOMPARE(qobject_cast<FileObject *>(obj->getObject(0))->getPath(), QString("/a/c/e"));

	setRangeAndWait(obj, QVariantList() << 8 << 12);

	QCOMPARE(obj->getSize(), 26);
	QCOMPARE(obj->rowCount(), 4);
	QCOMPARE(qobject_cast<FileObject *>(obj->getObject(0))->getPath(), QString("/a/c/i"));

	setRangeAndWait(obj, QVariantList() << 24 << 28);

	QCOMPARE(obj->getSize(), 26);
	QCOMPARE(obj->rowCount(), 2);
	QCOMPARE(qobject_cast<FileObject *>(obj->getObject(0))->getPath(), QString("/a/c/y"));
}


void TestFolderListModel::init()
{
	TreeBrowser *browser = new MockTreeBrowser();

	initObjects(new FolderListModel(browser), new MockTreeBrowser);
}


void TestFileObject::testGetters()
{
	EntryInfo entry("name", EntryInfo::AUDIO, "/path/to/name");
	FileObject fo(entry);

	QCOMPARE(fo.isLoading(), false);
	QCOMPARE(fo.getName(), QString("name"));
	QCOMPARE(fo.getPath(), QString("/path/to/name"));
	QCOMPARE(fo.getFileType(), FileObject::Audio);
}
