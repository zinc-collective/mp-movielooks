#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

//varying vec4 colorVarying;
varying vec2 texCoord0;
uniform sampler2D srcQuarter;
uniform sampler2D lutSampler;  //width=32x17, height=32
uniform float looksStrengthFast;
uniform float looksBrightnessFast;

vec4 get3DLUTValue( vec4 inColor )
{
	float paletteWidth = 0.0018382353; // 1/32x17
	float paletteHeight = 0.03125;	// 1/32

	float offsetB = floor( inColor.b * 16.0 );
	float remainderB = inColor.b * 16.0 - offsetB;

	float x1 = (0.5 * paletteWidth) + ( offsetB * 32.0 + inColor.r * 16.0  ) * paletteWidth ;
	float y1 = (0.5 * paletteHeight) + inColor.g * 16.0 * paletteHeight ;	
	vec4 lut1Color = texture2D(lutSampler,vec2(x1, y1));
	
	if (inColor.b < 1.0)
	{
		x1 += 32.0 * paletteWidth;
		vec4 lut2Color = texture2D(lutSampler,vec2(x1, y1));
		lut1Color = vec4(mix(vec3(lut1Color.r,lut1Color.g,lut1Color.b),vec3(lut2Color.r,lut2Color.g,lut2Color.b),remainderB),1.0);
	}
	return lut1Color;
}

void main()
{
	// original Image
	//
	vec4 srcColor = texture2D(srcQuarter,texCoord0);
	
	float red;
	float green;
	float blue;
	float blend;
	if (looksBrightnessFast<0.5)
	{
		blend = (0.5 - looksBrightnessFast) * 2.0;

		// apply darken adjustment
		//
		red = texture2D(lutSampler,vec2(0.000919+srcColor.b*0.46875, 0.64)).x;
		green = texture2D(lutSampler,vec2(0.000919+srcColor.g*0.46875, 0.64)).x;
		blue = texture2D(lutSampler,vec2(0.000919+srcColor.r*0.46875, 0.64)).x;
	}
	else 
	{
		blend = (looksBrightnessFast - 0.5) * 2.0;
		
		// apply brighten adjustment
		//
		red = texture2D(lutSampler,vec2(0.000919+srcColor.b*0.46875, 0.89)).x;
		green = texture2D(lutSampler,vec2(0.000919+srcColor.g*0.46875, 0.89)).x;
		blue = texture2D(lutSampler,vec2(0.000919+srcColor.r*0.46875, 0.89)).x;
	}

	// 3D LUT
	vec4 looksColor = get3DLUTValue( vec4(mix(vec3(srcColor.b, srcColor.g, srcColor.r),vec3(red, green, blue),blend),1.0) );
	
	// apply strength adjustment
	//
	//gl_FragColor = vec4(looksColor.b, looksColor.g, looksColor.r, 1.0);
	gl_FragColor = vec4(mix(vec3(blue, green, red), vec3(looksColor.b, looksColor.g, looksColor.r), looksStrengthFast), 1.0);
//	gl_FragColor = texture2D(lutSampler,vec2(texCoord0.x*0.47058824, 0.5 + texCoord0.y * 0.5));
}
