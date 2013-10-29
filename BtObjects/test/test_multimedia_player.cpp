#include "test_multimedia_player.h"
#include "multimediaplayer.h"
#include "objecttester.h"
#include "mediaplayer.h"
#include "playlistplayer.h"
#include "folderlistmodel.h"

#include <QtTest>
#include <gst/gst.h>

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
	MultiMediaPlayer::setGlobalCommandLineArguments("mplayer", QStringList() << "-ao" << "null", QStringList());

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
	d3_info["total_time"] = QTime(0, 0, 20);

	f5_info["meta_title"] = "F5 pluck";
	f5_info["file_name"] = "f5.mp3";
	f5_info["meta_album"] = "BTicino tests";
	f5_info["meta_artist"] = "Sox";
	f5_info["total_time"] = QTime(0, 0, 20);

	a4_info["meta_title"] = "A4 pluck";
	a4_info["file_name"] = "a4.mp3";
	a4_info["meta_album"] = "BTicino tests";
	a4_info["meta_artist"] = "Sox";
	a4_info["total_time"] = QTime(0, 0, 22);
}

void TestMultiMediaPlayer::cleanup()
{
	delete player;
	delete state_changed;
	delete output_changed;
	delete track_info_changed;
	delete source_changed;
}

bool TestMultiMediaPlayer::waitTrackInfo()
{
	return waitTrackInfo(track_info_changed);
}

bool TestMultiMediaPlayer::waitTrackInfo(ObjectTester *tester)
{
	QTime time;
	bool received = false;

	time.start();
	while (time.elapsed() < TIMEOUT)
	{
		if (tester->waitForSignal(TIMEOUT))
			received = true;
	}

	return received;
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
	track_info_changed->checkNoSignals();

	player->play();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);

	QVERIFY(waitTrackInfo());
	QVariantMap info = player->getTrackInfo();

	QCOMPARE(info["meta_title"], QVariant("D3 pluck"));
	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	player->stop();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Stopped);

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputStopped);

	QCOMPARE(QString(), player->getCurrentSource());
}

void TestMultiMediaPlayer::testPlay()
{
	QVariantMap info;
	QVariant last_time;

	player->setCurrentSource("files/audio/d3.mp3");

	player->play();

	// wait for first track info update
	QVERIFY(waitTrackInfo());
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, d3_info));
	last_time = info["current_time"];

	// wait for next track info update and check current time has changed
	QVERIFY(waitTrackInfo());
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, d3_info));
	QVERIFY(last_time != info["current_time"]);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());
}

void TestMultiMediaPlayer::testPlayMulti()
{
	MultiMediaPlayer player1;
	MultiMediaPlayer player2;

	ObjectTester ti1(&player1, SIGNAL(trackInfoChanged(QVariantMap)));
	ObjectTester ti2(&player2, SIGNAL(trackInfoChanged(QVariantMap)));

	QVariantMap info1, info2;
	QVariant last_time1, last_time2;

	player1.mediaplayer_output_mode = MediaPlayer::OutputStdout;
	player2.mediaplayer_output_mode = MediaPlayer::OutputStdout;

	player1.setCurrentSource("files/audio/d3.mp3");
	player2.setCurrentSource("files/audio/f5.mp3");

	player1.play();
	player2.play();

	// wait for first track info update
	QVERIFY(waitTrackInfo(&ti1));
	QVERIFY(waitTrackInfo(&ti2));

	info1 = player1.getTrackInfo();
	QVERIFY(compareInfo(info1, d3_info));
	last_time1 = info1["current_time"];

	info2 = player2.getTrackInfo();
	QVERIFY(compareInfo(info2, f5_info));
	last_time2 = info2["current_time"];

	// wait for next track info update and check current time has changed
	QVERIFY(waitTrackInfo(&ti1));
	info1 = player1.getTrackInfo();

	QVERIFY(waitTrackInfo(&ti2));
	info2 = player2.getTrackInfo();

	QVERIFY(compareInfo(info1, d3_info));
	QVERIFY(last_time1 != info1["current_time"]);

	QVERIFY(compareInfo(info2, f5_info));
	QVERIFY(last_time2 != info2["current_time"]);
}

void TestMultiMediaPlayer::testPauseResume()
{
	player->setCurrentSource("files/audio/d3.mp3");
	player->play();

	// wait for first status update
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	// pause() changes status and sends pause command to mplayer
	player->pause();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::AboutToPause);

	// wait for mplayer to actually pause
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QVERIFY(!output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	// calling pause() again is a no-op
	player->pause();

	QVERIFY(!state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	// resume() changes status and sends resume command to mplayer
	player->resume();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(!output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	// calling resume() again is a no-op
	player->resume();

	QVERIFY(!state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());
}

void TestMultiMediaPlayer::testPauseReleaseResume()
{
	player->setCurrentSource("files/audio/d3.mp3");
	player->play();

	// wait for first status update
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);

	// pause() changes status and sends pause command to mplayer
	player->pause();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::AboutToPause);

	// wait for mplayer to actually pause
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QVERIFY(!output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);
	QVERIFY(player->player->isInstanceRunning());

	// calling releaseOutputDevices() stops player and changes audio output, but state is still Paused
	player->releaseOutputDevices();

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputStopped);
	QVERIFY(!player->player->isInstanceRunning());

	// resume() changes status and restarts mplayer
	player->resume();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);
	QVERIFY(player->player->isInstanceRunning());

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);
}

void TestMultiMediaPlayer::testReleaseResume()
{
	player->setCurrentSource("files/audio/d3.mp3");
	player->play();

	// wait for first status update
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);

	// calling releaseOutputDevices() stops player and changes audio output, but state is still Paused
	player->releaseOutputDevices();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputStopped);
	QVERIFY(!player->player->isInstanceRunning());

	// resume() changes status and restarts mplayer
	player->resume();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);
	QVERIFY(player->player->isInstanceRunning());

	QVERIFY(output_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getAudioOutputState(), MultiMediaPlayer::AudioOutputActive);
}

void TestMultiMediaPlayer::testMultiplePauseResume()
{
	player->setCurrentSource("files/audio/d3.mp3");
	player->play();

	// wait for first status update
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

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

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	// test that multiple resume() are ignored
	player->resume();
	player->resume();
	player->resume();
	player->resume();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

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

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

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

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());
}

void TestMultiMediaPlayer::testSetSource()
{
	QVariantMap info;
	QVariant last_time;

	player->setCurrentSource("files/audio/d3.mp3");
	player->play();

	QVERIFY(waitTrackInfo()); // track info cleared

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	// set new source (starts playing automatically)
	player->setCurrentSource("files/audio/f5.mp3");

	QVERIFY(waitTrackInfo());
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, f5_info));
	last_time = info["current_time"];

	QVERIFY(!state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(waitTrackInfo());
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, f5_info));
	QVERIFY(last_time != info["current_time"]);

	QCOMPARE(QString("files/audio/f5.mp3"), player->getCurrentSource());

	// set new source (starts playing automatically)
	player->setCurrentSource("files/audio/a4.mp3");

	QVERIFY(waitTrackInfo());
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, a4_info));
	last_time = info["current_time"];

	QVERIFY(!state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(waitTrackInfo());
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, a4_info));
	QVERIFY(last_time != info["current_time"]);

	QCOMPARE(QString("files/audio/a4.mp3"), player->getCurrentSource());
}

void TestMultiMediaPlayer::testSetSourcePaused()
{
	QVariantMap info;
	QVariant last_time;

	player->setCurrentSource("files/audio/d3.mp3");
	player->play();

	QVERIFY(waitTrackInfo()); // track info cleared

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	player->pause();

	QVERIFY(state_changed->waitForSignal(TIMEOUT)); // AboutToPause
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	// set new source and wait for update, player is still paused
	player->setCurrentSource("files/audio/f5.mp3");

	QVERIFY(waitTrackInfo());
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, f5_info));
	QCOMPARE(info["current_time"], QVariant(QTime(0, 0, 0)));

	QVERIFY(!state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QCOMPARE(QString("files/audio/f5.mp3"), player->getCurrentSource());

	// set new source and wait for update, player is still paused
	player->setCurrentSource("files/audio/a4.mp3");

	QVERIFY(waitTrackInfo());
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, a4_info));
	QCOMPARE(info["current_time"], QVariant(QTime(0, 0, 0)));
	last_time = info["current_time"];

	QVERIFY(!state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QCOMPARE(QString("files/audio/a4.mp3"), player->getCurrentSource());

	// resume player and check it's actually playing
	player->resume();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	// this resume() restarts MPlayer, and is consistently slower than other tests
	QVERIFY(track_info_changed->waitForSignal(TIMEOUT * 2));
	info = player->getTrackInfo();

	QVERIFY(compareInfo(info, a4_info));
	last_time = info["current_time"];

	QVERIFY(waitTrackInfo());
	info = player->getTrackInfo();
	QVERIFY(last_time != info["current_time"]);

	QCOMPARE(QString("files/audio/a4.mp3"), player->getCurrentSource());
}

void TestMultiMediaPlayer::testSetEmptySource()
{
	player->setCurrentSource("files/audio/d3.mp3");
	player->play();

	QVERIFY(waitTrackInfo()); // track info cleared

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	// set empty source: stops player
	player->setCurrentSource("");

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Stopped);

	QCOMPARE(QString(), player->getCurrentSource());

	// restart playback
	player->setCurrentSource("files/audio/d3.mp3");
	player->play();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	player->pause();

	QVERIFY(state_changed->waitForSignal(TIMEOUT)); // AboutToPause
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	player->setCurrentSource("");

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Stopped);

	QCOMPARE(QString(), player->getCurrentSource());

	player->play();

	QVERIFY(!state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Stopped);

	QCOMPARE(QString(), player->getCurrentSource());
}

void TestMultiMediaPlayer::testSeek()
{
	QVariantMap info;
	QVariant last_time;
	int delta;

	player->setCurrentSource("files/audio/d3.mp3");
	player->play();

	QVERIFY(state_changed->waitForSignal(TIMEOUT)); // Playing

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	player->pause();

	QVERIFY(state_changed->waitForSignal(TIMEOUT)); // AboutToPause
	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Paused);

	QVERIFY(waitTrackInfo());
	info = player->getTrackInfo();
	last_time = info["current_time"];

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	// seek and check time delta
	player->seek(2);

	QVERIFY(waitTrackInfo());
	info = player->getTrackInfo();

	// since this is an MP3 with constant bit rate, the seek should be more-or-less correct,
	// tolerate at most 1 second error
	delta = info["current_time"].toTime().second() - last_time.toTime().second();
	QVERIFY(delta >= 1 && delta <= 3);
	last_time = info["current_time"];

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	// multiple seeks
	player->seek(3);
	player->seek(2);
	player->seek(1);

	// wait until we receive all updates
	while(waitTrackInfo()) /* do nothing */;
	info = player->getTrackInfo();

	delta = info["current_time"].toTime().second() - last_time.toTime().second();
	QVERIFY(delta >= 5 && delta <= 7);

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());
}

void TestMultiMediaPlayer::testDone()
{
	player->setCurrentSource("files/audio/d3.mp3");
	player->play();

	QVERIFY(state_changed->waitForSignal(TIMEOUT)); // Playing

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	player->pause();

	QVERIFY(state_changed->waitForSignal(TIMEOUT)); // AboutToPause
	QVERIFY(state_changed->waitForSignal(TIMEOUT));

	QCOMPARE(QString("files/audio/d3.mp3"), player->getCurrentSource());

	// seek past the end and resume
	player->seek(30);
	player->resume();

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Playing);

	QVERIFY(state_changed->waitForSignal(TIMEOUT));
	QCOMPARE(player->getPlayerState(), MultiMediaPlayer::Stopped);

	QCOMPARE(player->getCurrentSource(), QString(""));
	QCOMPARE(player->getTrackInfo(), QVariantMap());
}

void TestMultiMediaPlayer::initTestCase()
{
	gst_init_check(NULL, NULL, NULL);
}


void TestPlaylistPlayer::init()
{
	MultiMediaPlayer::setGlobalCommandLineArguments("mplayer", QStringList() << "-ao" << "null", QStringList());

	player = new AudioVideoPlayer(this);
	static_cast<MultiMediaPlayer*>(player->getMediaPlayer())->mediaplayer_output_mode = MediaPlayer::OutputStdout;
	model = new DirectoryListModel(this);
}

void TestPlaylistPlayer::cleanup()
{
	delete player;
	delete model;
}

void TestPlaylistPlayer::testLoopCheck()
{
	model->setRootPath(buildRootPath("files/audio/broken"));
	ObjectTester next(player->getMediaPlayer(), SIGNAL(currentSourceChanged(QString)));
	ObjectTester loop(player, SIGNAL(loopDetected()));

	player->generatePlaylistLocal(model, 3, model->getCount(), false);

	QVERIFY(player->isPlaying());
	QVERIFY(next.waitForSignal(TIMEOUT));
	loop.checkNoSignals();

	for (int i = 0; i < model->getCount(); ++i)
	{
		QVERIFY(player->isPlaying());
		loop.checkNoSignals();
		QVERIFY(next.waitForSignal(TIMEOUT));
	}

	QVERIFY(!player->isPlaying());
	loop.checkSignals();
}

void TestPlaylistPlayer::testResetLoopCheck()
{
	model->setRootPath(buildRootPath("files/audio/broken"));
	player->loop_starting_file = 3;

	player->terminate();
	QCOMPARE(player->loop_starting_file, -1);

	player->loop_starting_file = 3;
	player->generatePlaylistLocal(model, 0, model->getCount(), false);
	QCOMPARE(player->loop_starting_file, -1);

	player->generatePlaylistLocal(model, 4, model->getCount(), false);
	player->nextTrack();
	QCOMPARE(player->loop_starting_file, 4);
}

void TestPlaylistPlayer::testGenerateLocal()
{
	model->setRootPath(buildRootPath("files/media_content"));
	player->generatePlaylistLocal(model, 0, model->getCount(), false);

	QStringList check = QStringList() << "f5.mp3" << "f6.mp3";
	QCOMPARE(player->local_list->totalFiles(), check.size());
	for (int i = 0; i < player->local_list->totalFiles(); ++i)
	{
		QString full_path = player->local_list->currentFilePath();
		QCOMPARE(full_path.split("/", QString::SkipEmptyParts).last(), check.at(i));
		player->local_list->nextFile();
	}
}

QVariantList TestPlaylistPlayer::buildRootPath(QString path)
{
	QVariantList root;

	foreach (QString part, QDir::currentPath().split("/", QString::SkipEmptyParts))
		root << part;
	foreach (const QString &part, path.split("/", QString::SkipEmptyParts))
		root << part;
	return root;
}

void TestPlaylistPlayer::initTestCase()
{
	gst_init_check(NULL, NULL, NULL);
}
