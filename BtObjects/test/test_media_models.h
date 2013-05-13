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
