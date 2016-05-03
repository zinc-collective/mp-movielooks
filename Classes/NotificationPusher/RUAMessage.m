//
//  RUAMessage.m
//  ePager
//
//  Created by mac on 11-3-3.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RUAMessage.h"


@implementation RUAMessage
@synthesize ID;
@synthesize title;
@synthesize content;
@synthesize sendtime;
@synthesize unread;




- (void)dealloc
{		
	[ID release];
	[title release];
	[content release];
	[sendtime release];
	
	[super dealloc];
}



@end
