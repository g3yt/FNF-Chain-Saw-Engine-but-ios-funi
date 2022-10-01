package;

import flixel.FlxG;
import openfl.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard"];

	public static function difficultyString(curDifficulty:Int):String
		return difficultyArray[curDifficulty];

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];

		if (Assets.exists(path))
			daList = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];

		for (i in min...max)
			dumbArray.push(i);

		return dumbArray;
	}

	public static function camLerpShit(ratio:Float):Float
		return FlxG.elapsed / (1 / 60) * ratio;

	public static function coolLerp(a:Float, b:Float, ratio:Float):Float
		return a + camLerpShit(ratio) * (b - a);

	public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		var newValue:Float = value;

		if (newValue < min)
			newValue = min;
		else if (newValue > max)
			newValue = max;

		return newValue;
	}
}
