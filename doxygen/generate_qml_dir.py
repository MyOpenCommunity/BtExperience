#!/usr/bin/env python
#-*- coding: utf-8 -*-

import os

def main():
	for r, d, f in os.walk(".."):
		for files in f:
			if files.endswith(".qml"):
				print "                        ", r, "\\"
				break

if __name__ == '__main__':
	main()

