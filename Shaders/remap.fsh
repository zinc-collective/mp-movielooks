#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

//varying vec4 colorVarying;
varying vec2 texCoord0;
uniform sampler2D specialImg;
uniform sampler2D tempImg;


void main()
{
	// source for remap is located in top 40% of temp texture
	//
	vec4 color1 = texture2D(tempImg, texCoord0);

	// remap LUT is located at the 90% y location and the the left 20% of special texture (i.e. rectangle (0,720) to (256,720) of the 1280x800 texture)
	//
	float red = texture2D(specialImg,vec2(color1.x*0.2, 0.15)).x;
	float green = texture2D(specialImg,vec2(color1.y*0.2, 0.15)).y;
	float blue = texture2D(specialImg,vec2(color1.z*0.2, 0.15)).z;
	gl_FragColor = vec4(red,green,blue,1);
}