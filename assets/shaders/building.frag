#pragma header

uniform float alphaShit;

void main()
{
	#pragma body
	vec4 col = flixel_texture2D(bitmap, openfl_TextureCoordv);

	if (col.a > 0.0)
		col -= alphaShit;

	gl_FragColor = col;
}