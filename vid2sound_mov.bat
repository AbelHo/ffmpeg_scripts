for %%f in (*.mov) do (
REM            echo %%~nf
	    ffmpeg -i %%~nf.mov -f wav %%~nf.wav
    )
:: pause