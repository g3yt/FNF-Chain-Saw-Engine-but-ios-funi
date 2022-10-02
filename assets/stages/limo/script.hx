import('Paths');
import('flixel.FlxG');
import('flixel.FlxSprite');
import('flixel.group.FlxSpriteGroup');
import('flixel.util.FlxTimer');
import('flixel.graphics.frames.FlxAtlasFrames');
import('states.PlayState');

var limo:FlxSprite;
var grpLimoDancers:FlxSpriteGroup;
var fastCar:FlxSprite;
var fastCarCanDrive:Bool = true;

function create()
{
	PlayState.isPixelAssets = false;

	var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.returnGraphic('stages/limo/images/limoSunset'));
	skyBG.scrollFactor.set(0.1, 0.1);
	PlayState.instance.add(skyBG);

	var bgLimo:FlxSprite = new FlxSprite(-200, 480);
	bgLimo.frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('stages/limo/images/bgLimo'), Paths.xml('stages/limo/images/bgLimo'));
	bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
	bgLimo.animation.play('drive');
	bgLimo.scrollFactor.set(0.4, 0.4);
	PlayState.instance.add(bgLimo);

	grpLimoDancers = new FlxSpriteGroup();
	grpLimoDancers.scrollFactor.set(0.4, 0.4);
	PlayState.instance.add(grpLimoDancers);

	for (i in 0...5)
	{
		var dancer:FlxSprite = new FlxSprite((370 * i) + 130, bgLimo.y - 400);
		dancer.frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('stages/limo/images/limoDancer'), Paths.xml('stages/limo/images/limoDancer'));
		dancer.animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		dancer.animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		dancer.animation.play('danceLeft');
		grpLimoDancers.add(dancer);
	}

	fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.returnGraphic('stages/limo/images/fastCarLol'));
	resetFastCar();
	PlayState.instance.add(fastCar);

	PlayState.instance.add(PlayState.instance.gf);

	limo = new FlxSprite(-120, 550);
	limo.frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('stages/limo/images/limoDrive'), Paths.xml('stages/limo/images/limoDrive'));
	limo.animation.addByPrefix('drive', "Limo stage", 24);
	limo.animation.play('drive');
	PlayState.instance.add(limo);
}

function resetFastCar()
{
	fastCar.x = -12600;
	fastCar.y = FlxG.random.int(140, 250);
	fastCar.velocity.x = 0;
	fastCarCanDrive = true;
}

function fastCarDrive()
{
	FlxG.sound.play(Paths.returnSound('stages/limo/sounds/carPass' + FlxG.random.int(0, 1)), 0.7);

	fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
	fastCarCanDrive = false;
	new FlxTimer().start(2, function(tmr:FlxTimer)
	{
		resetFastCar();
	});
}

var danceDir:Bool = false;

function beatHit(curBeat:Int)
{
	grpLimoDancers.forEach(function(dancer:FlxSprite)
	{
		danceDir = !danceDir;

		if (danceDir)
			dancer.animation.play('danceRight', true);
		else
			dancer.animation.play('danceLeft', true);
	});

	if (FlxG.random.bool(10) && fastCarCanDrive)
		fastCarDrive();
}
