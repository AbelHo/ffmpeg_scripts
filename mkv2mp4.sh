#!/bin/sh

for f in `ls *.mkv`; do ffmpeg -i $f -vcodec copy -acodec copy ${f%%.mkv}.mp4 -loglevel quiet; done