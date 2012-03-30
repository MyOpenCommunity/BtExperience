TEMPLATE = subdirs
SUBDIRS += gui
SUBDIRS += BtObjects

gui.depends += BtObjects
