import('Paths');
import('flixel.FlxG');
import('flixel.FlxSprite');
import('flixel.tweens.FlxEase');
import('flixel.tweens.FlxTween');
import('states.PlayState');

var allowCountdown:Bool = false;

function startCountdown()
{
	if (!allowCountdown && PlayState.isStoryMode && !PlayState.seenCutscene)
	{
		var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF000000);
		blackScreen.scrollFactor.set();
		PlayState.instance.add(blackScreen);
		PlayState.instance.camHUD.visible = false;

		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			PlayState.instance.remove(blackScreen);
			FlxG.sound.play(Paths.sound('Lights_Turn_On'));
			PlayState.instance.camFollow.y = -2050;
			PlayState.instance.camFollow.x += 200;
			FlxG.camera.focusOn(PlayState.instance.camFollow.getPosition());
			FlxG.camera.zoom = 1.5;

			new FlxTimer().start(0.8, function(tmr:FlxTimer)
			{
				PlayState.instance.camHUD.visible = true;
				PlayState.instance.remove(blackScreen);
				FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, 2.5, {
					ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween)
					{
						PlayState.seenCutscene = true;
						PlayState.instance.startCountdown();
					}
				});
			});
		});

		allowCountdown = true;
		return Function_Stop;
	}
	else
		return Function_Continue;
}
