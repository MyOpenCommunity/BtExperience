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
	exit_state = false;

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

QString RingtoneManager::descriptionFromType(Ringtone type) const
{
	return type_to_description[type];
}

void RingtoneManager::setRingtone(Ringtone type, int index, QString description)
{
	Q_ASSERT_X(ringtone_to_file.contains(index), __PRETTY_FUNCTION__,
		qPrintable(QString("Given ringtone %1 is outside valid range.").arg(index)));
	if (type_to_ringtone[type] == index)
		return;
	type_to_ringtone[type] = index;
	type_to_description[type] = description;
	emit ringtoneChanged(type, index, description);
}

void RingtoneManager::setRingtoneFromFilename(Ringtone type, QString ringtone)
{
	type_to_ringtone[type] = ringtone_to_file.key(ringtone);
	emit ringtoneChanged(type, type_to_ringtone[type], descriptionFromType(type));
}

QStringList RingtoneManager::ringtoneList() const
{
	QStringList result;

	QHashIterator<int, QString> it(ringtone_to_file);
	while (it.hasNext())
	{
		it.next();
		result << it.value();
	}

	return result;
}

void RingtoneManager::playRingtone(QString path, int _state)
{
	qDebug() << "Requested ringtone" << path;
	exitStateIfNeeded();

	ringtone = path;
	exit_state = true;
	state = _state;

	playRingtone();
}

void RingtoneManager::playRingtoneAndKeepState(QString path, int _state)
{
	qDebug() << "Requested ringtone" << path;
	exitStateIfNeeded();

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
	exitStateIfNeeded();
}

void RingtoneManager::exitStateIfNeeded()
{
	if (exit_state)
	{
		exit_state = false;
		audio_state->disableState(static_cast<AudioState::State>(state));
	}
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
