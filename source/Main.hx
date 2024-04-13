package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import meta.*;
import meta.data.PlayerSettings;
import meta.data.dependency.Discord;
import meta.data.dependency.FNFTransition;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

// Here we actually import the states and metadata, and just the metadata.
// It's nice to have modularity so that we don't have ALL elements loaded at the same time.
// at least that's how I think it works. I could be stupid!
class Main extends Sprite
{
	// class action variables
	public static var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).

	public static var initialState:Class<FlxState> = meta.state.TitleState; // Determine the state the game should begin at
	public static var framerate:Int = #if (html5 || neko) 60 #else 120 #end; // How many frames per second the game should run at.

	public static final gameVersion:String = '0.3.2h';

	// var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var infoCounter:Overlay; // initialize the heads up display that shows information before creating it.

	// heres gameweeks set up!

	/**
		Small bit of documentation here, gameweeks are what control everything in my engine
		this system will eventually be overhauled in favor of using actual week folders within the 
		assets.
		Enough of that, here's how it works
		[ [songs to use], [characters in songs], [color of week], name of week ]
	**/
	public static var gameWeeks:Array<Dynamic> = [
		[ // Week 0 / Tutorial
			['Tutorial'],
			['gf'],
			[FlxColor.fromRGB(129, 100, 223)],
			'Funky Beginnings'
		],
		[ // Week 1
			['Bopeebo', 'Fresh', 'Dadbattle'],
			['dad', 'dad', 'dad'],
			[FlxColor.fromRGB(129, 100, 223)],
			'vs. DADDY DEAREST'
		],
		[ // Week 2
			['Spookeez', 'South', 'Monster'],
			['spooky', 'spooky', 'monster'],
			[FlxColor.fromRGB(30, 45, 60)],
			'Spooky Month'
		],
		[ // Week 3
			['Pico', 'Philly-Nice', 'Blammed'],
			['pico'],
			[FlxColor.fromRGB(111, 19, 60)],
			'vs. Pico'
		],
		[ // Week 4
			['Satin-Panties', 'High', 'Milf'],
			['mom'],
			[FlxColor.fromRGB(203, 113, 170)],
			'MOMMY MUST MURDER'
		],
		[ // Week 5
			['Cocoa', 'Eggnog', 'Winter-Horrorland'],
			['parents-christmas', 'parents-christmas', 'monster-christmas'],
			[FlxColor.fromRGB(141, 165, 206)],
			'RED SNOW'
		],
		[ // Week 6
			['Senpai', 'Roses', 'Thorns'],
			['senpai', 'senpai', 'spirit'],
			[FlxColor.fromRGB(206, 106, 169)],
			"hating simulator ft. moawling"
		],
	];

	// most of these variables are just from the base game!
	// be sure to mess around with these if you'd like.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	// calls a function to set the game up
	public function new()
	{
		super();

		/**
			ok so, haxe html5 CANNOT do 120 fps. it just cannot.
			so here i just set the framerate to 60 if its complied in html5.
			reason why we dont just keep it because the game will act as if its 120 fps, and cause
			note studders and shit its weird.
		**/

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		// simply said, a state is like the 'surface' area of the window where everything is drawn.
		// if you've used gamemaker you'll probably understand the term surface better
		// this defines the surface bounds

		/* // no longer serves purpose due to flixel 5 changes
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
			// this just kind of sets up the camera zoom in accordance to the surface width and camera zoom.
			// if set to negative one, it is done so automatically, which is the default.
		}
		*/

		// here we set up the base game
		var gameCreate:FlxGame;
		gameCreate = new FlxGame(gameWidth, gameHeight, Init, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash);
		addChild(gameCreate); // and create it afterwards

		// default game FPS settings, I'll probably comment over them later.
		// addChild(new FPS(10, 3, 0xFFFFFF));

		FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e) ->
		{
			// Prevent Flixel from listening to key inputs when switching fullscreen mode
			// thanks nebulazorua @crowplexus
			if (e.keyCode == FlxKey.ENTER && e.altKey)
				e.stopImmediatePropagation();
		}, false, 100);

		// begin the discord rich presence
		#if discord_rpc
		Discord.initializeRPC();
		Discord.changePresence('');
		#end

		// test initialising the player settings
		PlayerSettings.init();

		infoCounter = new Overlay(0, 0);
		addChild(infoCounter);
	}

	public static function framerateAdjust(input:Float)
	{
		return input * (60 / FlxG.drawFramerate);
	}

	/*  This is used to switch "rooms," to put it basically. Imagine you are in the main menu, and press the freeplay button.
		That would change the game's main class to freeplay, as it is the active class at the moment.
	 */
	public static function switchState(target:FlxState)
	{
		// Custom made Trans in
		if (!FlxTransitionableState.skipNextTransIn)
		{
			FlxG.state.openSubState(new FNFTransition(0.35, false));
			FNFTransition.finishCallback = function()
			{
				FlxG.switchState(target);
			};
			//trace('changed state');
		}
		else
			// load the state
			FlxG.switchState(target);
	}

	public static function updateFramerate(newFramerate:Int)
	{
		// flixel will literally throw errors at me if I dont separate the orders
		if (newFramerate > FlxG.updateFramerate)
		{
			FlxG.updateFramerate = newFramerate;
			FlxG.drawFramerate = newFramerate;
		}
		else
		{
			FlxG.drawFramerate = newFramerate;
			FlxG.updateFramerate = newFramerate;
		}
	}

	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = 'crash/FE_$dateNow.txt';

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;
		//errMsg += "\nPlease report this error to the GitHub page: https://github.com/CrowPlexus-FNF/Forever-Engine-Legacy";

		if (!FileSystem.exists("crash/"))
			FileSystem.createDirectory("crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println('Crash dump saved in ${Path.normalize(path)}');
		Sys.println("Making a simple alert...");

		#if windows
		var crashDialoguePath:String = "FE-CrashDialog.exe";
		if (FileSystem.exists(crashDialoguePath))
			new Process(crashDialoguePath, [path]);
		else
		#end
		Application.current.window.alert(errMsg, "Error!");
		Sys.exit(1);
	}
}
