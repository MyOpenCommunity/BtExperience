#ifndef TEST_MULTIMEDIA_PLAYER_H
#define TEST_MULTIMEDIA_PLAYER_H

#include "test_btobject.h"

class MultiMediaPlayer;
class ObjectTester;


class TestMultiMediaPlayer : public TestBtObject
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testPreconditions();
	void testSanity();

private:
	MultiMediaPlayer *player;
	ObjectTester *state_changed, *output_changed, *track_info_changed, *source_changed;
};

#endif // TEST_MULTIMEDIA_PLAYER_H
