#!/usr/bin/python
# -*- encoding: UTF-8 -*-

# modify input file name as needed
with open("log.txt") as f:
	ll = f.readlines()

with open("frames.txt", "w") as f:
	for l in ll:
		pos = l.find("MONITOR read")
		if (pos < 0):
			continue
		pos2 = l.find('"', pos + 12)
		pos3 = l.find('"', pos2 + 1)
		frame = l[pos2+1:pos3]
		f.write(frame + "\n")

