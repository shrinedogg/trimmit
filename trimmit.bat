@Echo Off
SetLocal
Set "ext=mp4"
Set "trim_mode=start"          rem start | end | both
Set "skip_start_sec=0"
Set "skip_end_sec=0"
Set "trim_start_ms=000"
Set "opts=-v quiet"
Set "opts=%opts% -print_format "compact=print_section=0:nokey=1:escape=csv""
Set "opts=%opts% -show_entries "format=duration""
Set "ffmpeg_dir=%ffmpeg_dir%"
If Defined ffmpeg_dir (
    Set "ffmpeg=%ffmpeg_dir%\ffmpeg.exe"
    Set "ffprobe=%ffmpeg_dir%\ffprobe.exe"
) Else (
    Set "ffmpeg=ffmpeg"
    Set "ffprobe=ffprobe"
)
If Exist *.%ext% (If Not Exist "Trimmed\" MD Trimmed)
For %%a In (*.%ext%) Do Call :Sub "%%~a"
Exit/B

:Sub
Set "start_skip=0"
Set "end_skip=0"
If /I "%trim_mode%"=="start" Set "start_skip=%skip_start_sec%"
If /I "%trim_mode%"=="end"   Set "end_skip=%skip_end_sec%"
If /I "%trim_mode%"=="both" (
    Set "start_skip=%skip_start_sec%"
    Set "end_skip=%skip_end_sec%"
)

For /f "Tokens=1* Delims=." %%a In (
    '%ffprobe% %opts% %1') Do (Set/A "ws=%%a-start_skip-end_skip" & Set "ps=%%b")

If %ws% LEQ 0 (
    Echo Skipping %~1 (shorter than requested trims: start %start_skip%s, end %end_skip%s)
    GoTo :EOF
)

rem Format start offset (HH:MM:SS.mmm)
Set/A shh=start_skip/(60*60), slo=start_skip%%(60*60), smm=slo/60, sss=slo%%60
If %shh% Lss 10 Set shh=0%shh%
If %smm% Lss 10 Set smm=0%smm%
If %sss% Lss 10 Set sss=0%sss%

rem Format duration to keep (-t)
Set/A hh=ws/(60*60), lo=ws%%(60*60), mm=lo/60, ss=lo%%60
If %hh% Lss 10 Set hh=0%hh%
If %mm% Lss 10 Set mm=0%mm%
If %ss% Lss 10 Set ss=0%ss%

"%ffmpeg%" -i %1 -ss %shh%:%smm%:%sss%.%trim_start_ms% -t %hh%:%mm%:%ss%.%ps,~3% -c:v copy -c:a copy "Trimmed\%~1"