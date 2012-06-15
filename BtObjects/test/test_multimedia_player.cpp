#include "test_multimedia_player.h"
#include "multimediaplayer.h"
#include "objecttester.h"
#include "mediaplayer.h"

#include <QtTest>

#define TIMEOUT 2000

namespace
{
	QVariantMap d3_info, f5_info, a4_info;

	bool compareInfo(QVariantMap got, QVariantMap expected)
	{
		foreach (QString key, expected.keys())
		{
			if (got.value(key) != expected.value(key))
			{
				qWarning() << "Key" << key << "got" << got[key].toString() << "expected" << expected[key].toString();

				return false;
			}
		}

		return true;
	}
}

void TestMultiMediaPlayer::init()
{
	MediaPlayer::setCommandLineArguments("mplayer", QStringList() << "-ao" << "null", QStringList());

	player = new MultiMediaPlayer();
	player->mediaplayer_output_mode = MediaPlayer::OutputStdout;
	state_changed = new ObjectTester(player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)));
	output_changed = new ObjectTester(player, SIGNAL(audioOutputStateChanged(MultiMediaPlayer::AudioOutputState)));
	track_info_changed = new ObjectTester(player, SIGNAL(trackInfoChanged(QVariantMap)));
	source_changed = new ObjectTester(player, SIGNAL(currentSourceChanged(QString)));

	d3_info["meta_title"] = "D3 pluck";
	d3_info["file_name"] = "d3.mp3";
	d3_info["meta_album"] = "BTicino tests";
	d3_info["meta_artist"] = "Sox";
	d3_info["total_time"] = QTime(0, 0, 14);

	f5_info["meta_title"] = "F5 pluck";
	f5_info["file_name"] = "f5.mp3";
	f5_info["meta_album"] = "BTicino tests";
	f5_info["meta_artist"] = "Sox";
	f5_info["total_time"] = QTime(0, 0, 21);

	a4_info["meta_title"] = "A4 pluck";
	a4_info["file_name"] = "a4.mp3";
	a4_info["meta_album"] = "BTicino tests";
	a4_info["meta_artist"] = "Sox";
	a4_info["total_time"] = QTime(0, 0, 20);
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
	QCOMPARE(player->getTrackInfo(), QVariantMap());
}

void TestMultiMediaPlayer::testSanity()
{
	player->setCurrentSource("files/audio/d3.mp3");

	source_changed->checkSignals();
	track_info_changed->checkSignals();

	player->play();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT));
	QVariantMap info = player->getTrackInfo();

	QCOMPARE(info["meta_title"], QVariant("D3 pluck"));

	player->stop();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Stopped);

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputStopped);
}

void TestMultiMediaPlayer::testPlay()
{
	QVariantMap info;
	QVariant last_time;

	player->setCurrentSource("files/audio/d3.mp3");

	source_changed->checkSignals();
	track_info_changed->checkSignals();

	player->play();

	// wait for first track info update
	QVERIFY(track_info_changed->waitForSignal(TIMEOUT));
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, d3_info));
	last_time = info["current_time"];

	// wait for next track info update and check current time has changed
	QVERIFY(track_info_changed->waitForSignal(TIMEOUT));
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, d3_info));
	QVERIFY(last_time != info["current_time"]);
}

void TestMultiMediaPlayer::testPauseResume()
{
	player->setCurrentSource("files/audio/d3.mp3");

	source_changed->checkSignals();
	track_info_changed->checkSignals();

	player->play();

	// wait for first status update
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);

	QVERIFY(player->info_poll_timer->isActive());

	// pause() changes status and sends pause command to mplayer
	player->pause();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::AboutToPause);

	QVERIFY(player->info_poll_timer->isActive());

	// wait for mplayer to actually pause
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputStopped);

	QVERIFY(!player->info_poll_timer->isActive());

	// calling pause() again is a no-op
	player->pause();

	QVERIFY(!state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QVERIFY(!player->info_poll_timer->isActive());

	// resume() changes status and sends resume command to mplayer
	player->resume();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);

	QVERIFY(player->info_poll_timer->isActive());

	// calling resume() again is a no-op
	player->resume();

	QVERIFY(!state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(player->info_poll_timer->isActive());
}

void TestMultiMediaPlayer::testMultiplePauseResume()
{
	player->setCurrentSource("files/audio/d3.mp3");

	source_changed->checkSignals();
	track_info_changed->checkSignals();

	player->play();

	// wait for first status update
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(player->info_poll_timer->isActive());

	// test that multiple pause() are ignored
	player->pause();
	player->pause();
	player->pause();
	player->pause();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::AboutToPause);

	// wait for mplayer to actually pause
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QVERIFY(!player->info_poll_timer->isActive());

	// test that multiple resume() are ignored
	player->resume();
	player->resume();
	player->resume();
	player->resume();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(player->info_poll_timer->isActive());

	// test a semi-random sequence ending with pause()
	player->pause();
	player->pause();
	player->resume();
	player->resume();
	player->pause();
	player->resume();
	player->pause();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::AboutToPause);

	// wait for mplayer to actually pause
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QVERIFY(!player->info_poll_timer->isActive());

	// test a semi-random sequence ending with resume()
	player->resume();
	player->resume();
	player->pause();
	player->resume();
	player->resume();
	player->pause();
	player->resume();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(player->info_poll_timer->isActive());
}

void TestMultiMediaPlayer::testSetSource()
{
	QVariantMap info;
	QVariant last_time;

	player->setCurrentSource("files/audio/d3.mp3");

	source_changed->checkSignals();
	track_info_changed->checkSignals();

	player->play();

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT)); // track info cleared

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	// set new source (starts playing automatically)
	player->setCurrentSource("files/audio/f5.mp3");

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT)); // track info cleared
	QVERIFY(track_info_changed->waitForSignal(TIMEOUT));
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, f5_info));
	last_time = info["current_time"];

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT));
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, f5_info));
	QVERIFY(last_time != info["current_time"]);

	// set new source (starts playing automatically)
	player->setCurrentSource("files/audio/a4.mp3");

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT)); // track info cleared
	QVERIFY(track_info_changed->waitForSignal(TIMEOUT));
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, a4_info));
	last_time = info["current_time"];

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT));
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, a4_info));
	QVERIFY(last_time != info["current_time"]);
}

void TestMultiMediaPlayer::testSetSourcePaused()
{
	QVariantMap info;
	QVariant last_time;

	player->setCurrentSource("files/audio/d3.mp3");

	source_changed->checkSignals();
	track_info_changed->checkSignals();

	player->play();

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT)); // track info cleared

	player->pause();

	QVERIFY(state_changed->waitForSignal(TIMEOUT)); // AboutToPause
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	// set new source and wait for update, player is still paused
	player->setCurrentSource("files/audio/f5.mp3");

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT)); // track info cleared
	QVERIFY(track_info_changed->waitForSignal(TIMEOUT));
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, f5_info));
	QCOMPARE(info["current_time"], QVariant(QTime(0, 0, 0)));

	QVERIFY(!state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	// set new source and wait for update, player is still paused
	player->setCurrentSource("files/audio/a4.mp3");

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT)); // track info cleared
	QVERIFY(track_info_changed->waitForSignal(TIMEOUT));
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, a4_info));
	QCOMPARE(info["current_time"], QVariant(QTime(0, 0, 0)));
	last_time = info["current_time"];

	QVERIFY(!state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	// resume player and check it's actually playing
	player->resume();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	// this resume() restarts MPlayer, and is consistently slower than other tests
	QVERIFY(track_info_changed->waitForSignal(TIMEOUT * 2));
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, a4_info));
	last_time = info["current_time"];

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT));
	info = player->getTrackInfo();
	QVERIFY(last_time != info["current_time"]);
}

void TestMultiMediaPlayer::testSetEmptySource()
{
	player->setCurrentSource("files/audio/d3.mp3");

	source_changed->checkSignals();
	track_info_changed->checkSignals();

	player->play();

	QVERIFY(track_info_changed->waitForSignal(TIMEOUT)); // track info cleared

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	// set empty source: stops player
	player->setCurrentSource("");

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Stopped);

	// restart playback
	player->setCurrentSource("files/audio/d3.mp3");

	player->play();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	player->pause();

	QVERIFY(state_changed->waitForSignal(TIMEOUT)); // AboutToPause
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	player->setCurrentSource("");

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Stopped);
}
