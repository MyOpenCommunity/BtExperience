#include "ringtonemanager.h"
#include "multimediaplayer.h"
#include "audiostate.h"
#include "xml_functions.h"

#include <QFile>
#include <QDir>
#include <QtDebug>


RingtoneManager::RingtoneManager(QString ringtone_file, MultiMediaPlayer *_player, AudioState *_audio_state, QObject *parent) :
	QObject(parent)
{
	player = _player;
	audio_state = _audio_state;

	QFile fh(ringtone_file);
	QDomDocument qdom;

	QDir dirname = QFileInfo(fh).absoluteDir();
	if (qdom.setContent(&fh))
	{
		QDomNode ring_node = getChildWithName(qdom.documentElement(), "ringtones");
		foreach (const QDomNode &item_node, getChildren(ring_node, "item"))
		{
			int id_ringtone = getTextChild(item_node, "id_ringtone").toInt();
			QString filename = getTextChild(item_node, "descr");
			ringtone_to_file[static_cast<Ringtone>(id_ringtone)] =
				QFileInfo(dirname, filename).absoluteFilePath();
		}
	}
	else
		qFatal("Failed to load ringtone file %s", qPrintable(ringtone_file));
}

MultiMediaPlayer *RingtoneManager::getMediaPlayer() const
{
	return player;
}

QString RingtoneManager::ringtoneFromIndex(int index) const
{
	return ringtone_to_file.value(index, QString());
}

QString RingtoneManager::ringtoneFromType(Ringtone type) const
{
	if (!type_to_ringtone.contains(type))
		return QString();

	return ringtoneFromIndex(type_to_ringtone[type]);
}

void RingtoneManager::setRingtone(Ringtone type, int index)
{
	Q_ASSERT_X(ringtone_to_file.contains(index), "RingtonesManager::setRingtone",
		qPrintable(QString("Given ringtone %1 is outside valid range.").arg(index)));
	if (type_to_ringtone[type] == index)
		return;
	type_to_ringtone[type] = index;
	emit ringtoneChanged(type, index);
}

void RingtoneManager::playRingtone(QString path, int _state)
{
	qDebug() << "Requested ringtone" << path;

	ringtone = path;
	exit_state = true;
	state = _state;

	playRingtone();
}

void RingtoneManager::playRingtoneAndKeepState(QString path, int _state)
{
	qDebug() << "Requested ringtone" << path;

	ringtone = path;
	exit_state = false;
	state = _state;

	playRingtone();
}

void RingtoneManager::stopRingtone()
{
	if (ringtone.isEmpty())
		return;

	player->stop();
}

void RingtoneManager::playerStateChange()
{
	if (player->getPlayerState() != MultiMediaPlayer::Stopped)
		return;

	disconnect(player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
		   this, SLOT(playerStateChange()));
	if (ringtone.isEmpty())
		return;

	ringtone.clear();

	emit ringtoneFinished();

	if (exit_state)
		audio_state->disableState(static_cast<AudioState::State>(state));
}

void RingtoneManager::playRingtone()
{
	disconnect(audio_state, SIGNAL(stateChanged(AudioState::State,AudioState::State)),
		   this, SLOT(playRingtone()));
	if (ringtone.isEmpty())
		return;

	if (audio_state->getState() != state)
	{
		qWarning() << "Going from state" <<  audio_state->getState() << "to" << state;
		connect(audio_state, SIGNAL(stateChanged(AudioState::State,AudioState::State)),
			this, SLOT(playRingtone()));

		audio_state->enableState(static_cast<AudioState::State>(state));
	}
	else
	{
		qWarning() << "Already in state" << state;
		connect(player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
			this, SLOT(playerStateChange()));

		qDebug() << "Playing ringtone" << ringtone;

		player->setCurrentSource(ringtone);
		player->play();
	}
}
