#ifndef MOUNTS_H
#define MOUNTS_H

#include <QPair>
#include <QProcess>
#include <QVariant>

class QFileSystemWatcher;
class MountWatcher;


class BrowsePoint : public QObject
{
	Q_OBJECT

	Q_PROPERTY(MountType type READ getType CONSTANT)

public:
	enum MountType
	{
		Usb   = 1,
		Sd    = 2,
		UPnP  = 3
	};

	BrowsePoint(MountType type);

	MountType getType() const;

private:
	MountType type;
};


/*!
	\brief Class representing a mount point

	Currently there can only be a single USB mount point and a single SD mount point
 */
class MountPoint : public BrowsePoint
{
	Q_OBJECT

	/*!
		\brief mount point path as a string (es. /media/sda1)

		Only set after the first time the mount status is updated
	*/
	Q_PROPERTY(QString path READ getPath  NOTIFY pathChanged)

	/*!
		\brief mount point path as a list (es. ["media", "sda1"])

		Only set after the first time the mount status is updated
	*/
	Q_PROPERTY(QVariantList logicalPath READ getLogicalPath NOTIFY logicalPathChanged)

	/*!
		\brief Whether this mount point is mounted or not
	*/
	Q_PROPERTY(bool mounted READ getMounted NOTIFY mountedChanged)

public:
	MountPoint(MountType type);

	void setPath(QString path);
	QString getPath() const;

	void setLogicalPath(QVariantList path);
	QVariantList getLogicalPath() const;

	void setMounted(bool mounted);
	bool getMounted() const;

public slots:
	void unmount();

signals:
	void pathChanged();
	void logicalPathChanged();
	void mountedChanged();

private slots:
	void directoryMounted(const QString &dir, MountPoint::MountType mount_type);
	void directoryUnmounted(const QString &dir, MountPoint::MountType mount_type);

private:
	QString path;
	QVariantList logical_path;
	bool mounted;
};


// Helper class, not used directly
class MountWatcher : public QObject
{
	Q_OBJECT

public:
	typedef QPair<QString, QStringList> ProcessEntry;

public:
	MountWatcher(QObject *parent = 0);

	// returns the list of currently-mounted directories
	QStringList mountState() const;

	// mount/unmount the path
	void mount(const QString &device, const QString &dir);
	void unmount(const QString &dir);

	// starts watching for mount/umount events, emits a directoryMounted() signal
	// for every mounted filesystem
	void startWatching();

	// force notifications for all currently-mounted mountpoints
	void notifyAll();

	static MountWatcher *instance();

signals:
	void directoryMounted(const QString &dir, MountPoint::MountType type);
	void directoryUnmounted(const QString &dir, MountPoint::MountType type);

private:
	QStringList parseMounts() const;

	void mtabChanged();
	void enqueueCommand(const QString &command, const QStringList &arguments);
	void runQueue();

	MountPoint::MountType mountType(const QString &dir) const;

private slots:
	void fileChanged(const QString &file);
	void directoryChanged(const QString &directory);
	void mountComplete();
	void mountError(QProcess::ProcessError error);

private:
	// avoid double initialization
	bool watching;

	// list of currently-mounted filesystems
	QStringList mounts;

	QFileSystemWatcher *watcher;
	QProcess mount_process;
	QList<ProcessEntry> command_queue;

	static MountWatcher *mount_watcher;
};

#endif // MOUNTS_H
