//
//  RUAMessage.h
//  ePager
//
//  Created by mac on 11-3-3.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RUAMessage : NSObject {

	NSString *ID;
	NSString *title;
	NSString *content;
	NSString *sendtime;
	BOOL      unread;
	
}

@property (nonatomic, retain) NSString *ID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *sendtime;
@property (nonatomic) BOOL      unread;

@end
