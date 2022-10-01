package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.io.Bytes;
import openfl.display.BitmapData;

class ModsMenuState extends MusicBeatState
{
	public static var mustResetMusic:Bool = false;
	private var daMods:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<ModIcon> = [];
	private var curSelected:Int = 0;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if FUTURE_DISCORD_RCP
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		add(bg);

		daMods = new FlxTypedGroup<Alphabet>();
		add(daMods);

		for (i in 0...ModCore.trackedMods.length)
		{
			var text:Alphabet = new Alphabet(0, (70 * i) + 30, ModCore.trackedMods[i].title, false, false);
			text.isMenuItem = true;
			text.targetY = i;
			daMods.add(text);

			var icon:ModIcon = new ModIcon(ModCore.trackedMods[i].icon);
			icon.sprTracker = text;
			iconArray.push(icon);
			add(icon);
		}

		changeSelection();

		#if mobile
		addVirtualPad(UP_DOWN, A_B);
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		if (controls.UI_UP_P)
			changeSelection(-1);
		else if (controls.UI_DOWN_P)
			changeSelection(1);
		else if (FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			ModCore.reload();
			ModsMenuState.mustResetMusic = true;
			MusicBeatState.switchState(new MainMenuState());
		}
		else if (controls.ACCEPT)
		{
			if (!FlxG.save.data.disabledMods.contains(ModCore.trackedMods[curSelected].id))
			{
				FlxG.save.data.disabledMods.push(ModCore.trackedMods[curSelected].id);
				FlxG.save.flush();
				changeSelection();
			}
			else
			{
				FlxG.save.data.disabledMods.remove(ModCore.trackedMods[curSelected].id);
				FlxG.save.flush();
				changeSelection();
			}
		}

		super.update(elapsed);
	}

	private function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = ModCore.trackedMods.length - 1;
		if (curSelected >= ModCore.trackedMods.length)
			curSelected = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;

			if (!FlxG.save.data.disabledMods.contains(ModCore.trackedMods[i].id))
				iconArray[i].alpha = 1;
		}

		var bullShit:Int = 0;
		for (i in 0...daMods.length)
		{
			daMods.members[i].targetY = bullShit - curSelected;
			bullShit++;

			daMods.members[i].alpha = 0.6;

			if (!FlxG.save.data.disabledMods.contains(ModCore.trackedMods[i].id))
				daMods.members[i].alpha = 1;
		}
	}
}

class ModIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public function new(bytes:Bytes)
	{
		super();

		loadGraphic(BitmapData.fromBytes(bytes));
		setGraphicSize(150, 150);
		updateHitbox();
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y);
	}
}
