#!/usr/bin/env python
#-*- coding: utf-8 -*-

import os

def fixQhp(filename):
    out_lines = []

    with open(filename, 'r') as f:
        line = f.readline()

        # adds myhome image to generated documentation
        while line.strip() != "<files>":
            out_lines.append(line)
            line = f.readline()

        out_lines.append(line)
        out_lines.append("      <file>myhome.jpg</file>\n")
        line = f.readline()

        while line.strip() != "":
            out_lines.append(line)
            line = f.readline()

    with open(filename, 'w+') as f:
        f.write(''.join(out_lines))

if __name__ == '__main__':
    os.system('doxygen btexperience.cfg')
    fixQhp('../doc/html/index.qhp')
    os.system('cp myhome.jpg ../doc/html/')
    os.system('qhelpgenerator ../doc/html/index.qhp -o ../doc/btexperience.qch')
    os.system('rm ../doc/html/index.qhp')

