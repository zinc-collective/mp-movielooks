//
//  Shader.vsh
//  MobileLooks
//
//  Created by George on 7/19/10.
//  Copyright RED/SAFI 2010. All rights reserved.
//

attribute vec4 position;
//attribute vec4 color;
attribute vec2 texcoord;

//uniform mat4 modelViewProjectionMatrix;

//uniform sampler2D sampler;

//varying vec4 colorVarying;
varying vec2 texCoord0;

void main()
{
	gl_Position = position;
	texCoord0 = texcoord;
//	colorVarying = color;	
}