#include "test_multimedia_player.h"
#include "multimediaplayer.h"
#include "objecttester.h"
#include "mediaplayer.h"

#include <QtTest>

#define TIMEOUT 2000


void TestMultiMediaPlayer::init()
{
	MediaPlayer::setCommandLineArguments("mplayer", QStringList() << "-ao" << "null", QStringList());

	player = new MultiMediaPlayer();
	state_changed = new ObjectTester(player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)));
	output_changed = new ObjectTester(player, SIGNAL(audioOutputStateChanged(MultiMediaPlayer::AudioOutputState)));
	track_info_changed = new ObjectTester(player, SIGNAL(trackInfoChanged(MultiMediaPlayer::TrackInfo)));
	source_changed = new ObjectTester(player, SIGNAL(currentSourceChanged(QString)));
}

void TestMultiMediaPlayer::cleanup()
{
	delete player;
	delete state_changed;
	delete output_changed;
	delete track_info_changed;
	delete source_changed;
}

void TestMultiMediaPlayer::testPreconditions()
{
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Stopped);
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputStopped);
	QCOMPARE(player->getCurrentSource(), QString());
	QCOMPARE(player->getTrackInfo(), MultiMediaPlayer::TrackInfo());
}

void TestMultiMediaPlayer::testSanity()
{
	player->setCurrentSource("files/audio/d3.mp3");

	source_changed->checkSignals();

	player->play();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);
	state_changed->clearSignals();

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);
	output_changed->clearSignals();

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT));
	MultiMediaPlayer::TrackInfo info = player->getTrackInfo();
	track_info_changed->clearSignals();

	QCOMPARE(info["meta_title"], QString("D3 pluck"));

	player->stop();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Stopped);
	state_changed->clearSignals();

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputStopped);
	output_changed->clearSignals();
}
