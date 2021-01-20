
for %%f in (*.mp4) do (
REM            echo %%~nf
	    ffmpeg -i %%~nf.mp4 -f wav %%~nf.wav -loglevel quiet
    )

:: pause
REM :EndComment