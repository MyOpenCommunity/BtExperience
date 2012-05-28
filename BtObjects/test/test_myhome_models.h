#ifndef TEST_MYHOME_MODELS_H
#define TEST_MYHOME_MODELS_H

#include "test_media_models.h"

class ObjectDataModel;
class ObjectModel;
class ObjectInterface;
class DimmerDevice;
class AmplifierDevice;


class TestObjectModel : public TestMediaModel
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testFilterObjectId();
	void testFilterObjectKey();
	void testComplexFilter();

private:
	ObjectInterface *light1, *light2, *light3, *amplifier1, *amplifier2;
	DimmerDevice *dev1;
	AmplifierDevice *dev2;
	ObjectDataModel *src;
	ObjectModel *obj;
};

#endif // TEST_MYHOME_MODELS_H
