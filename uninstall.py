#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os

with open('file_mappings.json', 'r') as file:
    mappings = json.load(file)

# get current directory (absolute path)
current_dir = os.path.abspath(os.path.dirname(__file__))
os.chdir(current_dir)

print('Remove these symlinks.')
print(json.dumps(mappings, indent=2))

while True:
    # some code here
    if input('Do You Want To Continue? ').lower() in ('y', 'yes'):
        break

errors = []
for target, _ in sorted(mappings.items()):
    target = os.path.expanduser(target)

    # make a symbolic link if available
    if os.path.islink(target):
        os.remove(target)
    else:
        errors.append(target)

print()
if errors:
    print("Cannot remove normal files =>")
    print(*errors, sep='\n')
else:
    print("Successfully removed!")
