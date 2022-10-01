package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;
import parsers.StoryCharacter as StoryCharacterParse;
import parsers.StoryCharacter.SwagStoryAnimation;
import parsers.StoryCharacter.SwagStoryCharacter;

/**
	Class based on Character.hx lmao
**/
class StoryCharacter extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>> = [];

	public function new(x:Float, y:Float, name:String = 'bf')
	{
		super(x, y);

		changeCharacter(name);
	}

	public function changeCharacter(char:String = 'bf'):Void
	{
		animOffsets.clear();

		if (char == '')
		{
			if (visible == true)
				visible = false;
		}
		else
		{
			if (visible == false)
				visible = true;

			scale.set(1, 1);
			updateHitbox(); // is this acually needed?

			final daCharacter:SwagStoryCharacter = StoryCharacterParse.loadJson(char + '/data');

			if (Assets.exists(Paths.xml('images/menucharacters/' + char + '/spritesheet')))
				frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('images/menucharacters/' + char + '/spritesheet'),
					Paths.xml('images/menucharacters/' + char + '/spritesheet'));
			else if (Assets.exists(Paths.txt('images/menucharacters/' + char + '/spritesheet')))
				frames = FlxAtlasFrames.fromSpriteSheetPacker(Paths.returnGraphic('images/menucharacters/' + char + '/spritesheet'),
					Paths.txt('images/menucharacters/' + char + '/spritesheet'));
			else if (Assets.exists(Paths.json('images/menucharacters/' + char + '/spritesheet')))
				frames = FlxAtlasFrames.fromTexturePackerJson(Paths.returnGraphic('images/menucharacters/' + char + '/spritesheet'),
					Paths.json('images/menucharacters/' + char + '/spritesheet'));
	
			final animations:Array<SwagStoryAnimation> = daCharacter.animations;
	
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
				animation.addByPrefix('idle', 'idle', 24, false);

			if (daCharacter.scale != 1)
			{
				scale.set(daCharacter.scale, daCharacter.scale);
				updateHitbox(); // is this acually needed?
			}

			if (daCharacter.antialiasing == true)
				antialiasing = PreferencesData.antialiasing;
			else
				antialiasing = daCharacter.antialiasing;
	
			flipX = daCharacter.flipX;
			flipY = daCharacter.flipY;
	
			dance();
		}
	}

	private var danced:Bool = false;

	public function dance():Void
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

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		if (animOffsets.exists(AnimName))
			offset.set(animOffsets.get(AnimName)[0], animOffsets.get(AnimName)[1]);
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0):Void
		animOffsets[name] = [x, y];
}
