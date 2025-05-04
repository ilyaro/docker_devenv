#!/bin/bash

diskutil apfs create $(hdiutil attach -nomount ram://131072000) RAMDisk && touch /Volumes/RAMDisk/.metadata_never_index
