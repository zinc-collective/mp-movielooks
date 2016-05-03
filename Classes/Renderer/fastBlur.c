#include <stdlib.h>
#include "RenderDefs.h"
#include "fastBlur.h"

GLubyte* fast_blur(GLubyte* _srcImg, int s_radius, int width, int height)
{
	int kernel_size = s_radius*2 + 1;
	int kernel_area = kernel_size * kernel_size;
	
	int theWidth = width;
	int theHeight = height;
	
	GLuint**tmpRows = (GLuint**) malloc(kernel_size * sizeof(GLuint*));
	if (!tmpRows)
	{
		return NULL;
	}
	
	for (int i=0; i<kernel_size; i++)
	{
		tmpRows[i] = (GLuint *)malloc(theWidth * 3 * sizeof(GLuint));
		if (!tmpRows[i])
		{
			for (int j=i-1; j>=0; j--)
				free(tmpRows[j]);
			free(tmpRows);
			return NULL;
		}
	}
	
	GLuint *subTotalHead, *subtotal;
	subTotalHead = subtotal = (GLuint *)malloc(theWidth * 3 * sizeof(GLuint));
	if (!subtotal)
	{
		for (int i=0; i<kernel_size; i++)
		{
			free(tmpRows[i]);
		}
		free(tmpRows);
		return NULL;
	}
	
	// Clear accumlation buffer
	//
	for (int j=0; j<theWidth * 3; j++)
	{
		*subtotal++ = 0;
	}
	GLuint *tmpRowPtr = NULL;
	for (int i=0; i<kernel_size; i++) 
	{
		tmpRowPtr = (GLuint *) tmpRows[i];
		for (int j=0; j<theWidth * 3; j++)
		{
			*tmpRowPtr++ = 0;
		}
	}	
	
	// Store the blur value to output buffer
	//
	GLubyte *pout, *poutb;
	pout = poutb = (GLubyte *)malloc(theWidth * theHeight * 4);
	if (!pout)
	{
		for (int i=0; i<kernel_size; i++)
		{
			free(tmpRows[i]);
		}
		free(tmpRows);
		free(subtotal);
		return NULL;
	}	
	
	// Run length variables;
	GLuint runningSum[3];
	GLuint *tmpColR = (GLuint *)malloc(kernel_size * sizeof(GLuint));
	GLuint *tmpColG = (GLuint *)malloc(kernel_size * sizeof(GLuint));
	GLuint *tmpColB = (GLuint *)malloc(kernel_size * sizeof(GLuint));
	if (!tmpColR || !tmpColG || !tmpColB)
	{
		for (int i=0; i<kernel_size; i++)
		{
			free(tmpRows[i]);
		}
		free(tmpRows);
		free(subtotal);
		if (!tmpColR)
			free(tmpColR);
		if (!tmpColG)
			free(tmpColG);
		if (!tmpColB)
			free(tmpColB);
		return NULL;
	}
	
	int lastBottomIdx = 0;
	for (int yy = -s_radius, loadedRow = 0; yy < theHeight; yy++, loadedRow++) 
	{    
		int bottomIdx = loadedRow%kernel_size;
		
		//Subtract the previous row
		//
		tmpRowPtr = tmpRows[bottomIdx];
		subtotal = subTotalHead;		
		for (int xx = 0; xx < theWidth; xx++) 
		{
			*subtotal++ -= (GLuint) *tmpRowPtr++;	
			*subtotal++ -= (GLuint) *tmpRowPtr++;	
			*subtotal++ -= (GLuint) *tmpRowPtr++;	
		}
		
		//Load the new row
		//
		tmpRowPtr = tmpRows[bottomIdx];
		if (loadedRow < theHeight)
		{
			lastBottomIdx = bottomIdx;
			
			// linear blur for each row
			//
			GLubyte	*_src = (GLubyte *)&_srcImg[loadedRow*theWidth*4];
			
			// initialize the left side to avoid black border
			//
			runningSum[0] = 0;
			runningSum[1] = 0;
			runningSum[2] = 0;
			for ( int j=0; j<kernel_size; j++ )
			{
				tmpColR[j] = _src[0];
				tmpColG[j] = _src[1];
				tmpColB[j] = _src[2];
				
				runningSum[0] += tmpColR[j];
				runningSum[1] += tmpColG[j];
				runningSum[2] += tmpColB[j];
			}
			
			// Blur the row
			int lastIdx = 0;
			for ( int j=-s_radius, rightIdx=0; j<theWidth; j++, rightIdx++)
			{
				int idx = rightIdx%kernel_size;
				
				// Subtract old pixels
				runningSum[0] -= tmpColR[idx];
				runningSum[1] -= tmpColG[idx];
				runningSum[2] -= tmpColB[idx];			
				
				if ( rightIdx < theWidth )
				{
					// retrieve source
					//
					tmpColR[idx] = (GLubyte) *_src++;
					tmpColG[idx] = (GLubyte) *_src++;
					tmpColB[idx] = (GLubyte) *_src++;
					_src++;
					
					lastIdx = idx;
				}
				else 
				{
					// Repeat the right side to avoid black border
					//
					tmpColR[idx] = tmpColR[lastIdx];
					tmpColG[idx] = tmpColG[lastIdx];
					tmpColB[idx] = tmpColB[lastIdx];					
				}
				
				runningSum[0] += tmpColR[idx];
				runningSum[1] += tmpColG[idx];
				runningSum[2] += tmpColB[idx];
				
				if ( j >= 0 )
				{
					// Could write to output buffer
					//
					*tmpRowPtr++ = runningSum[0];
					*tmpRowPtr++ = runningSum[1];
					*tmpRowPtr++ = runningSum[2];
				}
			}
			
			// Add to total
			//
			tmpRowPtr = tmpRows[bottomIdx];
			subtotal = subTotalHead;		
			for (int j=0; j<theWidth; j++) 
			{			
				*subtotal++ += *tmpRowPtr++;
				*subtotal++ += *tmpRowPtr++;
				*subtotal++ += *tmpRowPtr++;
			}
			
			if (loadedRow==0)
			{
				// First row - accumulate the border to avoid black edge
				//
				GLuint *tmpFirstRows;
				for ( int j=1; j<kernel_size; j++ )
				{
					tmpFirstRows = tmpRows[bottomIdx];
					tmpRowPtr = tmpRows[j];
					subtotal = subTotalHead;		
					for (int j=0; j<theWidth; j++) 
					{			
						*tmpRowPtr++ = *tmpFirstRows;
						*tmpRowPtr++ = *(tmpFirstRows+1);
						*tmpRowPtr++ = *(tmpFirstRows+2);

						*subtotal++ += *tmpFirstRows++;
						*subtotal++ += *tmpFirstRows++;
						*subtotal++ += *tmpFirstRows++;
					}
				}
			}
		}
		else 
		{
			// Repeat the bottom side to avoid black border
			//
			GLuint *tmpLastRowPtr = tmpRows[lastBottomIdx];
			subtotal = subTotalHead;		
			for (int j=0; j<theWidth * 3; j++, tmpRowPtr++) 
			{			
				*tmpRowPtr = *tmpLastRowPtr++;
				*subtotal++ += *tmpRowPtr;
			}
		}
		
		if ( yy >= 0 )
		{
			// Could write to output buffer
			//
			subtotal = subTotalHead;		
			for (int xx = 0; xx < theWidth; xx++) 
			{				
				*pout++ = (GLubyte) (*subtotal++ / kernel_area);
				*pout++ = (GLubyte) (*subtotal++ / kernel_area);
				*pout++ = (GLubyte) (*subtotal++ / kernel_area);
				if (glPixelSize >= 4) {
					*pout++ = (GLubyte) 255;
				}
			}
		}
	}
	
	// Free buffers
	for (int i=0; i<kernel_size; i++)
	{
		free(tmpRows[i]);   		
	}
	free(subTotalHead);
	free(tmpRows);
	free(tmpColR);
	free(tmpColG);
	free(tmpColB);
	
	return poutb;
}	

