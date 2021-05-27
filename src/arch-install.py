#!/usr/bin/env python
# -*- coding: utf-8 -*-

import subprocess as sp
import os

#Install prerequisite programs:
sp.run(['pacman', '-Sy parted'])

# Show the available disks
print(sp.run(['fdisk', '-l'], stdout=sp.PIPE).stdout.decode('utf-8'))

install_disk = input("Enter Install Disk Path (ex: /dev/sda): ")

result = sp.run(['parted', f'-a optimal {install_disk} mkpart primary '])
