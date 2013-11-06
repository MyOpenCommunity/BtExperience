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
	void testMultipleFilter();

private:
	ObjectInterface *light1, *light2, *light3, *amplifier1, *amplifier2;
	DimmerDevice *dev1;
	AmplifierDevice *dev2;
	ObjectDataModel *src;
	ObjectModel *obj;
};

#endif // TEST_MYHOME_MODELS_H
