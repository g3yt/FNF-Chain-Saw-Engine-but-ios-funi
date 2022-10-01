var upperBoppers:FlxSprite;
var bottomBoppers:FlxSprite;
var santa:FlxSprite;

function create()
{
	PlayState.isPixelAssets = false;

	var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.returnGraphic('stages/mall/images/bgWalls'));
	bg.scrollFactor.set(0.2, 0.2);
	bg.setGraphicSize(Std.int(bg.width * 0.8));
	bg.updateHitbox();
	PlayState.instance.add(bg);

	upperBoppers = new FlxSprite(-240, -90);
	upperBoppers.frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('stages/mall/images/upperBop'), Paths.xml('stages/mall/images/upperBop'));
	upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
	upperBoppers.scrollFactor.set(0.33, 0.33);
	upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
	upperBoppers.updateHitbox();
	PlayState.instance.add(upperBoppers);

	var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.returnGraphic('stages/mall/images/bgEscalator'));
	bgEscalator.scrollFactor.set(0.3, 0.3);
	bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
	bgEscalator.updateHitbox();
	PlayState.instance.add(bgEscalator);

	var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.returnGraphic('stages/mall/images/christmasTree'));
	tree.scrollFactor.set(0.40, 0.40);
	PlayState.instance.add(tree);

	bottomBoppers = new FlxSprite(-300, 140);
	bottomBoppers.frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('stages/mall/images/bottomBop'), Paths.xml('stages/mall/images/bottomBop'));
	bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
	bottomBoppers.scrollFactor.set(0.9, 0.9);
	bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
	bottomBoppers.updateHitbox();
	PlayState.instance.add(bottomBoppers);

	var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.returnGraphic('stages/mall/images/fgSnow'));
	PlayState.instance.add(fgSnow);

	santa = new FlxSprite(-840, 150);
	santa.frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('stages/mall/images/santa'), Paths.xml('stages/mall/images/santa'));
	santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
	PlayState.instance.add(santa);
}

function beatHit(curBeat:Int)
{
	upperBoppers.animation.play('bop', true);
	bottomBoppers.animation.play('bop', true);
	santa.animation.play('idle', true);
}
