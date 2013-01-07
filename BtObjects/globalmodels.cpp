#include "globalmodels.h"
#include "note.h"
#include "medialink.h"
#include "objectlink.h"
#include "alarmclock.h"
#include "objectmodel.h"
#include "alarmclocknotifier.h"
#include "container.h"

#include <QDebug>


GlobalModels::GlobalModels()
{
	floors = 0;
	rooms = 0;
	object_links = 0;
	systems = 0;
	my_home_objects = 0;
	notes = 0;
	profiles = 0;
	media_links = 0;
	media_containers = 0;
	homepage_links = 0;
}

void GlobalModels::setFloors(MediaDataModel *_floors)
{
	floors = _floors;
}

MediaDataModel *GlobalModels::getFloors() const
{
	return floors;
}

void GlobalModels::setRooms(MediaDataModel *_rooms)
{
	rooms = _rooms;
}

MediaDataModel *GlobalModels::getRooms() const
{
	return rooms;
}

void GlobalModels::setSystems(MediaDataModel *_systems)
{
	systems = _systems;
}

MediaDataModel *GlobalModels::getSystems() const
{
	return systems;
}

void GlobalModels::setObjectLinks(MediaDataModel *_object_links)
{
	object_links = _object_links;
}

MediaDataModel *GlobalModels::getObjectLinks() const
{
	return object_links;
}

void GlobalModels::setMyHomeObjects(ObjectDataModel *_my_home_objects)
{
	my_home_objects = _my_home_objects;
}

ObjectDataModel *GlobalModels::getMyHomeObjects() const
{
	return my_home_objects;
}

void GlobalModels::setNotes(MediaDataModel *_notes)
{
	notes = _notes;
}

MediaDataModel *GlobalModels::getNotes() const
{
	return notes;
}

Note *GlobalModels::createNote(int profile_uii, QString text)
{
	return new Note(profile_uii, text);
}

ItemInterface *GlobalModels::createQuicklink(int uii, QString media_type, QString name,
											 QString address, ObjectInterface *bt_object,
											 int x, int y, bool is_home_link)
{
	if ((QString::compare("camera", media_type, Qt::CaseInsensitive) == 0) ||
		(QString::compare("scenario", media_type, Qt::CaseInsensitive) == 0))
	{
		ObjectLink *result = new ObjectLink(bt_object, x, y, uii);
		getMediaLinks()->prepend(result);
		return result;
	}

	// defaults to web link
	int cid = Container::IdMultimediaWebLink;
	MediaLink::MediaType t = MediaLink::Web;

	if (QString::compare("web page", media_type, Qt::CaseInsensitive) == 0)
	{
		cid = Container::IdMultimediaWebLink;
		t = MediaLink::Web;
	}

	if (QString::compare("web camera", media_type, Qt::CaseInsensitive) == 0)
	{
		cid = Container::IdMultimediaWebCam;
		t = MediaLink::Webcam;
	}

	if (QString::compare("rss", media_type, Qt::CaseInsensitive) == 0)
	{
		cid = Container::IdMultimediaRss;
		t = MediaLink::Rss;
	}

	if (QString::compare("weather", media_type, Qt::CaseInsensitive) == 0)
	{
		cid = Container::IdMultimediaRssMeteo;
		t = MediaLink::RssMeteo;
	}

	if (QString::compare("web radio", media_type, Qt::CaseInsensitive) == 0)
	{
		cid = Container::IdMultimediaWebRadio;
		t = MediaLink::WebRadio;
	}

	if (QString::compare("scenario", media_type, Qt::CaseInsensitive) == 0)
	{
		// TODO check these values
		cid = Container::IdScenarios;
		t = MediaLink::BtObject;
	}

	MediaLink *result = new MediaLink(-1, t, name, address, QPoint(x, y));

	if (is_home_link)
	{
		// home link
		result->setContainerUii(uii);
	}
	else if (uii != -1)
	{
		// profile link
		result->setContainerUii(uii);
	}
	else
	{
		// multimedia link
		MediaDataModel *containers = getMediaContainers();
		for (int i = 0; i < containers->getCount(); ++i)
		{
			ItemInterface *ii = containers->getObject(i);
			Container *c = qobject_cast<Container *>(ii);
			Q_ASSERT_X(c, __PRETTY_FUNCTION__, "Unexpected NULL object");

			if (c->getContainerId() != cid)
				continue;

			result->setContainerUii(c->getUii());
		}
	}

	getMediaLinks()->prepend(result);

	result->update();
	return result;
}

ItemInterface *GlobalModels::createAlarmClock()
{
	AlarmClock *alarmClock = new AlarmClock("new alarm clock", false, AlarmClock::AlarmClockBeep, 0, 0, 0);

	// retrieves notifier model
	ObjectModel *notifierModel = new ObjectModel(this);
	notifierModel->setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdAlarmClockNotifier);

	// retrieves notifiers and add alarm clock connections to them
	for (int i = 0; i < notifierModel->getCount(); ++i)
	{
		ItemInterface *item = notifierModel->getObject(i);
		AlarmClockNotifier *notifier = qobject_cast<AlarmClockNotifier *>(item);
		Q_ASSERT_X(notifier, __PRETTY_FUNCTION__, "Unexpected NULL object");
		notifier->addAlarmClockConnections(alarmClock);
	}

	return alarmClock;
}

void GlobalModels::setProfiles(MediaDataModel *_profiles)
{
	profiles = _profiles;
}

MediaDataModel *GlobalModels::getProfiles() const
{
	return profiles;
}

void GlobalModels::setMediaContainers(MediaDataModel *_media_containers)
{
	media_containers = _media_containers;
}

MediaDataModel *GlobalModels::getMediaContainers() const
{
	return media_containers;
}

void GlobalModels::setHomepageLinks(Container *_homepage_links)
{
	homepage_links = _homepage_links;
}

Container *GlobalModels::getHomepageLinks() const
{
	return homepage_links;
}

void GlobalModels::setMediaLinks(MediaDataModel *_media_links)
{
	media_links = _media_links;
}

MediaDataModel *GlobalModels::getMediaLinks() const
{
	return media_links;
}
