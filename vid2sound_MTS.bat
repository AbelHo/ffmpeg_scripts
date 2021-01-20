REM ffmpeg -i video201212050004.wmv -f wav o4.wav


REM GOTO EndComment
for %%f in (*.MTS) do (
REM            echo %%~nf
	    ffmpeg -i %%~nf.MTS -f wav %%~nf.wav -loglevel quiet
    )

:: pause
REM :EndComment