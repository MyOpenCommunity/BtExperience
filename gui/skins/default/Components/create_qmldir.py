#!/usr/bin/env python
#-*- coding: utf-8 -*-

from glob import glob
from os.path import splitext 


def main():
	data = []
	files = glob('*.qml')
	for f in files:
		data.append(splitext(f)[0] + ' 1.0 ' + f)
	
	out = open('qmldir', 'w+')
	out.write('\n'.join(data))
	out.close()

if __name__ == '__main__':
	main()
