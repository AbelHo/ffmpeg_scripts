for f in `ls *.mov`; do ffmpeg -i $f -f wav ${f%%.mov}.wav; done