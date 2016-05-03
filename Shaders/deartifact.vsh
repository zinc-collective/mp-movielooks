attribute vec4 position;
//attribute vec4 color;
attribute vec2 texcoord;

//uniform mat4 modelViewProjectionMatrix;

//varying vec4 colorVarying;
varying vec2 texCoord0;

void main()
{
	//gl_Position = modelViewProjectionMatrix * position;
	gl_Position = position;
//	colorVarying = color;
	texCoord0 = texcoord;
}
