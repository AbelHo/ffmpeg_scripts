#!/bin/sh

for f in `ls *.mov`; do ffmpeg -i $f -vcodec copy -acodec copy ${f%%.mov}.mp4 -loglevel quiet; done