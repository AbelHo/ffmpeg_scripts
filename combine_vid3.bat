for %%f in (*.mov) do (
        echo %%~nf
	ffmpeg -i ../low/%%~nf.mov -vf "[in] scale=iw/2:ih/2, pad=2*iw:ih [left]; movie=%%~nf.mov, scale=iw/2:ih/2 [right]; [left][right] overlay=main_w/2:0 [out]" 2_70kHz_%%~nf.mp4
	ffmpeg -i ../temp/all/%%~nf.mov -vf "[in] scale=iw/3:ih/3, pad=3*iw:ih [left]; movie=2_70kHz_%%~nf.mp4, scale=iw/3*2:ih/3*2 [right]; [left][right] overlay=main_w/3:0 [out]" 3_70kHz_%%~nf.mp4
	
    )

pause