package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.Assets;
#if FUTURE_POLYMOD
import polymod.Polymod;
#end

using StringTools;

class Paths
{
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static var localTrackedAssets:Array<String> = [];

	public static function clearUnusedMemory()
	{
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null)
				{
					Assets.cache.removeBitmapData(key);
					Assets.cache.clearBitmapData(key);
					Assets.cache.clear(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}

		#if FUTURE_POLYMOD
		Polymod.clearCache();
		#end
		System.gc();
	}

	public static function clearStoredMemory()
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				Assets.cache.removeBitmapData(key);
				Assets.cache.clearBitmapData(key);
				Assets.cache.clear(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				Assets.cache.removeSound(key);
				Assets.cache.clearSounds(key);
				currentTrackedSounds.remove(key);
			}
		}

		for (key in Assets.cache.getKeys())
			if (!localTrackedAssets.contains(key) && key != null)
				Assets.cache.clear(key);

		localTrackedAssets = [];
	}

	inline static public function txt(key:String):String
		return 'assets/$key.txt';

	inline static public function xml(key:String):String
		return 'assets/$key.xml';

	inline static public function json(key:String):String
		return 'assets/$key.json';

	inline static public function hx(key:String):String
		return 'assets/$key.hx';

	inline static public function frag(key:String):String
		return 'assets/$key.frag';

	inline static public function vert(key:String):String
		return 'assets/$key.vert';

	inline static public function font(key:String):String
		return 'assets/fonts/$key';

	static public function sound(key:String, ?cache:Bool = true):Sound
		return returnSound('sounds/$key', cache);

	inline static public function music(key:String, ?cache:Bool = true):Sound
		return returnSound('music/$key', cache);

	inline static public function voices(song:String, ?cache:Bool = true):Sound
		return returnSound('songs/' + song.replace(' ', '-').toLowerCase() + '/Voices', cache);

	inline static public function inst(song:String, ?cache:Bool = true):Sound
		return returnSound('songs/' + song.replace(' ', '-').toLowerCase() + '/Inst', cache);

	inline static public function image(key:String, ?cache:Bool = true):FlxGraphic
		return returnGraphic('images/$key', cache);

	inline static public function getSparrowAtlas(key:String, ?cache:Bool = true):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(returnGraphic('images/$key', cache), xml('images/$key'));

	inline static public function getPackerAtlas(key:String, ?cache:Bool = true):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(returnGraphic('images/$key', cache), txt('images/$key'));

	public static function returnGraphic(key:String, ?cache:Bool = true):FlxGraphic
	{
		var path:String = 'assets/$key.png';
		if (Assets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(path), false, path, cache);
				graphic.persist = true;
				currentTrackedAssets.set(path, graphic);
			}

			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}

		trace('oh no $key its returning null NOOOO');
		return null;
	}

	public static function returnSound(key:String, ?cache:Bool = true):Sound
	{
		var path:String = 'assets/$key.ogg';
		if (Assets.exists(path, SOUND))
		{
			if (!currentTrackedSounds.exists(path))
				currentTrackedSounds.set(path, Assets.getSound(path, cache));

			localTrackedAssets.push(path);
			return currentTrackedSounds.get(path);
		}

		trace('oh no $key its returning null NOOOO');
		return null;
	}
}
