
#ifndef FASTBLUR
#define FASTBLUR

#include <OpenGLES/ES1/gl.h>

GLubyte* fast_blur(GLubyte* _srcImg, int s_radius, int width, int height);

#endif /* FASTBLUR */