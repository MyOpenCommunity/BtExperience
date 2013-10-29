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
