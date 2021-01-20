REM ffmpeg -i video201212050004.wmv -r 50 -f image2 42\image-%01d.png
for %%f in (*.mov) do (
REM            echo %%~nf
	    mkdir %%~nf
	    ffmpeg -i %%~nf.mov -r 25 -f image2 %%~nf\image-%%04d.png -loglevel quiet
    )
::pause