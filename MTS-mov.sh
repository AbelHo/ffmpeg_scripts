#!/bin/sh

for f in `ls *.MTS`; do ffmpeg -i $f -vcodec copy -acodec copy -sn ${f%%.MTS}.mov -loglevel quiet; done