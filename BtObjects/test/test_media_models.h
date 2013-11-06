/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef TEST_MEDIA_MODELS_H
#define TEST_MEDIA_MODELS_H

#include "test_btobject.h"

class MediaDataModel;
class MediaModel;
class ItemInterface;
class Container;
class UiiMapper;


class TestMediaModel : public TestBtObject
{
	Q_OBJECT

protected:
	void initObjects(MediaDataModel *src, MediaModel *obj, QList<ItemInterface *> items);

private slots:
	void init();
	void cleanup();

	void testInsert();
	void testRemoveNoElements();
	void testRemove();
	void testRemove2();
	void testRemove3();
	void testRemoveObject();
	void testRemoveFiltered();
	void testRemoveAll();
	void testRemoveAllWithRange();
	void testRemoveAllFiltered();

	void testFilterContainer();
	void testFilterRange();

	void testSort();

private:
	QList<ItemInterface *> items;
	MediaDataModel *src;
	MediaModel *obj;
	Container *container;
	UiiMapper *uii_map;
};

#endif // TEST_MEDIA_MODELS_H
