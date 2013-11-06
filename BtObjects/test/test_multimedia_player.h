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

#ifndef TEST_MULTIMEDIA_PLAYER_H
#define TEST_MULTIMEDIA_PLAYER_H

#include "test_btobject.h"

#include <QVariantList>

class MultiMediaPlayer;
class AudioVideoPlayer;
class DirectoryListModel;
class ObjectTester;


class TestMultiMediaPlayer : public TestBtObject
{
	Q_OBJECT

private slots:
	void initTestCase();
	void init();
	void cleanup();

	void testPreconditions();
	void testSanity();

	// test playback, track info updates and current playback time updates
	void testPlay();

	// test playback of multiple fiiles
	void testPlayMulti();

	// test pause/detach/resume sequences
	void testPauseResume();
	void testPauseReleaseResume();
	void testReleaseResume();
	void testMultiplePauseResume();

	// change current source
	void testSetSource();
	void testSetSourcePaused();
	void testSetEmptySource();

	// seek
	void testSeek();

	// track complete
	void testDone();

private:
	bool waitTrackInfo();
	bool waitTrackInfo(ObjectTester *tester);

	MultiMediaPlayer *player;
	ObjectTester *state_changed, *output_changed, *track_info_changed, *source_changed;
};


class TestPlaylistPlayer : public TestBtObject
{
	Q_OBJECT

private slots:
	void initTestCase();
	void init();
	void cleanup();

	void testLoopCheck();
	void testResetLoopCheck();
	void testGenerateLocal();

private:
	QVariantList buildRootPath(QString path);
	AudioVideoPlayer *player;
	DirectoryListModel *model;
};

#endif // TEST_MULTIMEDIA_PLAYER_H
