set arg1=%1
ffmpeg -i %1 -f wav %1.wav -loglevel quiet
pause