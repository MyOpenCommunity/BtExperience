#include "mounts.h"

#include <QFileSystemWatcher>
#include <QSet>
#include <QTextStream>
#include <QProcess>
#include <QFile>
#include <QDir>
#include <QtDebug>


// when /etc/udev/scripts/mount.sh mounts a new device under /media/NAME, it creates
// a file named /tmp/.automount-NAME; the code below does not check the files in /tmp,
// but uses the /tmp directory change to trigger a reparse of /proc/mounts

#define MTAB         "/etc/mtab"
#define MOUNTS       "/proc/mounts"
#define AUTOMOUNT    "/tmp/.automount-"
#define MOUNT_PATH   "/media"

MountWatcher *MountWatcher::mount_watcher = 0;


BrowsePoint::BrowsePoint(MountType _type)
{
	type = _type;
}

BrowsePoint::MountType BrowsePoint::getType() const
{
	return type;
}


MountPoint::MountPoint(MountType type) :
	BrowsePoint(type)
{
	mounted = false;

	MountWatcher *mount_watcher = MountWatcher::instance();

	connect(mount_watcher, SIGNAL(directoryMounted(QString,MountPoint::MountType)),
		this, SLOT(directoryMounted(QString,MountPoint::MountType)));
	connect(mount_watcher, SIGNAL(directoryUnmounted(QString,MountPoint::MountType)),
		this, SLOT(directoryUnmounted(QString,MountPoint::MountType)));
}

void MountPoint::setPath(QString _path)
{
	if (path == _path)
		return;
	path = _path;
	emit pathChanged();
}

QString MountPoint::getPath() const
{
	return path;
}

void MountPoint::setLogicalPath(QVariantList _path)
{
	if (logical_path == _path)
		return;
	logical_path = _path;
	emit logicalPathChanged();
}

QVariantList MountPoint::getLogicalPath() const
{
	return logical_path;
}

void MountPoint::setMounted(bool _mounted)
{
	if (mounted == _mounted)
		return;
	mounted = _mounted;
	emit mountedChanged();
}

bool MountPoint::getMounted() const
{
	return mounted;
}

void MountPoint::unmount()
{
	if (!mounted)
		return;

	MountWatcher::instance()->unmount(path);
}

void MountPoint::directoryMounted(const QString &dir, MountPoint::MountType mount_type)
{
	if (getType() != mount_type)
		return;
	if (mounted)
		return;

	if (dir != path)
	{
		QStringList parts = dir.split("/", QString::SkipEmptyParts);

		logical_path.clear();
		foreach (QString part, parts)
			logical_path.append(part);
		path = dir;

		emit pathChanged();
		emit logicalPathChanged();
	}

	mounted = true;
	emit mountedChanged();
}

void MountPoint::directoryUnmounted(const QString &dir, MountPoint::MountType mount_type)
{
	Q_UNUSED(dir);

	if (getType() != mount_type)
		return;
	if (!mounted)
		return;

	mounted = false;
	emit mountedChanged();
}


MountWatcher::MountWatcher(QObject *parent) : QObject(parent)
{
	watching = false;

	connect(&mount_process, SIGNAL(finished(int)), SLOT(mountComplete()));
	connect(&mount_process, SIGNAL(error(QProcess::ProcessError)), SLOT(mountError(QProcess::ProcessError)));

	// USB mount/umount
	watcher = new QFileSystemWatcher(this);
	connect(watcher, SIGNAL(directoryChanged(const QString &)), SLOT(directoryChanged(const QString &)));

	// mount/umount notifications
	connect(watcher, SIGNAL(fileChanged(const QString &)), SLOT(fileChanged(const QString &)));
}

MountWatcher *MountWatcher::instance()
{
	if (!mount_watcher)
		mount_watcher = new MountWatcher();

	return mount_watcher;
}

void MountWatcher::enqueueCommand(const QString &command, const QStringList &arguments)
{
	qDebug() << "Enqueuing mount command:" << command << arguments;
	command_queue << qMakePair(command, arguments);
}

void MountWatcher::runQueue()
{
	if (command_queue.empty())
		return;
	if (mount_process.state() != QProcess::NotRunning)
		return;

	ProcessEntry entry = command_queue.front();
	command_queue.pop_front();

	qDebug() << "Running mount command:" << entry.first << entry.second;
	mount_process.start(entry.first, entry.second);
}

void MountWatcher::mountError(QProcess::ProcessError error)
{
	qDebug() << "Mount error" << mount_process.errorString();
}

void MountWatcher::mountComplete()
{
	qDebug() << "Mount/umount command complete";

	// dequeue the next command, if any
	runQueue();
}

void MountWatcher::unmount(const QString &dir)
{
	qDebug() << "Unmounting" << dir;

	// only try to unmount if it is mounted
	foreach (const QString &mp, parseMounts())
		if (mp == dir)
			enqueueCommand("/bin/umount", QStringList() << "-l" << dir);

	runQueue();
}

void MountWatcher::mount(const QString &device, const QString &dir)
{
	enqueueCommand("/bin/mount", QStringList() << "-r" << "-t" << "vfat" << "-o" << "utf8=1" << device << dir);
	runQueue();
}

QStringList MountWatcher::parseMounts() const
{
	QStringList dirs;

	// parse currently-mounted directories from /proc/mounts; er do not use mtab
	// because we may get the file updated event when the mtab is only partially
	// written to disk
	QFile mtab(MOUNTS);
	if (!mtab.open(QFile::ReadOnly))
		return dirs;
	QTextStream mtab_in(&mtab);

	// skip malformed line and mount points not under "/mnt"
	for (;;)
	{
		QString line = mtab_in.readLine();
		if (line.isEmpty())
			break;
		QStringList parts = line.split(' ', QString::SkipEmptyParts);
		// the "/" is necessary in case /mnt is mounted using tmpfs
		if (!parts[1].startsWith(MOUNT_PATH "/") || !parts[0].startsWith("/"))
			continue;
		dirs.append(parts[1]);
	}

	return dirs;
}

MountPoint::MountType MountWatcher::mountType(const QString &dir) const
{
#if defined(BT_HARDWARE_X11)
	Q_UNUSED(dir);

	return MountPoint::Usb;
#else
	return dir.startsWith("/media/mmc") ? MountPoint::Sd : MountPoint::Usb;
#endif
}

void MountWatcher::notifyAll()
{
	foreach (const QString &dir, mounts)
	{
		MountPoint::MountType type = mountType(dir);
		emit directoryMounted(dir, type);
	}
}

void MountWatcher::startWatching()
{
	if (watching)
		return;
	watching = true;

	mounts = parseMounts();

	// force a status update
	foreach (const QString &dir, mounts)
		emit directoryMounted(dir, mountType(dir));

	// USB mount/umount
	watcher->addPath(MTAB);   // for x86/desktop
	watcher->addPath("/tmp"); // for touch
}

void MountWatcher::fileChanged(const QString &file)
{
	qDebug() << "File" << file << "changed";
	if (file == MTAB)
		mtabChanged();
}

void MountWatcher::directoryChanged(const QString &dir)
{
	qDebug() << "Directory" << dir << "changed";
	mtabChanged();
}

void MountWatcher::mtabChanged()
{
	// QFileSystemWatcher stops watching files when they are renamed/removed,
	// so restart watching if the watch list is empty
	if (watcher->files().isEmpty())
		watcher->addPath(MTAB);

	QStringList dirs = parseMounts();

	// compute the mounted/unmounted directories as the difference between the
	// old and new directory list
	QSet<QString> old_dirs = QSet<QString>::fromList(mounts), new_dirs = QSet<QString>::fromList(dirs);
	QSet<QString> mounted = QSet<QString>(new_dirs).subtract(old_dirs);
	QSet<QString> unmounted = QSet<QString>(old_dirs).subtract(new_dirs);

	foreach (const QString &dir, mounted)
		emit directoryMounted(dir, mountType(dir));

	foreach (const QString &dir, unmounted)
		emit directoryUnmounted(dir, mountType(dir));

	mounts = dirs;
}
