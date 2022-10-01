package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.utils.Assets;
import parsers.Song;
import parsers.Week;
import states.ChartingState;
import states.PlayState;

class FreeplayState extends MusicBeatState
{
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	private var iconArray:Array<HealthIcon> = [];

	private var songs:Array<SongMetadata> = [];
	private var curSelected:Int = 0;
	private var curDifficulty:Int = 1;
	private var scoreText:FlxText;
	private var diffText:FlxText;
	private var lerpScore:Float = 0;
	private var intendedScore:Int = 0;
	private var bg:FlxSprite;
	private var scoreBG:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		Week.loadJsons(false);

		for (i in 0...Week.weeksList.length)
		{
			if (!weekIsLocked(Week.weeksList[i]))
			{
				for (song in Week.currentLoadedWeeks.get(Week.weeksList[i]).songs)
				{
					var colors:Array<Int> = song.colors;
					if (colors == null || colors.length < 3)
						colors = [146, 113, 253];

					songs.push(new SongMetadata(song.name, i, song.character, FlxColor.fromRGB(colors[0], colors[1], colors[2])));
				}
			}
		}

		#if FUTURE_DISCORD_RCP
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = true;

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);
		}

		scoreBG = new FlxSprite(FlxG.width * 6.7, 0).makeGraphic(1, 77, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(FlxG.width * 0.7, 41, 0, "", 24);
		diffText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT);
		add(diffText);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		add(scoreText);

		changeSelection();
		changeDiff();

		#if mobile
		addVirtualPad(LEFT_FULL, A_B);
		#end

		super.create();
	}

	private function weekIsLocked(name:String):Bool
	{
		var daWeek:SwagWeek = Week.currentLoadedWeeks.get(name);
		return (daWeek.locked
			&& daWeek.unlockAfter.length > 0
			&& (!StoryMenuState.weekCompleted.exists(daWeek.unlockAfter) || !StoryMenuState.weekCompleted.get(daWeek.unlockAfter)));
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);
		bg.color = FlxColor.interpolate(bg.color, songs[curSelected].color, CoolUtil.camLerpShit(0.045));

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);
		positionHighScore();

		if (controls.UI_UP_P)
			changeSelection(-1);
		else if (controls.UI_DOWN_P)
			changeSelection(1);
		else if (FlxG.mouse.wheel != 0)
			changeSelection(-FlxG.mouse.wheel);

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.ACCEPT)
		{
			PlayState.SONG = Song.loadJson(HighScore.formatSong(StringTools.replace(songs[curSelected].songName, " ", "-").toLowerCase(), curDifficulty),
				StringTools.replace(songs[curSelected].songName, " ", "-").toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songs[curSelected].week;

			if (FlxG.keys.pressed.SHIFT)
				MusicBeatState.switchState(new ChartingState());
			else
				MusicBeatState.switchState(new PlayState());
		}
		else if (controls.BACK)
			MusicBeatState.switchState(new MainMenuState());

		super.update(elapsed);
	}

	private function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyArray.length - 1;
		else if (curDifficulty >= CoolUtil.difficultyArray.length)
			curDifficulty = 0;

		intendedScore = HighScore.getScore(songs[curSelected].songName, curDifficulty);

		diffText.text = '< ' + CoolUtil.difficultyString(curDifficulty).toUpperCase() + ' >';
	}

	private function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		else if (curSelected >= songs.length)
			curSelected = 0;

		intendedScore = HighScore.getScore(songs[curSelected].songName, curDifficulty);

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}

	private function positionHighScore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
		diffText.x = scoreBG.x + scoreBG.width / 2;
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:FlxColor = FlxColor.WHITE;

	public function new(song:String, week:Int, songCharacter:String, color:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
	}
}
