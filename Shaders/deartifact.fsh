#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

//varying vec4 colorVarying;
varying vec2 texCoord0;
uniform sampler2D srcSampler;
uniform sampler2D scaledImg;
uniform sampler2D specialImg;
uniform float looksBrightness;
uniform bool flipPixel;

#define oneSixth (0.16666667)
#define oneThird (0.33333333)
#define oneHalf (0.5)
#define twoThird (0.66666667)
#define fiveSixth (0.83333333)
#define eps (0.05)

/*
** Hue, saturation, luminance
*/

float getLuminance(vec3 color)
{
	float fmin = min(min(color.r, color.g), color.b);    //Min. value of RGB
	float fmax = max(max(color.r, color.g), color.b);    //Max. value of RGB
	return (fmax + fmin) * 0.5;
}

vec3 RGBToHSL(vec3 color)
{
	vec3 hsl; // init to 0 to avoid warnings ? (and reverse if + remove first part)
	
	float fmin = min(min(color.r, color.g), color.b);    //Min. value of RGB
	float fmax = max(max(color.r, color.g), color.b);    //Max. value of RGB
	float delta = fmax - fmin;             //Delta RGB value
	float fminaddmax = (fmax + fmin);
	hsl.z = fminaddmax * 0.5; // Luminance

	if (delta == 0.0)		//This is a gray, no chroma...
	{
		hsl.x = 0.0;	// Hue
		hsl.y = 0.0;	// Saturation
	}
	else                                    //Chromatic data...
	{
		if (hsl.z < 0.5)
			hsl.y = delta / fminaddmax; // Saturation
		else
			hsl.y = delta / (2.0 - fminaddmax); // Saturation
		
//		float deltaR = (((fmax - color.r) / 6.0) + (delta / 2.0)) / delta;
//		float deltaG = (((fmax - color.g) / 6.0) + (delta / 2.0)) / delta;
//		float deltaB = (((fmax - color.b) / 6.0) + (delta / 2.0)) / delta;
//
//		if (color.r == fmax )
//			hsl.x = deltaB - deltaG; // Hue
//		else if (color.g == fmax)
//			hsl.x = (1.0 / 3.0) + deltaR - deltaB; // Hue
//		else if (color.b == fmax)
//			hsl.x = (2.0 / 3.0) + deltaG - deltaR; // Hue

		float halfDelta = delta * 0.5;
		float invDelta = 1.0 / delta;

		float deltaR = (((fmax - color.r) * oneSixth) + halfDelta) * invDelta;
		float deltaG = (((fmax - color.g) * oneSixth) + halfDelta) * invDelta;
		float deltaB = (((fmax - color.b) * oneSixth) + halfDelta) * invDelta;

		if (color.r == fmax )
			hsl.x = deltaB - deltaG; // Hue
		else if (color.g == fmax)
			hsl.x = oneThird + deltaR - deltaB; // Hue
		else if (color.b == fmax)
			hsl.x = twoThird + deltaG - deltaR; // Hue

		if (hsl.x < 0.0)
			hsl.x += 1.0; // Hue
		else if (hsl.x > 1.0)
			hsl.x -= 1.0; // Hue
	}

	return hsl;
}

vec3 HueToRGB(float f1, float f2, float hue)
{
	if (hue < 0.0)
		hue += 1.0;
	else if (hue > 1.0)
		hue -= 1.0;
//	float res;
//	if ((6.0 * hue) < 1.0)
//		res = f1 + (f2 - f1) * 6.0 * hue;
//	else if ((2.0 * hue) < 1.0)
//		res = f2;
//	else if ((3.0 * hue) < 2.0)
//		res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
//	else
//		res = f1;
//	return res;
	vec3 res;
	if (hue < oneSixth)
	{
		res.b = f1;
		res.g = f1 + (f2 - f1) * 6.0 * hue;
		res.r = f2;
	}
	else if (hue < oneThird )
	{
		res.b = f1;
		res.g = f2;
		res.r = f1 + (f2 - f1) * (oneThird - hue) * 6.0;		
	}
	else if ( hue < oneHalf )
	{
		res.b = f1 + (f2 - f1) * 6.0 * (hue - oneThird);
		res.g = f2;
		res.r = f1;		
	}
	else if (hue < twoThird )
	{
		res.b = f2;
		res.g = f1 + (f2 - f1) * (twoThird - hue) * 6.0;
		res.r = f1;		
	}
	else if (hue < fiveSixth )
	{
		res.b = f2;
		res.g = f1;
		res.r = f1 + (f2 - f1) * 6.0 * (hue - twoThird);
	}
	else 
	{
		res.b = f1 + (f2 - f1) * (1.0 - hue) * 6.0;
		res.g = f1;
		res.r = f2;
	}
	return res;
}

vec4 HSLToRGB(vec3 hsl)
{
	vec3 rgb;
	
	if (hsl.y == 0.0)
		rgb = vec3(hsl.z); // Luminance
	else
	{
		float f2;
		
		if (hsl.z < 0.5)
			f2 = hsl.z * (1.0 + hsl.y);
		else
			f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
			
		float f1 = 2.0 * hsl.z - f2;
		
//		float oneThird = 1.0 / 3.0;
//		rgb.r = HueToRGB(f1, f2, hsl.x + oneThird);
//		rgb.g = HueToRGB(f1, f2, hsl.x);
//		rgb.b = HueToRGB(f1, f2, hsl.x - oneThird);
		rgb = HueToRGB(f1, f2, hsl.x);
	}
	
	return vec4(rgb, 1.0);
}

vec4 BlendColor(vec3 base, vec3 blend)
{
	float blendLum = getLuminance(blend);
	float baseLum = getLuminance(base);
	float diff = baseLum - blendLum;
	if ( (diff > eps) || (diff < -eps) )
	{
		vec3 blendHSL = RGBToHSL(blend);
		return HSLToRGB(vec3(blendHSL.r, blendHSL.g, baseLum));
	}
	else
	{
		return vec4(base, 1.0);
	}
}

void main()
{
	// original Image
	vec4 srcColor = texture2D(srcSampler,texCoord0);

	// scaled Image
	vec4 scaledColor = texture2D(scaledImg,texCoord0);

	vec4 deartifacted;
	if (flipPixel)
	{
		deartifacted = BlendColor(vec3(srcColor.b, srcColor.g, srcColor.r), vec3(scaledColor.b, scaledColor.g, scaledColor.r));
	}
	else 
	{
		deartifacted = BlendColor(vec3(srcColor.r, srcColor.g, srcColor.b), vec3(scaledColor.r, scaledColor.g, scaledColor.b));
	}

	float red;
	float green;
	float blue;
	float blend;
	
	if (looksBrightness<0.5)
	{
		blend = (0.5 - looksBrightness) * 2.0;

		// apply darken adjustment
		//
		red = texture2D(specialImg,vec2(deartifacted.r*0.2, 0.25)).x;
		green = texture2D(specialImg,vec2(deartifacted.g*0.2, 0.25)).y;
		blue = texture2D(specialImg,vec2(deartifacted.b*0.2, 0.25)).z;
	}
	else 
	{
		blend = (looksBrightness - 0.5) * 2.0;
		
		// apply brighten adjustment
		//
		red = texture2D(specialImg,vec2(deartifacted.r*0.2, 0.35)).x;
		green = texture2D(specialImg,vec2(deartifacted.g*0.2, 0.35)).y;
		blue = texture2D(specialImg,vec2(deartifacted.b*0.2, 0.35)).z;
	}

    gl_FragColor = vec4(mix(vec3(deartifacted.r, deartifacted.g, deartifacted.b),vec3(red, green, blue),blend),1.0);
}