function create()
{
	PlayState.isPixelAssets = true;

	var bg:FlxSprite = new FlxSprite(400, 200);
	bg.frames = FlxAtlasFrames.fromSparrow(Paths.returnGraphic('stages/schoolEvil/images/animatedEvilSchool'),
		Paths.xml('stages/schoolEvil/images/animatedEvilSchool'));
	bg.animation.addByPrefix('idle', 'background 2', 24);
	bg.animation.play('idle');
	bg.scrollFactor.set(0.8, 0.9);
	bg.scale.set(6, 6);
	PlayState.instance.add(bg);

	PlayState.instance.add(new FlxTrail(PlayState.instance.dad, null, 4, 24, 0.3, 0.069));
}
