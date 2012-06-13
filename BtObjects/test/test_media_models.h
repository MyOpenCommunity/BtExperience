#ifndef TEST_MEDIA_MODELS_H
#define TEST_MEDIA_MODELS_H

#include "test_btobject.h"

class MediaDataModel;
class MediaModel;
class ItemInterface;


class TestMediaModel : public TestBtObject
{
	Q_OBJECT

protected:
	void initObjects(MediaDataModel *src, MediaModel *obj, QList<ItemInterface *> items);

private slots:
	void init();
	void cleanup();

	void testInsert();
	void testRemove();
	void testRemoveFiltered();
	void testRemoveAll();
	void testRemoveAllFiltered();

	void testFilterContainer();
	void testFilterRange();

private:
	QList<ItemInterface *> items;
	MediaDataModel *src;
	MediaModel *obj;
};

#endif // TEST_MEDIA_MODELS_H
