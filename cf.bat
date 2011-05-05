@echo off
rem src = abc5 .. doesn't work
set src=abc5 base world media input keyhandling texthandling current
echo cf -r  for release version
echo cf -d  for creating html files
echo cf     default developing
if "%1"=="" (
echo ----- Doing a version for WIP ------
dmd %src% abc.res -debug -debug=TDD -I\jpro\dpro2\import \jpro\dpro2\import\jeca\libjeca.lib
)
if "%1"=="-r" (
echo ------ Doing a version that runs without a terminal ------
dmd %src% abc.res looseterm.def
del *.obj
del *.map
)
if "%1"=="-d" (
echo ------ Doing documentation ------
echo open html folder, select all files, then right click open. Note: Firefox doesn't know what to do
dmd %src% -c -D
move abc5.html html
move base.html html
move world.html html
move media.html html
move current.html html
move input.html html
move keyhandling.html html
move texthandling.html html
)
