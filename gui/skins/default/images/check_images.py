#!/usr/bin/env python
#-*- coding: utf-8 -*-

from glob import glob
from os.path import splitext


def main():
	data = {}
	files = sorted(glob('*.*'))
	for f in files:
		name = splitext(f)[0]
		ext = splitext(f)[1]
		data_ext = data.get(name, "n/a")
		#print "name:", name, "ext:", ext, "data_ext:", data_ext
		if data_ext == "n/a":
			data[name] = ext
			continue
		if data_ext != "n/a" and data_ext != ext:
			print "file: ", name, "a file with a different extension is present!", "ext 1:", data_ext, "ext 2:", ext

if __name__ == '__main__':
	main()
