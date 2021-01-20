REM ffmpeg -i video201212050004.wmv -r 50 -f image2 42\image-%01d.png
for %%f in (*.MTS) do (
REM            echo %%~nf
	    mkdir %%~nf
	    ffmpeg -i %%~nf.MTS -r 23.98 -f image2 %%~nf\image-%%04d.png -loglevel quiet
    )
::pause