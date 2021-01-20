
for %%f in (*.mkv) do (
REM            echo %%~nf
	    ffmpeg -i %%~nf.mkv -f wav %%~nf.wav -loglevel quiet
    )

:: pause
REM :EndComment