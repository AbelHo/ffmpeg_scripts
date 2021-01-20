#!/bin/sh

for f in `ls *.MTS`; do ffmpeg -i $f -vcodec copy -acodec copy ${f%%.MTS}.mp4 -loglevel quiet; done