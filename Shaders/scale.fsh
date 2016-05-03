//
//  Shader.fsh
//  MobileLooks
//
//  Created by George on 7/19/10.
//  Copyright RED/SAFI 2010. All rights reserved.
//

#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

//varying vec4 colorVarying;
varying vec2 texCoord0;
uniform sampler2D sampler;

void main()
{
//	vec4 color = texture2D(imgSampler,texCoord0);
//	float red = texture2D(lutSampler,vec2(color.x,0)).x;
//	float green = texture2D(lutSampler,vec2(color.y,0)).y;
//	float blue = texture2D(lutSampler,vec2(color.z,0)).z;
	gl_FragColor = texture2D(sampler, texCoord0);
}