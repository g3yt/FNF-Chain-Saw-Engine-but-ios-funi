package parsers;

import openfl.utils.Assets;
import haxe.Json;

typedef SwagCharacter =
{
	var position:Array<Float>;
	var camPos:Array<Float>;
	var animations:Array<SwagAnimation>;
	var scale:Float;
	var singDuration:Float;
	var antialiasing:Bool;
	var flipX:Bool;
	var flipY:Bool;
	var colors:Array<Int>;
}

typedef SwagAnimation =
{
	var animation:String;
	var prefix:String;
	var framerate:Int;
	var looped:Bool;
	var indices:Array<Int>;
	var flipX:Bool;
	var flipY:Bool;
	var offset:Array<Float>;
}

class Character
{
	public static function loadJson(file:String):SwagCharacter
		return parseJson(Paths.json('characters/' + file));

	public static function parseJson(path:String):SwagCharacter
	{
		var rawJson:String = '';

		if (Assets.exists(path))
			rawJson = Assets.getText(path);

		return Json.parse(rawJson);
	}
}
