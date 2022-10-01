package;

import flixel.FlxG;

class HighScore
{
	public static var songScores:Map<String, Int> = [];
	public static var weekScores:Map<String, Int> = [];

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		}
		else
			setScore(daSong, score);
	}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score)
				setScore(daWeek, score);
		}
		else
			setScore(daWeek, score);
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';

		return daSong;
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	static function setScore(song:String, score:Int):Void
	{
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	public static function getWeekScore(week, diff:Int):Int
	{
		if (!weekScores.exists(formatSong(week, diff)))
			setWeekScore(formatSong(week, diff), 0);

		return weekScores.get(formatSong(week, diff));
	}

	static function setWeekScore(song:String, score:Int):Void
	{
		weekScores.set(song, score);
		FlxG.save.data.weekScores = songScores;
		FlxG.save.flush();
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;

		if (FlxG.save.data.weekScores != null)
			weekScores = FlxG.save.data.weekScores;
	}
}
