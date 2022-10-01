package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;
import parsers.Character as CharacterParse;
import parsers.Character.SwagAnimation;
import parsers.Character.SwagCharacter;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>> = [];
	public var debugMode:Bool = false;
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var holdTimer:Float = 0;
	public var stunned:Bool = false;
	public var specialAnim:Bool = false;

	public var position:Array<Float> = [0, 0];
	public var camPos:Array<Float> = [0, 0];
	public var singDuration:Float = 4;
	public var colors:Array<Int> = [146, 113, 253];

	public function new(x:Float, y:Float, curCharacter:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets.clear();

		this.curCharacter = curCharacter;
		this.isPlayer = isPlayer;

		final character:SwagCharacter = CharacterParse.loadJson(curCharacter + '/data');

		if (Assets.exists(Paths.xml('characters/' + curCharacter + '/spritesheet')))
			frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('characters/' + curCharacter + '/spritesheet'),
				Paths.xml('characters/' + curCharacter + '/spritesheet'));
		else if (Assets.exists(Paths.txt('characters/' + curCharacter + '/spritesheet')))
			frames = FlxAtlasFrames.fromSpriteSheetPacker(Paths.returnGraphic('characters/' + curCharacter + '/spritesheet'),
				Paths.txt('characters/' + curCharacter + '/spritesheet'));
		else if (Assets.exists(Paths.json('characters/' + curCharacter + '/spritesheet')))
			frames = FlxAtlasFrames.fromTexturePackerJson(Paths.returnGraphic('characters/' + curCharacter + '/spritesheet'),
				Paths.json('characters/' + curCharacter + '/spritesheet'));

		final animations:Array<SwagAnimation> = character.animations;

		if (animations != null && animations.length > 0)
		{
			for (anim in animations)
			{
				final animAnimation:String = anim.animation;
				final animPrefix:String = anim.prefix;
				final animFramerate:Int = anim.framerate;
				final animLooped:Bool = anim.looped;
				final animIndices:Array<Int> = anim.indices;
				final animOffset:Array<Float> = anim.offset;
				final animFlipX:Bool = anim.flipX;
				final animFlipY:Bool = anim.flipY;

				if (animIndices != null && animIndices.length > 0)
					animation.addByIndices(animAnimation, animPrefix, animIndices, '', animFramerate, animLooped, animFlipX, animFlipY);
				else
					animation.addByPrefix(animAnimation, animPrefix, animFramerate, animLooped, animFlipX, animFlipY);

				if (animOffset != null && animOffset.length > 0)
					addOffset(animAnimation, animOffset[0], animOffset[1]);
				else
					addOffset(animAnimation);
			}
		}
		else
			animation.addByPrefix('idle', 'BF idle dance', 24, false);

		if (character.scale != 1)
		{
			setGraphicSize(Std.int(width * character.scale));
			updateHitbox();
		}

		position = character.position;
		camPos = character.camPos;
		singDuration = character.singDuration;

		if (character.antialiasing == true)
			antialiasing = PreferencesData.antialiasing;
		else
			antialiasing = character.antialiasing;

		flipX = character.flipX;
		flipY = character.flipY;

		if (character.colors == null || character.colors.length < 3)
			colors = [146, 113, 253];
		else
			colors = character.colors;

		if (isPlayer)
			flipX = !flipX;

		dance();
		animation.finish();
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
		{
			if (specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}
			else
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;
				else
					holdTimer = 0;

				if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
					playAnim('idle', true, false, 10);

				if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
					playAnim('deathLoop');
			}

			if (curCharacter == 'gf' && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
				dance();
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	public function dance()
	{
		if (!debugMode && !specialAnim)
		{
			if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight');
				else
					playAnim('danceLeft');
			}
			else if (animation.getByName('idle') != null)
				playAnim('idle');
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;

		animation.play(AnimName, Force, Reversed, Frame);

		if (animOffsets.exists(AnimName))
			offset.set(animOffsets.get(AnimName)[0], animOffsets.get(AnimName)[1]);
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];
}
