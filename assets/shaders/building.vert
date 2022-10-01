#pragma header

attribute float alpha;
attribute vec4 colorMultiplier;
attribute vec4 colorOffset;
uniform bool hasColorTransform;

void main(void)
{
	#pragma body
	openfl_Alphav = openfl_Alpha * alpha;
	
	if (hasColorTransform)
	{
		openfl_ColorOffsetv = colorOffset / 255.0;
		openfl_ColorMultiplierv = colorMultiplier;
	}
}