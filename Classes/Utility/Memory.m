//
//  Memory.m
//  MovieLooks
//
//  Created by Sean Hess on 5/5/16.
//
//

#import "Memory.h"

#include <sys/sysctl.h>
BOOL TooHighForDevice(CGSize videoSize)
{
	// checks device memory to see if the device has enough memory to process HD video (~300MB)
	// returns YES if HD video memory is too high for this device
	
	size_t value = 0;
	size_t length = sizeof(value) ;
	int selection[2] = { CTL_HW, HW_PHYSMEM } ;
	sysctl(selection, 2, &value, &length, NULL, 0) ;
	
	int mbSize = (int)(value/1048576);
	BOOL retval = (mbSize < 300);
	NSLog(@"Memory Size %d MB, too high for device {%d}", (int)(value/1048576), retval);
	
	//return ((value/1048576<300) && videoSize.width==1280 && videoSize.height==720);
	//return ((value/1048576<300) && videoSize.width==1920 && videoSize.height==1080);
	//return ((value/1048576<300));
	return retval;
}

@implementation Memory

@end
