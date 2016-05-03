//
//  main.m
//  MobileLooks
//
//  Created by jack on 8/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MobileLooksAppDelegate.h"

//for storyboard
int main(int argc, char *argv[])
{
    @autoreleasepool
    {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([MobileLooksAppDelegate class]));
    }
}

#if 0
int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"MobileLooksAppDelegate");
    [pool release];
    return retVal;
}
#endif
