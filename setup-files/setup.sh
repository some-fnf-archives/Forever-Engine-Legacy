#!/bin/bash
# FOR LINUX, based off of setup.bat
# go to https://haxe.org/download/linux/ to install the latest version of Haxe
# you may or may not need to run "haxelib setup"
# you may also need to run "chmod +x setup" to mark this file as an executable
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
haxelib run lime setup
haxelib install flixel-tools
haxelib run flixel-tools setup
haxelib install hxcpp-debug-server
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc