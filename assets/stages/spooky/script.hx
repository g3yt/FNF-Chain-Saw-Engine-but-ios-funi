var halloweenBG:FlxSprite;
var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

function create()
{
	PlayState.isPixelAssets = false;

	halloweenBG = new FlxSprite(-200, -100);
	halloweenBG.frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('stages/spooky/images/halloween_bg'), Paths.xml('stages/spooky/images/halloween_bg'));
	halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	halloweenBG.animation.play('idle');
	PlayState.instance.add(halloweenBG);
}

function lightningStrikeShit(curBeat:Int)
{
	FlxG.sound.play(Paths.returnSound('stages/spooky/sounds/thunder_' + FlxG.random.int(1, 2)));
	halloweenBG.animation.play('lightning');

	lightningStrikeBeat = curBeat;
	lightningOffset = FlxG.random.int(8, 24);

	PlayState.instance.boyfriend.playAnim('scared', true);
	PlayState.instance.boyfriend.specialAnim = true;
	PlayState.instance.gf.playAnim('scared', true);
	PlayState.instance.gf.specialAnim = true;
}

function beatHit(curBeat:Int)
{
	if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		lightningStrikeShit(curBeat);
}
