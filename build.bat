@echo off
rem	Build script for ScootTheBurbs

rem	Build ROM
echo Assembling...
rgbasm -o ScootTheBurbs.obj -p 255 Main.asm
if errorlevel 1 goto :BuildError
rgbasm -DGBS -o ScootTheBurbs_GBS.obj -p 255 Main.asm
if errorlevel 1 goto :BuildError
echo Linking...
rgblink -p 255 -o ScootTheBurbs.gbc -n ScootTheBurbs.sym ScootTheBurbs.obj
if errorlevel 1 goto :BuildError
rgblink -p 255 -o ScootTheBurbs_GBS.gbc ScootTheBurbs_GBS.obj
if errorlevel 1 goto :BuildError
echo Fixing...
rgbfix -v -p 255 ScootTheBurbs.gbc
echo Build complete.
goto MakeGBS

rem Clean up files
del ScootTheBurbs.obj

rem Make GBS file
:MakeGBS
echo Building GBS file...

py makegbs.py
if errorlevel 1 goto :GBSMakeError
echo GBS file built.
rem del /f ScootTheBurbs_GBS.obj ScootTheBurbs_GBS.gbc
echo ** Build finished with no errors **
goto:eof

:BuildError
echo Build failed, aborting...
goto:eof

:GBSMakeError
echo GBS build failed, aborting...
goto:eof