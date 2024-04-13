@echo off
title Forever Engine Setup - Start
echo Welcome to the Forever Engine Automatic Setup!
TIMEOUT 3 >nul

echo This will automatically install all of the needed libraries and dependencies for compiling.
echo This setup also expects that you already have Haxe, the open-source toolkit, installed and ready to use
echo And also expects you to have Git installed

echo So if you don't have those, feel free to go to the following wepages to install the software.
echo Haxe: https://haxe.org/download/
echo Git: https://git-scm.com/downloads/

TIMEOUT 4 >nul
pause
cls

title Forever Engine Setup - Installing HaxeFlixel
echo It is time to install the engine that Funkin' uses - HaxeFlixel.
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
haxelib run lime setup
haxelib install flixel-tools
haxelib run flixel-tools Setup

title Forever Engine Setup - Installing Additional Libraries
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib install hxcpp-debug-server
cls

title Forever Engine Setup - The End!
echo And this is where the setup comes to an end
TIMEOUT 2 >nul
echo In case you're getting an error when compiling complaining about MSVC
echo You should be able to run `setup-msvc.bat` in the same folder were this setup file is.
TIMEOUT 2 >nul
echo That's all!
pause
