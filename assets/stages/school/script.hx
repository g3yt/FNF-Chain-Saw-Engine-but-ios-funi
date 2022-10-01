var widShit:Int;
var bgGirls:FlxSprite;

function create()
{
	PlayState.isPixelAssets = true;

	var bgSky:FlxSprite = new FlxSprite().loadGraphic(Paths.returnGraphic('stages/school/images/weebSky'));

	widShit = Std.int(bgSky.width * 6);

	bgSky.scrollFactor.set(0.1, 0.1);
	bgSky.setGraphicSize(widShit);
	bgSky.updateHitbox();
	PlayState.instance.add(bgSky);

	var bgSchool:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.returnGraphic('stages/school/images/weebSchool'));
	bgSchool.scrollFactor.set(0.6, 0.90);
	bgSchool.setGraphicSize(widShit);
	bgSchool.updateHitbox();
	PlayState.instance.add(bgSchool);

	var bgStreet:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.returnGraphic('stages/school/images/weebStreet'));
	bgStreet.scrollFactor.set(0.95, 0.95);
	bgStreet.setGraphicSize(widShit);
	bgStreet.updateHitbox();
	PlayState.instance.add(bgStreet);

	var fgTrees:FlxSprite = new FlxSprite(-50, 130).loadGraphic(Paths.returnGraphic('stages/school/images/weebTreesBack'));
	fgTrees.scrollFactor.set(0.9, 0.9);
	fgTrees.setGraphicSize(Std.int(widShit * 0.8));
	fgTrees.updateHitbox();
	PlayState.instance.add(fgTrees);

	var bgTrees:FlxSprite = new FlxSprite(-580, -800);
	bgTrees.frames = FlxAtlasFrames.fromSpriteSheetPacker(Paths.returnGraphic('stages/school/images/weebTrees'), Paths.txt('stages/school/images/weebTrees'));
	bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
	bgTrees.animation.play('treeLoop');
	bgTrees.scrollFactor.set(0.85, 0.85);
	bgTrees.setGraphicSize(Std.int(widShit * 1.4));
	bgTrees.updateHitbox();
	PlayState.instance.add(bgTrees);

	var treeLeaves:FlxSprite = new FlxSprite(-200, -40);
	treeLeaves.frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('stages/school/images/petals'), Paths.xml('stages/school/images/petals'));
	treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
	treeLeaves.animation.play('leaves');
	treeLeaves.scrollFactor.set(0.85, 0.85);
	treeLeaves.setGraphicSize(widShit);
	treeLeaves.updateHitbox();
	PlayState.instance.add(treeLeaves);

	bgGirls = new FlxSprite(-100, 190);
	bgGirls.frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('stages/school/images/bgFreaks'), Paths.xml('stages/school/images/bgFreaks'));
	if (PlayState.SONG.song.toLowerCase() == 'roses')
	{
		bgGirls.animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
		bgGirls.animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
	}
	else
	{
		bgGirls.animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
		bgGirls.animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);
	}
	bgGirls.animation.play('danceLeft');
	bgGirls.scrollFactor.set(0.9, 0.9);
	bgGirls.setGraphicSize(Std.int(bgGirls.width * 6));
	bgGirls.updateHitbox();
	PlayState.instance.add(bgGirls);
}

var danceDir:Bool = false;

function beatHit(curBeat:Int)
{
	danceDir = !danceDir;

	if (danceDir)
		bgGirls.animation.play('danceRight', true);
	else
		bgGirls.animation.play('danceLeft', true);
}
