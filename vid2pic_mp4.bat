for %%f in (*.mp4) do (
	    echo %%~nf
	    mkdir %%~nf
	    ffmpeg -i %%~nf.mp4 -f image2 %%~nf\image-%%04d.png -loglevel quiet
    )
pause