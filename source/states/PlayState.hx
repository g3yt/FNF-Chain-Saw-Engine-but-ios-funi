package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import openfl.utils.Assets;
import parsers.Song;
import parsers.Stage;
import parsers.Week;
import substates.GameOverSubState;
import substates.PauseSubState;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;
	public static var campaignScore:Int = 0;
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var isPixelAssets:Bool = false;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;
	public static var autoplayMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	private var playerStrums:FlxTypedGroup<StrumNote> = null;
	private var opponentStrums:FlxTypedGroup<StrumNote> = null;
	private var grpNoteSplashes:FlxTypedGroup<NoteSplash> = null;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Character;
	private var scriptArray:Array<ScriptCore> = [];
	private var defaultPlayerStrumX:Array<Float> = [];
	private var defaultPlayerStrumY:Array<Float> = [];
	private var defaultOpponentStrumX:Array<Float> = [];
	private var defaultOpponentStrumY:Array<Float> = [];
	private var unspawnNotes:Array<Note> = [];
	private var prevCamFollow:FlxObject;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var vocals:FlxSound;
	private var vocalsFinished = false;
	private var curSection:Int = 0;
	private var camFollow:FlxObject;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var camZooming:Bool = true;
	private var score:Int = 0;
	private var scoreTxt:FlxText;
	private var defaultCamZoom:Float = 1.05;
	private var inCutscene:Bool = false;
	private var gfSpeed:Int = 1;
	private var combo:Int = 0;
	private var comboBreaks:Int = 0;
	private var maxSongPos:Int = 14000;
	private var minHealth:Int = 0;
	private var paused:Bool = false;
	private var startedCountdown:Bool = false;
	private var canPause:Bool = true;
	private var endingSong:Bool = false;
	private var cameraRightSide:Bool = false;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camFollowDad:Array<Float> = [0, 0];
	private var camFollowBoyfriend:Array<Float> = [0, 0];
	private var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	private var health:Float = 1;
	private var notes:FlxTypedGroup<Note>;

	private final divider:String = " | ";
	private final iconOffset:Int = 26;

	#if FUTURE_DISCORD_RCP
	// Discord RPC variables
	private var detailsText:String = "";
	#end

	override public function create()
	{
		Paths.clearStoredMemory();

		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		#if FUTURE_DISCORD_RCP
		if (isStoryMode)
			detailsText = "Story Mode: " + StoryMenuState.loadedWeekList[storyWeek];
		else
			detailsText = "Freeplay";
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = persistentDraw = true;

		if (SONG.stage == null || SONG.stage.length < 1)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'spookeez' | 'south' | 'monster':
					SONG.stage = 'spooky';
				case 'pico' | 'blammed' | 'philly':
					SONG.stage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					SONG.stage = 'limo';
				case 'cocoa' | 'eggnog':
					SONG.stage = 'mall';
				case 'winter-horrorland':
					SONG.stage = 'mallEvil';
				case 'senpai' | 'roses':
					SONG.stage = 'school';
				case 'thorns':
					SONG.stage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					SONG.stage = 'tank';
				default:
					SONG.stage = 'stage';
			}
		}

		var stageFile:SwagStage = Stage.loadJson(SONG.stage);
		if (stageFile == null)
		{
			stageFile = {
				zoom: 0.9,
				gf: [400, 100],
				dad: [100, 100],
				boyfriend: [770, 100],
				camFollowDad: [150, -100],
				camFollowBoyfriend: [-100, -100]
			};
		}

		defaultCamZoom = stageFile.zoom;
		camFollowDad = stageFile.camFollowDad;
		camFollowBoyfriend = stageFile.camFollowBoyfriend;

		if (SONG.gfVersion == null || SONG.gfVersion.length < 1)
		{
			switch (SONG.stage)
			{
				case 'limo':
					SONG.gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					SONG.gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					SONG.gfVersion = 'gf-pixel';
				default:
					SONG.gfVersion = 'gf';
			}
		}

		gf = new Character(0, 0, SONG.gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		gf.x = stageFile.gf[0] + gf.position[0];
		gf.y = stageFile.gf[1] + gf.position[1];

		dad = new Character(0, 0, SONG.player2);
		dad.x = stageFile.dad[0] + dad.position[0];
		dad.y = stageFile.dad[1] + dad.position[1];

		boyfriend = new Character(0, 0, SONG.player1, true);
		boyfriend.x = stageFile.boyfriend[0] + boyfriend.position[0];
		boyfriend.y = stageFile.boyfriend[1] + boyfriend.position[1];

		if (Assets.exists(Paths.hx('stages/' + SONG.stage + '/script')))
			scriptArray.push(new ScriptCore(Paths.hx('stages/' + SONG.stage + '/script')));

		add(gf);
		add(dad);
		add(boyfriend);

		for (script in Assets.list(TEXT).filter(text -> text.contains('assets/scripts')))
			if (script.endsWith('.hx'))
				scriptArray.push(new ScriptCore(script));

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		splash.alpha = 0.00001;
		grpNoteSplashes.add(splash);

		playerStrums = new FlxTypedGroup<StrumNote>();
		add(playerStrums);

		opponentStrums = new FlxTypedGroup<StrumNote>();
		add(opponentStrums);

		generateSong();

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(dad.getGraphicMidpoint().x + dad.camPos[0], dad.getGraphicMidpoint().y + dad.camPos[1]);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, PreferencesData.downScroll ? FlxG.height * 0.1 : FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(FlxColor.fromRGB(dad.colors[0], dad.colors[1], dad.colors[2]),
			FlxColor.fromRGB(boyfriend.colors[0], boyfriend.colors[1], boyfriend.colors[2]));
		add(healthBar);

		iconP1 = new HealthIcon(boyfriend.curCharacter, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dad.curCharacter, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(0, healthBarBG.y + 40, 0, 'Score:' + score + divider + 'Combo Breaks:' + comboBreaks, 19);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 19, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);

		grpNoteSplashes.cameras = [camHUD];
		playerStrums.cameras = [camHUD];
		opponentStrums.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		#if mobile
		addMobileControls(false);
		#end

		if (Assets.exists(Paths.hx('songs/' + SONG.song.toLowerCase() + '/script')))
			scriptArray.push(new ScriptCore(Paths.hx('songs/' + SONG.song.toLowerCase() + '/script')));

		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'senpai':
					var doof:DialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('songs/' + SONG.song.toLowerCase() + '/dialogue')));
					doof.scrollFactor.set();
					doof.finishThing = startCountdown;
					doof.cameras = [camHUD];
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					var doof:DialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('songs/' + SONG.song.toLowerCase() + '/dialogue')));
					doof.scrollFactor.set();
					doof.finishThing = startCountdown;
					doof.cameras = [camHUD];
					schoolIntro(doof);
				case 'thorns':
					var doof:DialogueBox = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('songs/' + SONG.song.toLowerCase() + '/dialogue')));
					doof.scrollFactor.set();
					doof.finishThing = startCountdown;
					doof.cameras = [camHUD];
					schoolIntro(doof);
				default:
					startCountdown();
			}

			seenCutscene = true;
		}
		else
			startCountdown();

		super.create();

		Paths.clearUnusedMemory();
	}

	private function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('stages/weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.updateHitbox();
		senpaiEvil.scrollFactor.set();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);
			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
				tmr.reset(0.3);
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
								swagTimer.reset();
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
						add(dialogueBox);
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	private function startCountdown():Void
	{
		if (startedCountdown)
		{
			callScripts('startCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callScripts('startCountdown', []);
		if (ret != ScriptCore.Function_Stop)
		{
			#if mobile
			mobileControls.visible = true;
			#end

			generateStaticArrows(0);
			generateStaticArrows(1);

			for (i in 0...playerStrums.length)
			{
				defaultPlayerStrumX.push(playerStrums.members[i].x);
				defaultPlayerStrumY.push(playerStrums.members[i].y);
			}

			for (i in 0...opponentStrums.length)
			{
				defaultOpponentStrumX.push(opponentStrums.members[i].x);
				defaultOpponentStrumY.push(opponentStrums.members[i].y);
				if (PreferencesData.centeredNotes)
					opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;

			doIntro(Conductor.crochet / 1000);
		}
	}

	private function doIntro(startTime:Float):Void
	{
		var swagCounter:Int = 0;
		var startTimer:FlxTimer = new FlxTimer().start(startTime, function(tmr:FlxTimer)
		{
			if (tmr.loopsLeft % Math.round(gfSpeed * 2) == 0 && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				gf.dance();

			if (tmr.loopsLeft % 2 == 0 && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				boyfriend.dance();

			if (tmr.loopsLeft % 2 == 0 && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				dad.dance();

			switch (swagCounter)
			{
				case 0:
					if (!PlayState.isPixelAssets)
						FlxG.sound.play(Paths.sound('intro3'), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro3-pixel'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite();
					if (!PlayState.isPixelAssets)
						ready.loadGraphic(Paths.image('ui/default/ready'));
					else
						ready.loadGraphic(Paths.image('ui/pixel/ready'));
					ready.scrollFactor.set();

					if (PlayState.isPixelAssets)
					{
						ready.setGraphicSize(Std.int(ready.width * 6));
						ready.updateHitbox();
					}

					ready.screenCenter();
					add(ready);

					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});

					if (!PlayState.isPixelAssets)
						FlxG.sound.play(Paths.sound('intro2'), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro2-pixel'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite();
					if (!PlayState.isPixelAssets)
						set.loadGraphic(Paths.image('ui/default/set'));
					else
						set.loadGraphic(Paths.image('ui/pixel/set'));
					set.scrollFactor.set();

					if (PlayState.isPixelAssets)
					{
						set.setGraphicSize(Std.int(set.width * 6));
						set.updateHitbox();
					}

					set.screenCenter();
					add(set);

					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});

					if (!PlayState.isPixelAssets)
						FlxG.sound.play(Paths.sound('intro1'), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro1-pixel'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite();
					if (!PlayState.isPixelAssets)
						go.loadGraphic(Paths.image('ui/default/go'));
					else
						go.loadGraphic(Paths.image('ui/pixel/go'));
					go.scrollFactor.set();

					if (PlayState.isPixelAssets)
					{
						go.setGraphicSize(Std.int(go.width * 6));
						go.updateHitbox();
					}

					go.screenCenter();
					add(go);

					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});

					if (!PlayState.isPixelAssets)
						FlxG.sound.play(Paths.sound('introGo'), 0.6);
					else
						FlxG.sound.play(Paths.sound('introGo-pixel'), 0.6);
			}

			swagCounter += 1;
		}, 5);
	}

	private function startSong():Void
	{
		startingSong = false;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
		vocals.onComplete = function()
		{
			vocalsFinished = true;
		}

		if (paused)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		#if FUTURE_DISCORD_RCP
		DiscordClient.changePresence(detailsText, SONG.song + " (" + CoolUtil.difficultyString(storyDifficulty) + ")", iconP2.curCharacter);
		#end
	}

	private var debugNum:Int = 0;

	private function generateSong():Void
	{
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		for (section in SONG.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				final daStrumTime:Float = songNotes[0];
				final daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.mustPress = gottaHitNote;
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength /= Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.mustPress = gottaHitNote;
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2;
				}

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2;
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	private function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:StrumNote = new StrumNote((PreferencesData.centeredNotes ? -278 : 42), (PreferencesData.downScroll ? FlxG.height - 150 : 50), i,
				player);
			babyArrow.downScroll = PreferencesData.downScroll;

			switch (player)
			{
				case 0:
					opponentStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (!paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				if (SONG.needsVoices)
					vocals.pause();
			}

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
			{
				if (!tmr.finished)
					tmr.active = false;
			});

			FlxTween.globalManager.forEach(function(twn:FlxTween)
			{
				if (!twn.finished)
					twn.active = false;
			});

			#if FUTURE_DISCORD_RCP
			DiscordClient.changePresence("Paused - " + detailsText, SONG.song + " (" + CoolUtil.difficultyString(storyDifficulty) + ")", iconP2.curCharacter);
			#end

			paused = true;
		}

		super.openSubState(SubState);

		Paths.clearUnusedMemory();
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
			{
				if (!tmr.finished)
					tmr.active = true;
			});

			FlxTween.globalManager.forEach(function(twn:FlxTween)
			{
				if (!twn.finished)
					twn.active = true;
			});

			#if FUTURE_DISCORD_RCP
			DiscordClient.changePresence(detailsText, SONG.song
				+ " ("
				+ CoolUtil.difficultyString(storyDifficulty)
				+ ")", iconP2.curCharacter, true,
				FlxG.sound.music.length
				- Conductor.songPosition);
			#end

			paused = false;
		}

		super.closeSubState();

		Paths.clearUnusedMemory();
	}

	#if FUTURE_DISCORD_RCP
	override public function onFocus():Void
	{
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ CoolUtil.difficultyString(storyDifficulty)
					+ ")", iconP2.curCharacter, true,
					FlxG.sound.music.length
					- Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + CoolUtil.difficultyString(storyDifficulty) + ")", iconP2.curCharacter);
		}

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (health > 0 && !paused)
			DiscordClient.changePresence("Paused - " + detailsText, SONG.song + " (" + CoolUtil.difficultyString(storyDifficulty) + ")", iconP2.curCharacter);

		super.onFocusLost();
	}
	#end

	private function resyncVocals():Void
	{
		if (SONG.needsVoices)
			vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (!vocalsFinished)
		{
			vocals.time = Conductor.songPosition;
			vocals.play();
		}

		#if FUTURE_DISCORD_RCP
		DiscordClient.changePresence(detailsText, SONG.song + " (" + CoolUtil.difficultyString(storyDifficulty) + ")", iconP2.curCharacter);
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		callScripts('update', [elapsed]);

		scoreTxt.text = 'Score:' + score + divider + 'Combo Breaks:' + comboBreaks;
		scoreTxt.screenCenter(X);

		if (controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
			pause();

		if (FlxG.keys.justPressed.SEVEN)
			MusicBeatState.switchState(new ChartingState());

		if (FlxG.keys.justPressed.EIGHT)
			MusicBeatState.switchState(new AnimationDebug(SONG.player2));

		if (FlxG.keys.justPressed.ZERO)
			MusicBeatState.switchState(new AnimationDebug(SONG.player1));

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.85)));
		iconP1.updateHitbox();
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);

		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.85)));
		iconP2.updateHitbox();
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		iconP1.animation.curAnim.curFrame = healthBar.percent < 20 ? 1 : 0;
		iconP2.animation.curAnim.curFrame = healthBar.percent > 80 ? 1 : 0;

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += elapsed * 1000;
			if (!paused && Conductor.lastSongPos != Conductor.songPosition)
				Conductor.lastSongPos = Conductor.songPosition;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			cameraMovement(!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		if (!inCutscene && !endingSong)
		{
			if (controls.RESET && startedCountdown)
			{
				health = minHealth;
				trace("RESET = True");
			}

			if (health <= minHealth && !practiceMode)
				gameOver();
		}

		if (unspawnNotes[0] != null
			&& unspawnNotes.length > 0
			&& (unspawnNotes[0].strumTime - Conductor.songPosition < maxSongPos / SONG.speed))
		{
			notes.add(unspawnNotes[0]);
			unspawnNotes.shift();
		}

		notes.forEachAlive(function(daNote:Note)
		{
			if (generatedMusic)
				noteCalls(daNote);
		});

		if (!inCutscene && !endingSong)
		{
			if (!autoplayMode)
				keyShit();
			else if (boyfriend.animation.curAnim != null
				&& boyfriend.holdTimer > 0.001 * boyfriend.singDuration * Conductor.stepCrochet
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}
	}

	private function pause()
	{
		var ret:Dynamic = callScripts('pause', []);
		if (ret != ScriptCore.Function_Stop)
		{
			persistentUpdate = false;
			persistentDraw = true;

			var cam:FlxCamera = new FlxCamera();
			cam.bgColor.alpha = 0;
			FlxG.cameras.add(cam, false);

			var pauseMenu:PauseSubState = new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y);
			pauseMenu.camera = cam;
			openSubState(pauseMenu);
		}
	}

	/**
	 * John Kramer: GameOver!
	 * Adam: Aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!
	 */
	private function gameOver()
	{
		var ret:Dynamic = callScripts('gameOver', []);
		if (ret != ScriptCore.Function_Stop)
		{
			boyfriend.stunned = true;
			persistentUpdate = persistentDraw = false;

			vocals.stop();
			FlxG.sound.music.stop();

			deathCounter += 1;

			openSubState(new GameOverSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if FUTURE_DISCORD_RCP
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + CoolUtil.difficultyString(storyDifficulty) + ")",
				iconP2.curCharacter);
			#end
		}
	}

	private function noteCalls(daNote:Note)
	{
		if (!daNote.mustPress && PreferencesData.centeredNotes)
		{
			daNote.active = true;
			daNote.visible = false;
		}
		else if (daNote.y > FlxG.height)
		{
			daNote.active = false;
			daNote.visible = false;
		}
		else
		{
			daNote.visible = true;
			daNote.active = true;
		}

		var strumX:Float = 0;
		var strumY:Float = 0;
		var strumScroll:Bool = false;
		var strumAngle:Float = 0;
		var strumAlpha:Float = 0;

		if (daNote.mustPress)
		{
			strumX = playerStrums.members[daNote.noteData].x;
			strumY = playerStrums.members[daNote.noteData].y;
			strumScroll = playerStrums.members[daNote.noteData].downScroll;
			strumAngle = playerStrums.members[daNote.noteData].angle;
			strumAlpha = playerStrums.members[daNote.noteData].alpha;
		}
		else
		{
			strumX = opponentStrums.members[daNote.noteData].x;
			strumY = opponentStrums.members[daNote.noteData].y;
			strumScroll = opponentStrums.members[daNote.noteData].downScroll;
			strumAngle = opponentStrums.members[daNote.noteData].angle;
			strumAlpha = opponentStrums.members[daNote.noteData].alpha;
		}

		strumX += daNote.offsetX;
		strumY += daNote.offsetY;
		strumAngle += daNote.offsetAngle;
		strumAlpha *= daNote.multAlpha;

		daNote.x = strumX;
		if (!daNote.sustainNote)
			daNote.angle = strumAngle;
		daNote.alpha = strumAlpha;

		var center:Float = strumY + (Note.swagWidth / 2);

		if (strumScroll)
		{
			daNote.y = strumY + (0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2));

			if (daNote.sustainNote)
			{
				daNote.flipY = true;
				daNote.y -= daNote.height - (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.SONG.speed, 2));

				if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect:FlxRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
					swagRect.height = (center - daNote.y) / daNote.scale.y;
					swagRect.y = daNote.frameHeight - swagRect.height;
					daNote.clipRect = swagRect;
				}
			}
		}
		else
		{
			daNote.y = strumY - (0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2));

			if (daNote.sustainNote
				&& daNote.y + daNote.offset.y * daNote.scale.y <= center
				&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
			{
				var swagRect:FlxRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
				swagRect.y = (center - daNote.y) / daNote.scale.y;
				swagRect.height -= swagRect.y;
				daNote.clipRect = swagRect;
			}
		}

		if (!daNote.mustPress && daNote.wasGoodHit)
			opponentNoteHit(daNote);

		if (daNote.mustPress && autoplayMode)
		{
			if (daNote.sustainNote)
			{
				if (daNote.canBeHit)
					goodNoteHit(daNote);
			}
			else if (daNote.strumTime <= Conductor.songPosition || (daNote.sustainNote && daNote.canBeHit && daNote.mustPress))
				goodNoteHit(daNote);
		}

		var doKill:Bool = daNote.y < -daNote.height;
		if (strumScroll)
			doKill = daNote.y > FlxG.height;

		if (doKill)
		{
			if (daNote.mustPress && !autoplayMode && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
				noteMiss();

			daNote.active = false;
			daNote.visible = false;

			destroyNote(daNote);
		}
	}

	private function destroyNote(daNote:Note)
	{
		daNote.kill();
		notes.remove(daNote, true);
		daNote.destroy();
	}

	private function cameraMovement(isDad:Bool = false)
	{
		if (isDad)
		{
			camFollow.x = dad.getMidpoint().x + camFollowDad[0];
			camFollow.y = dad.getMidpoint().y + camFollowDad[1];
			callScripts('camearaFollow', ['dad']);
		}
		else
		{
			camFollow.x = boyfriend.getMidpoint().x + camFollowBoyfriend[0];
			camFollow.y = boyfriend.getMidpoint().y + camFollowBoyfriend[1];
			callScripts('camearaFollow', ['boyfriend']);
		}
	}

	private function endSong():Void
	{
		seenCutscene = false;
		autoplayMode = false;
		deathCounter = 0;
		seenCutscene = false;
		canPause = false;
		FlxG.sound.music.volume = vocals.volume = 0;

		#if mobile
		mobileControls.visible = false;
		#end

		var ret:Dynamic = callScripts('endSong', []);
		if (ret != ScriptCore.Function_Stop)
		{
			if (SONG.validScore)
				HighScore.saveScore(SONG.song, Math.round(score), storyDifficulty);

			if (isStoryMode)
			{
				campaignScore += Math.round(score);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					StoryMenuState.weekCompleted.set(StoryMenuState.loadedWeekList[storyWeek], true);

					if (SONG.validScore)
						HighScore.saveWeekScore(StoryMenuState.loadedWeekList[storyWeek], campaignScore, storyDifficulty);

					FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
					FlxG.save.flush();

					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					MusicBeatState.switchState(new StoryMenuState());
				}
				else
				{
					FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadJson(HighScore.formatSong(PlayState.storyPlaylist[0].toLowerCase(), storyDifficulty),
						PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();
					MusicBeatState.switchState(new PlayState());
				}
			}
			else
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				MusicBeatState.switchState(new FreeplayState());
			}
		}
	}

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
		vocals.volume = 1;

		var addedScore:Int = 350;
		var daRating:String = 'sick';

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			addedScore = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			addedScore = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			addedScore = 200;
		}

		if (daRating == 'sick' && PreferencesData.noteSplashes)
		{
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			grpNoteSplashes.add(splash);
		}

		if (!practiceMode && !autoplayMode)
			score += addedScore;

		var rating:FlxSprite = new FlxSprite(0, 0);
		if (!PlayState.isPixelAssets)
			rating.loadGraphic(Paths.image('ui/default/' + daRating));
		else
			rating.loadGraphic(Paths.image('ui/pixel/' + daRating));
		rating.screenCenter();
		rating.x = (FlxG.width * 0.55) - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		if (!PlayState.isPixelAssets)
			rating.setGraphicSize(Std.int(rating.width * 0.7));
		else
			rating.setGraphicSize(Std.int(rating.width * 6 * 0.7));

		rating.updateHitbox();
		rating.cameras = [camHUD];
		add(rating);

		var comboSpr:FlxSprite = new FlxSprite(0, 0);
		if (!PlayState.isPixelAssets)
			comboSpr.loadGraphic(Paths.image('ui/default/combo'));
		else
			comboSpr.loadGraphic(Paths.image('ui/pixel/combo'));
		comboSpr.screenCenter();
		comboSpr.x = FlxG.width * 0.55;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);

		if (!PlayState.isPixelAssets)
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		else
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 6 * 0.7));

		comboSpr.updateHitbox();
		comboSpr.cameras = [camHUD];
		add(comboSpr);

		var comboSplit:Array<String> = Std.string(combo).split('');

		var seperatedScore:Array<Int> = [];
		for (i in 0...comboSplit.length)
			seperatedScore.push(Std.parseInt(comboSplit[i]));

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite(0, 0);
			if (!PlayState.isPixelAssets)
				numScore.loadGraphic(Paths.image('ui/default/num' + Std.int(i)));
			else
				numScore.loadGraphic(Paths.image('ui/pixel/num' + Std.int(i)));
			numScore.screenCenter();
			numScore.x = (FlxG.width * 0.55) + (43 * daLoop) - 90;
			numScore.y += 80;
			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (!PlayState.isPixelAssets)
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			else
				numScore.setGraphicSize(Std.int(numScore.width * 6));

			numScore.updateHitbox();
			numScore.cameras = [camHUD];
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		var holdingArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var controlArray:Array<Bool> = [
			controls.NOTE_LEFT_P,
			controls.NOTE_DOWN_P,
			controls.NOTE_UP_P,
			controls.NOTE_RIGHT_P
		];

		if (holdingArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.sustainNote && daNote.canBeHit && daNote.mustPress && holdingArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		if (controlArray.contains(true) && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];
			var removeList:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (ignoreList.contains(daNote.noteData))
					{
						for (possibleNote in possibleNotes)
						{
							if (possibleNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - possibleNote.strumTime) < 10)
								removeList.push(daNote);
							else if (possibleNote.noteData == daNote.noteData && daNote.strumTime < possibleNote.strumTime)
							{
								possibleNotes.remove(possibleNote);
								possibleNotes.push(daNote);
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						ignoreList.push(daNote.noteData);
					}
				}
			});

			for (badNote in removeList)
			{
				badNote.kill();
				notes.remove(badNote, true);
				badNote.destroy();
			}

			possibleNotes.sort(function(note1:Note, note2:Note)
			{
				return Std.int(note1.strumTime - note2.strumTime);
			});

			if (possibleNotes.length > 0)
			{
				for (i in 0...controlArray.length)
					if (!PreferencesData.ghostTapping && (controlArray[i] && !ignoreList.contains(i)))
						badNoteHit();

				for (possibleNote in possibleNotes)
					if (controlArray[possibleNote.noteData])
						goodNoteHit(possibleNote);
			}
			else if (!PreferencesData.ghostTapping)
				badNoteHit();
		}

		if (boyfriend.animation.curAnim != null
			&& boyfriend.holdTimer > 0.001 * boyfriend.singDuration * Conductor.stepCrochet
			&& !holdingArray.contains(true)
			&& boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			boyfriend.dance();

		playerStrums.forEach(function(spr:StrumNote)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}

			if (!holdingArray[spr.ID])
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		});
	}

	private function noteMiss(direction:Int = 0)
	{
		if (!boyfriend.stunned)
		{
			if (health <= minHealth && practiceMode)
				health = minHealth;
			else
				health -= 0.04;

			if (combo > 5 && gf.animation.getByName('sad') != null)
				gf.playAnim('sad');

			combo = 0;
			comboBreaks++;

			if (!practiceMode)
				score -= 10;

			FlxG.sound.play(Paths.sound('missnote' + FlxG.random.int(1, 3)), FlxG.random.float(0.1, 0.2));

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (Math.abs(direction) % 4)
			{
				case 0:
					if (boyfriend.animation.getByName('singLEFTmiss') != null)
						boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					if (boyfriend.animation.getByName('singDOWNmiss') != null)
						boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					if (boyfriend.animation.getByName('singUPmiss') != null)
						boyfriend.playAnim('singUPmiss', true);
				case 3:
					if (boyfriend.animation.getByName('singRIGHTmiss') != null)
						boyfriend.playAnim('singRIGHTmiss', true);
			}

			vocals.volume = 0;

			callScripts('noteMiss', [direction]);
		}
	}

	private function badNoteHit()
	{
		if (controls.NOTE_LEFT_P)
			noteMiss(0);
		if (controls.NOTE_DOWN_P)
			noteMiss(1);
		if (controls.NOTE_UP_P)
			noteMiss(2);
		if (controls.NOTE_RIGHT_P)
			noteMiss(3);
	}

	private function goodNoteHit(daNote:Note):Void
	{
		if (!daNote.wasGoodHit)
		{
			if (!daNote.sustainNote)
			{
				popUpScore(daNote);
				combo += 1;
			}

			if (daNote.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (Math.abs(daNote.noteData) % 4)
			{
				case 0:
					if (boyfriend.animation.getByName('singLEFT') != null)
						boyfriend.playAnim('singLEFT', true);
				case 1:
					if (boyfriend.animation.getByName('singDOWN') != null)
						boyfriend.playAnim('singDOWN', true);
				case 2:
					if (boyfriend.animation.getByName('singUP') != null)
						boyfriend.playAnim('singUP', true);
				case 3:
					if (boyfriend.animation.getByName('singRIGHT') != null)
						boyfriend.playAnim('singRIGHT', true);
			}

			var time:Float = 0.15;
			if (daNote.sustainNote && !daNote.animation.curAnim.name.endsWith('end'))
				time += 0.15;

			playerStrums.forEach(function(spr:StrumNote)
			{
				if (Math.abs(daNote.noteData) == spr.ID)
				{
					spr.playAnim('confirm', true);
					if (autoplayMode)
						spr.resetAnim = time;
					else
						spr.resetAnim = 0;
				}
			});

			daNote.wasGoodHit = true;
			vocals.volume = 1;

			callScripts('goodNoteHit', [daNote]);

			if (!daNote.sustainNote)
				destroyNote(daNote);
		}
	}

	private function opponentNoteHit(daNote:Note):Void
	{
		var altAnim:String = "";

		if ((SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) || daNote.altNote)
			altAnim = '-alt';

		switch (Math.abs(daNote.noteData) % 4)
		{
			case 0:
				if (dad.animation.getByName('singLEFT' + altAnim) != null)
					dad.playAnim('singLEFT' + altAnim, true);
			case 1:
				if (dad.animation.getByName('singDOWN' + altAnim) != null)
					dad.playAnim('singDOWN' + altAnim, true);
			case 2:
				if (dad.animation.getByName('singUP' + altAnim) != null)
					dad.playAnim('singUP' + altAnim, true);
			case 3:
				if (dad.animation.getByName('singRIGHT' + altAnim) != null)
					dad.playAnim('singRIGHT' + altAnim, true);
		}

		dad.holdTimer = 0;

		var time:Float = 0.15;
		if (daNote.sustainNote && !daNote.animation.curAnim.name.endsWith('end'))
			time += 0.15;

		opponentStrums.forEach(function(spr:StrumNote)
		{
			if (Math.abs(daNote.noteData) == spr.ID)
			{
				spr.playAnim('confirm', true);
				spr.resetAnim = time;
			}
		});

		vocals.volume = 1;

		callScripts('opponentNoteHit', [daNote]);

		if (!daNote.sustainNote)
			destroyNote(daNote);
	}

	private var danced:Bool = false;

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		super.stepHit();

		if (Math.abs(FlxG.sound.music.time - Conductor.songPosition) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - Conductor.songPosition) > 20))
			resyncVocals();

		if (curStep == lastStepHit)
			return;

		lastStepHit = curStep;
		callScripts('stepHit', [curStep]);

		#if FUTURE_DISCORD_RCP
		DiscordClient.changePresence(detailsText, SONG.song
			+ " ("
			+ CoolUtil.difficultyString(storyDifficulty)
			+ ")", iconP2.curCharacter, true,
			FlxG.sound.music.length
			- Conductor.songPosition);
		#end
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if (lastBeatHit >= curBeat)
			return;

		if (generatedMusic)
			notes.sort(FlxSort.byY, PreferencesData.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP1.updateHitbox();

		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		iconP2.updateHitbox();

		if (curBeat % Math.round(gfSpeed * 2) == 0 && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
			gf.dance();

		if (curBeat % 2 == 0 && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
			boyfriend.dance();

		if (curBeat % 2 == 0 && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
			dad.dance();

		lastBeatHit = curBeat;
		callScripts('beatHit', [curBeat]);
	}

	override function destroy()
	{
		scriptArray = [];
		defaultPlayerStrumX = [];
		defaultPlayerStrumY = [];
		defaultOpponentStrumX = [];
		defaultOpponentStrumY = [];

		callScripts('destroy', []);

		super.destroy();
	}

	private function callScripts(funcName:String, args:Array<Dynamic>):Dynamic
	{
		var value:Dynamic = ScriptCore.Function_Continue;

		for (i in 0...scriptArray.length)
		{
			final call:Dynamic = scriptArray[i].executeFunc(funcName, args);
			final bool:Bool = call == ScriptCore.Function_Continue;
			if (!bool && call != null)
				value = call;
		}

		return value;
	}

	private function setScripts(name:String, val:Dynamic)
		for (i in 0...scriptArray.length)
			scriptArray[i].setVariable(name, val);
}
