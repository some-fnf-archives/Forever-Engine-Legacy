package meta;

import lime.utils.Assets;
import meta.state.PlayState;

using StringTools;

#if sys
import sys.FileSystem;
#end

class CoolUtil
{
	public static final difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];
	public static var difficultyLength = difficultyArray.length;

	public static inline function difficultyFromNumber(number:Int):String
	{
		return difficultyArray[number];
	}

	public static inline function dashToSpace(string:String):String
	{
		return string.replace("-", " ");
	}

	public static inline function spaceToDash(string:String):String
	{
		return string.replace(" ", "-");
	}

	public static inline function swapSpaceDash(string:String):String
	{
		return string.contains('-') ? dashToSpace(string) : spaceToDash(string);
	}

	public static inline function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
		return daList;
	}

	public static inline function getOffsetsFromTxt(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);
		var firstArray:Array<String> = fullText.split('\n');
		var swagOffsets:Array<Array<String>> = [];

		for (i in firstArray)
			swagOffsets.push(i.split(' '));

		return swagOffsets;
	}

	public static inline function returnAssetsLibrary(library:String, ?subDir:String = 'assets/images'):Array<String>
	{
		var libraryArray:Array<String> = [];

		#if sys
		var unfilteredLibrary = FileSystem.readDirectory('$subDir/$library');

		for (folder in unfilteredLibrary)
		{
			if (!folder.contains('.'))
				libraryArray.push(folder);
		}
		//trace(libraryArray);
		#end

		return libraryArray;
	}

	public static inline function getAnimsFromTxt(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);
		var firstArray:Array<String> = fullText.split('\n');
		var swagOffsets:Array<Array<String>> = [];

		for (i in firstArray)
			swagOffsets.push(i.split('--'));
		return swagOffsets;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		return [for (i in min...max) i];
	}
}
