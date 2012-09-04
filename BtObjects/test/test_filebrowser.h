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

#ifndef TEST_FILEBROWSER_H
#define TEST_FILEBROWSER_H

#include "test_btobject.h"

class TreeBrowserListModelBase;
class TreeBrowser;


class TestFileObject : public TestBtObject
{
	Q_OBJECT

private slots:
	void testGetters();
};


class TestTreeBrowserListModelBase : public TestBtObject
{
	Q_OBJECT

protected:
	void initObjects(TreeBrowserListModelBase *obj, TreeBrowser *dev);
	virtual bool isAsync() const = 0;

private slots:
	void cleanup();

	void testSetFilter();
	void testSetRange();

	void testIsRoot();
	void testNavigation();
	void testListItems();
	void testRange();

protected:
	TreeBrowserListModelBase *obj;
	TreeBrowser *dev;
	int reset_counter, range_reset_counter;
};


class TestFolderListModel : public TestTreeBrowserListModelBase
{
	Q_OBJECT

protected:
	virtual bool isAsync() const { return false; }

private slots:
	void init();

	void testSetRoot();
};


class TestPagedFolderListModel : public TestTreeBrowserListModelBase
{
	Q_OBJECT

protected:
	virtual bool isAsync() const { return true; }

private slots:
	void init();
};

#endif // TEST_FILEBROWSER_H
