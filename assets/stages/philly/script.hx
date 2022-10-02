import('Paths');
import('flixel.FlxG');
import('flixel.FlxSprite');
import('flixel.group.FlxSpriteGroup');
import('flixel.addons.display.FlxRuntimeShader');
import('states.PlayState');

var lightFadeShader:FlxRuntimeShader;
var phillyCityLights:FlxSpriteGroup;
var phillyTrain:FlxSprite;
var curLight:Int = 0;
var startedMoving:Bool = false;
var trainMoving:Bool = false;
var trainCars:Int = 8;
var trainFinishing:Bool = false;
var trainCooldown:Int = 0;
var trainFrameTiming:Float = 0;
var trainSound:FlxSound;

function create()
{
	PlayState.isPixelAssets = false;

	var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.returnGraphic('stages/philly/images/sky'));
	bg.scrollFactor.set(0.1, 0.1);
	PlayState.instance.add(bg);

	var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.returnGraphic('stages/philly/images/city'));
	city.scrollFactor.set(0.3, 0.3);
	city.setGraphicSize(Std.int(city.width * 0.85));
	city.updateHitbox();
	PlayState.instance.add(city);

	lightFadeShader = new FlxRuntimeShader(Paths.frag('shaders/building'), Paths.vert('shaders/building'));
	lightFadeShader.setFloat('alphaShit', 0);
        lightFadeShader.setBool('hasColorTransform', true); // (theShaderGod) lmao, you can set uniform for vertex part of shader using same thing as in fragment

	phillyCityLights = new FlxSpriteGroup();
	phillyCityLights.scrollFactor.set(0.3, 0.3);
	phillyCityLights.shader = lightFadeShader;
	PlayState.instance.add(phillyCityLights);

	for (i in 0...5)
	{
		var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.returnGraphic('stages/philly/images/win' + i));
		light.setGraphicSize(Std.int(light.width * 0.85));
		light.updateHitbox();
		light.visible = false;
		phillyCityLights.add(light);
	}

	var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.returnGraphic('stages/philly/images/behindTrain'));
	PlayState.instance.add(streetBehind);

	phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.returnGraphic('stages/philly/images/train'));
	PlayState.instance.add(phillyTrain);

	trainSound = new FlxSound().loadEmbedded(Paths.returnSound('stages/philly/sounds/train_passes'));
	FlxG.sound.list.add(trainSound);

	var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.returnGraphic('stages/philly/images/street'));
	PlayState.instance.add(street);
}

function updateTrainPos()
{
	if (trainSound.time >= 4700)
	{
		startedMoving = true;
		PlayState.instance.gf.playAnim('hairBlow');
	}

	if (startedMoving)
	{
		phillyTrain.x -= 400;

		if (phillyTrain.x < -2000 && !trainFinishing)
		{
			phillyTrain.x = -1150;
			trainCars -= 1;

			if (trainCars <= 0)
				trainFinishing = true;
		}

		if (phillyTrain.x < -4000 && trainFinishing)
			trainReset();
	}
}

function trainStart()
{
	trainMoving = true;
	if (!trainSound.playing)
		trainSound.play(true);
}

function trainReset()
{
	PlayState.instance.gf.playAnim('hairFall');
	PlayState.instance.gf.specialAnim = true;
	phillyTrain.x = FlxG.width + 200;
	trainMoving = false;
	trainCars = 8;
	trainFinishing = false;
	startedMoving = false;
}

var shaderTime:Float = 0;
function update(elapsed:Float)
{
	shaderTime += 1.5 * (Conductor.crochet / 1000) * elapsed;

	if (trainMoving)
	{
		trainFrameTiming += elapsed;

		if (trainFrameTiming >= 1 / 24)
		{
			updateTrainPos();
			trainFrameTiming = 0;
		}
	}

	lightFadeShader.setFloat('alphaShit', shaderTime);
}

function beatHit(curBeat:Int)
{
	if (!trainMoving)
		trainCooldown += 1;

	if (curBeat % 4 == 0)
	{
		lightFadeShader.setFloat('alphaShit', 0);

		phillyCityLights.forEach(function(light:FlxSprite)
		{
			light.visible = false;
		});

		curLight = FlxG.random.int(0, phillyCityLights.length - 1);

		phillyCityLights.members[curLight].visible = true;
	}

	if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
	{
		trainCooldown = FlxG.random.int(-4, 0);
		trainStart();
	}
}
