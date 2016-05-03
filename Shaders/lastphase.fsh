#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif
//bret hd
//varying vec4 colorVarying;
varying vec2 texCoord0;
uniform sampler2D specialImg;
uniform sampler2D remapTexture;
uniform sampler2D deartifactTexture;
uniform sampler2D blurHiliteTexture;
uniform sampler2D overlayImg;
uniform float looksStrength;
uniform float diffuseOpacity;
uniform float preDesatAmount;
uniform float vignetteAmount;
uniform bool doOverlay;
uniform bool flipPixel2;
uniform bool doQuickRender2;
uniform float looksBrightness2;
uniform	float diffusionSize;


/*
** Screen Blend
*/
#define BlendScreenf(base, blend) 		(1.0 - ((1.0 - base) * (1.0 - blend)))
#define Blend(base, blend, funcf) 		vec4(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b), blend.a)
#define BlendScreen(base, blend) 		Blend(base, blend, BlendScreenf)

/*
** Desaturation
*/
vec4 Desaturate(vec3 color, float Desaturation)
{
	vec3 grayXfer = vec3(0.3, 0.59, 0.11);
	vec3 gray = vec3(dot(grayXfer, color));
	return vec4(mix(color, gray, Desaturation), 1.0);
}

vec4 get3DLUTValue( vec4 inColor )
{
	float paletteWidth = 1.0 / 1280.0;
	float paletteHeight = 1.0 / 1280.0;

	float offsetB = floor( inColor.b * 16.0 );
	float remainderB = inColor.b * 16.0 - offsetB;

	float x1 = (512.5 * paletteWidth) + ( offsetB * 32.0 + inColor.r * 16.0  ) * paletteWidth ;
	float y1 = (0.5 * paletteHeight) + inColor.g * 16.0 * paletteHeight ;	
	vec4 lut1Color = texture2D(specialImg,vec2(x1, y1));
	
	if (inColor.b < 1.0)
	{
		x1 += 32.0 * paletteWidth;
		vec4 lut2Color = texture2D(specialImg,vec2(x1, y1));
		lut1Color = vec4(mix(vec3(lut1Color.r,lut1Color.g,lut1Color.b),vec3(lut2Color.r,lut2Color.g,lut2Color.b),remainderB),1.0);
	}
	return lut1Color;
}

/*
vec4 blurMe(int radius)
{
		float pixelWidth = 1.0 / 1280.0;
		float pixelHeight = 1.0 / 720.0;
		vec4 sum = vec4(0.0, 0.0, 0.0, 0.0);
		
		float x = 0.0;
		float y = 0.0;
		float xx = 0.0;
		float yy = 0.0;
		float avgFactor = 1.0 / float((radius*2 + 1)*(radius*2 + 1));
		
		y = float(-radius) * pixelHeight;
		for (int i = -radius; i <= radius; i++)
		{
			x = float(-radius) * pixelWidth;
			for (int j = -radius; j <= radius; j++)
			{
				xx = texCoord0.x + x;
				yy = texCoord0.y + y;
				if ( xx < 0.0 )
					xx = 0.0;
				else if ( xx > 1.0 )
					xx = 1.0;
				if ( yy < 0.0 )
					yy = 0.0;
				else if ( yy > 1.0 )
					yy = 1.0;
					
				sum += texture2D(blurHiliteTexture, vec2(xx, yy));
				x += pixelWidth;
			}
			y += pixelHeight;
		}
 		return sum * avgFactor;
}
*/

void main()
{
	vec4 blurHilite = texture2D(remapTexture, texCoord0);		

	// Deartifact Image: in top 40% of the temp texture
	//
	vec4 deartifact = texture2D(deartifactTexture, texCoord0);

	vec4 preLUT = deartifact;
	if ( !doQuickRender2 )
	{
		// Blurred hilite Image: in second 40% of the temp texture
		//
		if ( diffusionSize > 0.0 )
		{
			blurHilite = texture2D(blurHiliteTexture, texCoord0);
		}

		
		//vec4 blurHilite = blurMe(2);
		
		// Screen blended
		//
		vec4 screen = BlendScreen(blurHilite, deartifact);
		float diffOpac = 0.01 * diffuseOpacity;
		screen = vec4(mix(vec3(screen.r, screen.g, screen.b),vec3(blurHilite.r, blurHilite.g, blurHilite.b), diffOpac),1.0);

		// De-saturation 15%
		//
		vec4 deSatA = Desaturate(vec3(screen.r, screen.g, screen.b), 0.01 * preDesatAmount);

		// De-saturation 20% on darken image: darken LUT is located in 0.95 y location of the special texture
		//
		float red = texture2D(specialImg,vec2(deSatA.r*0.2, 0.05)).x;
		float green = texture2D(specialImg,vec2(deSatA.g*0.2, 0.05)).y;
		float blue = texture2D(specialImg,vec2(deSatA.b*0.2, 0.05)).z;
		vec4 deSatB = Desaturate(vec3(red, green, blue), 0.2);

		// Load Vignette Image: located in top 90% of the special texture
		vec4 vignette = texture2D(specialImg, vec2(texCoord0.x, 0.4375 + texCoord0.y * 0.5625) );

		// Blend de-sat images
		//
		vec4 blendColor = vec4(mix(vec3(deSatA.r,deSatA.g,deSatA.b), vec3(deSatB.r,deSatB.g,deSatB.b), vignetteAmount * (1.0 - vignette.r)), 1.0);

		// A over B
		//
		preLUT = blendColor;
		if (doOverlay)
		{
			// Overlay Image: located in bottom 50% of the source texture
			//
			vec4 overlay = texture2D(overlayImg, texCoord0);

			preLUT = vec4(mix(vec3(blendColor.r, blendColor.g, blendColor.b), vec3(overlay.r, overlay.g, overlay.b), overlay.a), 1.0);
		}
	}
	else 
	{		
		//deartifact texture 
		float red;
		float green;
		float blue;
		float blend;
		
		vec4 rgb_deartifact;
		if(flipPixel2)
			rgb_deartifact = vec4(deartifact.b, deartifact.g, deartifact.r,1.0);
		else
			rgb_deartifact = vec4(deartifact.r, deartifact.g, deartifact.b,1.0);

		if (looksBrightness2<0.5)
		{
			blend = (0.5 - looksBrightness2) * 2.0;

			// apply darken adjustment
			//
			red = texture2D(specialImg,vec2(rgb_deartifact.r*0.2, 0.25)).x;
			green = texture2D(specialImg,vec2(rgb_deartifact.g*0.2, 0.25)).y;
			blue = texture2D(specialImg,vec2(rgb_deartifact.b*0.2, 0.25)).z;
		}
		else 
		{
			blend = (looksBrightness2 - 0.5) * 2.0;
			
			// apply brighten adjustment
			//
			red = texture2D(specialImg,vec2(rgb_deartifact.r*0.2, 0.35)).x;
			green = texture2D(specialImg,vec2(rgb_deartifact.g*0.2, 0.35)).y;
			blue = texture2D(specialImg,vec2(rgb_deartifact.b*0.2, 0.35)).z;
		}
		
		if (flipPixel2)
		{
			preLUT = vec4(mix(vec3(rgb_deartifact.r, rgb_deartifact.g, rgb_deartifact.b),vec3(red, green, blue),blend),1.0);
		}
		else
		{
			preLUT = vec4(mix(vec3(deartifact.r, deartifact.g, deartifact.b),vec3(red, green, blue),blend),1.0);
		}
	}
 
	// 3D LUT
	vec4 looksColor = get3DLUTValue( preLUT );

//preLUT = blurHilite;
//looksColor = blurHilite;
		
	// apply strength adjustment
	//
	if (flipPixel2)
	{
		gl_FragColor = vec4(mix(vec3(preLUT.b, preLUT.g, preLUT.r), vec3(looksColor.b, looksColor.g, looksColor.r), looksStrength), 1.0);
	}
	else 
	{
		gl_FragColor = vec4(mix(vec3(preLUT.r, preLUT.g, preLUT.b), vec3(looksColor.r, looksColor.g, looksColor.b), looksStrength), 1.0);
	}
}
