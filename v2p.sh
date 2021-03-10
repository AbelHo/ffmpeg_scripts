#!/usr/bin/env bash

mkdir $1_pics
#echo ffmpeg -i %1 -r %2 -f image2 %1_pics\image-%%06d.png
ffmpeg -i $1 -r $2 -f image2 $1_pics/image-%06d.png

#pause