package meta;

import flixel.FlxG;
using flixel.util.FlxStringUtil;

import haxe.Timer;

import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;


/**
	Overlay that displays FPS and memory usage.

	Based on this tutorial:
	https://keyreal-code.github.io/haxecoder-tutorials/17_displaying_fps_and_memory_usage_using_openfl.html
**/
class Overlay extends TextField
{
	var times:Array<Float> = [];
	var memPeak:UInt = 0;

	// display info
	static var displayFps = true;
	static var displayMemory = true;
	static var displayExtra = true;

	public function new(x:Float, y:Float)
	{
		super();

		this.x = x;
		this.y = x;

		autoSize = LEFT;
		selectable = false;

		defaultTextFormat = new TextFormat(Paths.font("vcr.ttf"), 16, 0xFFFFFF);
		text = "";

		addEventListener(Event.ENTER_FRAME, update);
	}

	function update(_:Event)
	{
		var now:Float = Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		var mem = System.totalMemory;
		if (mem > memPeak)
			memPeak = mem;

		if (visible)
		{
			text = ''; // set up the text itself
			if (displayFps) // Framerate
				text += '${times.length} FPS\n';
			#if !neko // Current Game State
			if (displayExtra && FlxG.state != null) {
				text += 'State: ${Type.getClassName(Type.getClass(FlxG.state))}\n';
				text += 'Objects: ${FlxG.state.countLiving()} (Dead: ${FlxG.state.countDead()})\n';
			}
			#end
			if (displayMemory) // Current and Total Memory Usage
				text += '${FlxStringUtil.formatBytes(mem)} / ${FlxStringUtil.formatBytes(memPeak)}\n';
		}
	}

	public static function updateDisplayInfo(shouldDisplayFps:Bool, shouldDisplayExtra:Bool, shouldDisplayMemory:Bool)
	{
		displayFps = shouldDisplayFps;
		displayExtra = shouldDisplayExtra;
		displayMemory = shouldDisplayMemory;
	}
}
