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

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *sendtime;
@property (nonatomic) BOOL      unread;

@end
