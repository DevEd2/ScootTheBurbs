@echo off
rem	Build script for ScootTheBurbs

rem	Build ROM
echo Assembling...
rgbasm -o ScootTheBurbs.obj -p 255 Main.asm
if errorlevel 1 goto :BuildError
echo Linking...
rgblink -p 255 -o ScootTheBurbs.gbc -n ScootTheBurbs.sym ScootTheBurbs.obj
if errorlevel 1 goto :BuildError
echo Fixing...
rgbfix -v -p 255 ScootTheBurbs.gbc
echo Build complete.
rem Clean up files
del ScootTheBurbs.obj
goto:eof

:BuildError
echo Build failed, aborting...