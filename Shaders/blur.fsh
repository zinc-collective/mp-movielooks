//
//  Shader.fsh
//  MobileLooks
//
//  Created by George on 7/19/10.
//  Copyright RED/SAFI 2010. All rights reserved.
//
//bret hd
#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

//varying vec4 colorVarying;
varying vec2 texCoord0;
uniform int factor;
uniform int radius;
uniform sampler2D sampler;

vec4 blurMe()
{
		float pixelWidth = float(factor) / 1280.0 ;
		float pixelHeight = float(factor) / 720.0 ;
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
					
				sum += texture2D(sampler, vec2(xx, yy));
				x += pixelWidth;
			}
			y += pixelHeight;
		}
 		return sum * avgFactor;
}

void main()
{
//	vec4 color = texture2D(imgSampler,texCoord0);
//	float red = texture2D(lutSampler,vec2(color.x,0)).x;
//	float green = texture2D(lutSampler,vec2(color.y,0)).y;
//	float blue = texture2D(lutSampler,vec2(color.z,0)).z;
	gl_FragColor = blurMe();
	//gl_FragColor = texture2D(sampler, texCoord0);
}