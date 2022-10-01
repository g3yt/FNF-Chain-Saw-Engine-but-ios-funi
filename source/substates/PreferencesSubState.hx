package substates;

import flixel.FlxG;
import openfl.Lib;

class PreferencesSubState extends BaseOptionsSubState
{
	public function new()
	{
		discordClientTitle = 'Preferences Menu';

		var option:Option = new Option('Ghost Tapping', '---', 'ghostTapping', 'bool', true);
		addOption(option);

		var option:Option = new Option('Downscroll', '---', 'downScroll', 'bool', false);
		addOption(option);

		var option:Option = new Option('Centered Note-Field', '---', 'centeredNotes', 'bool', false);
		addOption(option);

		var option:Option = new Option('Note Splashes', '---', 'noteSplashes', 'bool', true);
		addOption(option);

		var option:Option = new Option('Overlay', '---', 'overlay', 'bool', false);
		option.onChange = function()
		{
			if (Main.overlay != null)
				Main.overlay.visible = PreferencesData.overlay;
		}
		addOption(option);

		#if !html5
		var option:Option = new Option('Framerate', "---", 'framerate', 'int', 60);
		option.minValue = 60;
		option.maxValue = 240;
		option.onChange = function()
		{
			if (PreferencesData.framerate > FlxG.drawFramerate)
			{
				FlxG.updateFramerate = PreferencesData.framerate;
				FlxG.drawFramerate = PreferencesData.framerate;
				Lib.current.stage.frameRate = PreferencesData.framerate;
			}
			else
			{
				FlxG.drawFramerate = PreferencesData.framerate;
				FlxG.updateFramerate = PreferencesData.framerate;
				Lib.current.stage.frameRate = PreferencesData.framerate;
			}
		}
		addOption(option);
		#end

		var option:Option = new Option('Safe Frames', '---', 'safeFrames', 'int', 10);
		option.minValue = 2;
		option.maxValue = 10;
		addOption(option);

		var option:Option = new Option('Check For Updates', '---', 'checkForUpdates', 'bool', true);
		addOption(option);

		var option:Option = new Option('Antialiasing', '---', 'antialiasing', 'bool', true);
		addOption(option);

		var option:Option = new Option('Flashing', '---', 'flashing', 'bool', true);
		addOption(option);

		super();
	}
}
