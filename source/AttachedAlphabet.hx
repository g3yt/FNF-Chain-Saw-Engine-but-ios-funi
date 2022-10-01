package;

import flixel.FlxSprite;

/**
 * Class from Psych Engine used here for controls menu.
 * Credits: Shadow Mario.
 */
class AttachedAlphabet extends Alphabet
{
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var sprTracker:FlxSprite;

	public function new(text:String = "", ?offsetX:Float = 0, ?offsetY:Float = 0, ?bold = false)
	{
		super(0, 0, text, bold);
		isMenuItem = false;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}

	override function update(elapsed:Float)
	{
		if (sprTracker != null)
			setPosition(sprTracker.x + offsetX, sprTracker.y + offsetY);

		super.update(elapsed);
	}
}
