for f in `ls *.MTS`; do mkdir ${f%%.MTS}; ffmpeg -i $f -r 23.98 -f image2 ${f%%.MTS}/image-%04d.png -loglevel quiet; done