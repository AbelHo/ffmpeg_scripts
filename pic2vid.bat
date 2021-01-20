REM ffmpeg -f image2 -framerate 50 -r 50 -i image-%04d.png -vcodec libx264 -b 5m Trial01_400_L_1_good2.mp4
for %%f in (*) do (
REM            echo %%~nf
	    ffmpeg -f image2 -framerate 50 -r 50 -i %%~nf/image-%04d.png -vcodec libx264 -b 5m %%~nf.mp4
::	    ffmpeg -i %%~nf.mov -r 25 -f image2 %%~nf\image-%%04d.png -loglevel quiet
    )
::pause