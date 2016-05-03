//
//  NotiPusher.m
//  ePager
//
//  Created by rydring on 10-9-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NotiPusher.h"


//sever macros
#define push_sever_broadcast					@"https://go.urbanairship.com/api/push/broadcast/"

#define rich_push_sever_user_port				@"https://go.urbanairship.com/api/user/"
#define rich_push_sever_broadcast				@"https://go.urbanairship.com/api/airmail/send/broadcast/"


static NotiPusher *_sharedNotiPusher;

@implementation NotiPusher
@synthesize delegate=_delegate;
@synthesize deviceToken;
@synthesize deviceAlias;
@synthesize userID;
@synthesize password;



#pragma mark -
#pragma mark system funcions
+(NotiPusher*)sharedNotiPusher
{
	if (!_sharedNotiPusher) {
		_sharedNotiPusher = [[NotiPusher alloc] init];
	}
	return _sharedNotiPusher;
}

- (id)init
{
	if(self = [super init])
	{
		_gettingState = gettingStateNone;
		_postingState = postingStateNone;
		_bGetting = NO;
		_bPosting = NO;
	}
	
	return self;
}

- (void)dealloc
{		
	[_sharedNotiPusher release];
	[deviceToken release];
	[deviceAlias release];
	[userID release];
	[password release];
	
	if(_receivedData != nil)
	{
		[_receivedData release];
		_receivedData = nil;
	}
	
	if(_postHttp)
	{
		[_postHttp shutHttp];
		[_postHttp release];
	}
	if(_createUserHttp)
	{
		[_createUserHttp shutHttp];
		[_createUserHttp release];
	}
	if(_getHttp)
	{
		[_getHttp shutHttp];
		[_getHttp release];
	}
	if(_putHttp)
	{
		[_putHttp shutHttp];
		[_putHttp release];
	}
	
	[super dealloc];
}





#pragma mark -
#pragma mark in & out use functions ps: not only for push-notification
//From: http://www.cocoadev.com/index.pl?BaseSixtyFour
-(NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}






#pragma mark -
#pragma mark in use funcions
-(void)postTheNotification:(NSString*)pushString toSever:(NSString*)sever
{
	if(_bPosting) return;
	if(pushString == nil) return;
	if(sever == nil) return;
	
	_bPosting = YES;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	//push
	NSString *authorization = [NSString stringWithFormat:@"Basic %@",
							   [self base64forData:[[NSString stringWithFormat:@"%@:%@", 
													 kApplicationKey, 
													 kMasterSecret
													 ] dataUsingEncoding: NSUTF8StringEncoding]]];
	
	if(_postHttp != nil)
	{
		[_postHttp shutHttp];
		[_postHttp release];
		_postHttp = nil;
	}
	_postHttp = [[Http alloc] init];
	_postHttp.delegate = self;
	
	[_postHttp postRequestAsync:pushString stringURL:sever contentType:@"application/json" authorization:authorization];
	
}
-(void)getDataFromSever:(NSString*)sever
{
	if(_bGetting) return;
	if(_gettingState == gettingStateNone) return;
	if(sever == nil) return;
	
	_bGetting = YES;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	//get
	NSString *authorization = [NSString stringWithFormat:@"Basic %@",
							   [self base64forData:[[NSString stringWithFormat:@"%@:%@", 
													 self.userID, 
													 self.password
													 ] dataUsingEncoding: NSUTF8StringEncoding]]];
	
	if(_getHttp != nil)
	{
		[_getHttp shutHttp];
		[_getHttp release];
		_getHttp =  nil;
	}
	_getHttp = [[Http alloc] init];
	_getHttp.delegate = self;
	
	[_getHttp getRequestAsync:sever contentType:@"application/json" authorization:authorization];
}
-(void)getNewestUnreadMessageByID:(NSString*)messageID
{
	if(self.userID == nil) return;
	if(self.password == nil) return;
	if(messageID == nil || [messageID compare:@""] == NSOrderedSame) return;
	
	//get
	NSString *sever = [NSString stringWithFormat:@"%@%@/messages/message/%@/", rich_push_sever_user_port, self.userID, messageID];
	
	_gettingState = gettingStateNewestUnreadMessage;
	[self getDataFromSever:sever];
}
-(void)markMessageAsReadForIDs:(NSArray*)messageIDs
{
	if(messageIDs == nil || [messageIDs count] == 0) 
	{
		// Reset badge number to 0
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
		
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidMarkAllUnreadAsRead:)])
		{
			[self.delegate notiPusherDidMarkAllUnreadAsRead:YES];
		}
		return;
	}
	
	//组合发送的messageID的数组
	NSMutableArray *markArr = [[[NSMutableArray alloc] init] autorelease];
	for(NSString *mID in messageIDs)
	{
		NSString *markStr = [NSString stringWithFormat:@"https://go.urbanairship.com/api/user/%@/messages/message/%@/", self.userID, mID];
		[markArr addObject:markStr];
	}
	
	//组成要发送的字典
	NSDictionary *markDic = [NSDictionary dictionaryWithObject:markArr 
														forKey:@"mark_as_read"];
	
	//翻译为json字符串
	NSString *markJsonString = [markDic JSONRepresentation];
	NSLog(@"mark as read Sending: %@", markJsonString);
	
	//sever	
	NSString *sever = [NSString stringWithFormat:@"%@%@/messages/unread/", rich_push_sever_user_port, self.userID];
	
	//发送
	_postingState = postingStateMarkAllUnreadAsRead;
	[self postTheNotification:markJsonString toSever:sever];
	
}





#pragma mark -
#pragma mark out use funcions PS: only for push-notification
//nomal push --------------------------------------------
-(void)pushBoradcastNotification:(NSString*)notification
{
	if(notification == nil || [notification compare:@""] == NSOrderedSame) return;

	NSString *pushStr = [NSString stringWithFormat:@"{\"aps\": {\"badge\": 0,\"alert\": \"%@\",\"sound\": \"pig.caf\"}}", notification];
	
	//push
	_postingState = postingStatePostMessage;
	[self postTheNotification:pushStr toSever:push_sever_broadcast];
}


//rich push --------------------------------------------
-(void)richCreateUser
{
	NSLog(@"Create User information >>");
		
    //bret
    //UIDevice currentDevice].uniqueIdentifier is deprecated in iOS 5 and above
    //for testing under older sdk builds, uncomment line below and comment the next
    //NSString *udid = [UIDevice currentDevice].uniqueIdentifier;
	NSString *udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSString *pushStr = [NSString stringWithFormat:@"{\"airmail\":true, \"alias\": \"%@\", \"tags\": [\"%@\"], \"device_tokens\": [\"%@\"], \"udid\":\"%@\"}", udid, udid, self.deviceToken, udid];
	
	//push
	NSString *authorization = [NSString stringWithFormat:@"Basic %@",
							   [self base64forData:[[NSString stringWithFormat:@"%@:%@", 
													 kApplicationKey, 
													 kMasterSecret
													 ] dataUsingEncoding: NSUTF8StringEncoding]]];
	
	if(_createUserHttp == nil)
	{
		[_createUserHttp shutHttp];
		[_createUserHttp release];
		_createUserHttp = nil;
	}
	_createUserHttp = [[Http alloc] init];
	_createUserHttp.delegate = self;
	
	[_createUserHttp postRequestAsync:pushStr stringURL:rich_push_sever_user_port contentType:@"application/json" authorization:authorization];
	
}
-(void)richPushBoardcastNotification:(NSString*)notification
{
	NSString *pushStr = @"\
	{\
		\"push\": {\
			\"aps\": {\
				\"alert\": \"这是一个rich push的发送测试\"\
			}\
		},\
		\"title\": \"如果能收到很好\",\
		\"message\": \"这个地方是你应该接收到的消息内容\"\
	}";
	
	//push
	_postingState = postingStatePostRichMessage;
	[self postTheNotification:pushStr toSever:rich_push_sever_broadcast];
}
-(void)getUnreadMessagesIDs
{	
	if(self.userID == nil) return;
	if(self.password == nil) return;
	
	//get
	NSString *sever = [NSString stringWithFormat:@"%@%@/messages/unread/", rich_push_sever_user_port, self.userID];
	
	_gettingState = gettingStateAllUnreadMessagesIDs;
	[self getDataFromSever:sever];
}
-(void)getNewestMessage
{
	if(self.userID == nil) return;
	if(self.password == nil) return;
	
	//get
	NSString *sever = [NSString stringWithFormat:@"%@%@/messages/unread/", rich_push_sever_user_port, self.userID];
	
	_gettingState = gettingStateNewestUnreadMessageID;
	[self getDataFromSever:sever];
}
-(void)getSpecifyMessageByID:(NSString*)messageID
{
	if(self.userID == nil) return;
	if(self.password == nil) return;
	if(messageID == nil || [messageID compare:@""] == NSOrderedSame) return;

	//get
	NSString *sever = [NSString stringWithFormat:@"%@%@/messages/message/%@/", rich_push_sever_user_port, self.userID, messageID];
	
	_gettingState = gettingStateSpecifyMessage;
	[self getDataFromSever:sever];
}
-(void)markAllUnreadMessagesAsRead
{
	if(self.userID == nil) return;
	if(self.password == nil) return;
	
	//get
	NSString *sever = [NSString stringWithFormat:@"%@%@/messages/unread/", rich_push_sever_user_port, self.userID];
	
	_gettingState = gettingStateMarkAllUnreadMessageAsRead;
	[self getDataFromSever:sever];
}
-(void)markAsReadForMessageID:(NSString*)messageID
{
	if(messageID == nil || [messageID compare:@""] == NSOrderedSame) 
	{
		// Reset badge number to 0
		[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
		
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidMarkMessageAsRead:)])
		{
			[self.delegate notiPusherDidMarkMessageAsRead:YES];
		}
		return;
	}
	
	//组合发送的messageID的数组
	NSMutableArray *markArr = [[[NSMutableArray alloc] init] autorelease];
	NSString *markStr = [NSString stringWithFormat:@"https://go.urbanairship.com/api/user/%@/messages/message/%@/", self.userID, messageID];
	[markArr addObject:markStr];
	
	
	//组成要发送的字典
	NSDictionary *markDic = [NSDictionary dictionaryWithObject:markArr 
														forKey:@"mark_as_read"];
	
	//翻译为json字符串
	NSString *markJsonString = [markDic JSONRepresentation];
	NSLog(@"mark as read Sending: %@", markJsonString);
	
	//sever	
	NSString *sever = [NSString stringWithFormat:@"%@%@/messages/unread/", rich_push_sever_user_port, self.userID];
	
	//发送
	_postingState = postingStateMarkMessageAsRead;
	[self postTheNotification:markJsonString toSever:sever];
}
-(void)setQuietTimeFrom:(NSString*)startTime to:(NSString*)endTime
{
	NSLog(@"Start Quiet-Time >>");
		
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSString *timeZone = [NSTimeZone systemTimeZone].name;
	NSString *putStr = [NSString stringWithFormat:@"{\"alias\": \"%@\", \"quiettime\": {\"start\": \"%@\", \"end\": \"%@\"}, \"tz\": \"%@\"}", self.deviceAlias, startTime, endTime, timeZone];
	
    NSString *severURL = [NSString stringWithFormat:@"https://go.urbanairship.com/api/device_tokens/%@/", self.deviceToken];

	//push
	NSString *authorization = [NSString stringWithFormat:@"Basic %@",
							   [self base64forData:[[NSString stringWithFormat:@"%@:%@", 
													 kApplicationKey, 
													 kMasterSecret
													 ] dataUsingEncoding: NSUTF8StringEncoding]]];
	
	if(_putHttp == nil)
	{
		[_putHttp shutHttp];
		[_putHttp release];
		_putHttp = nil;
	}
	_putHttp = [[Http alloc] init];
	_putHttp.delegate = self;
	
	[_putHttp putRequestAsync:putStr stringURL:severURL contentType:@"application/json" authorization:authorization];
}




#pragma mark -
#pragma mark delegate funcions
//HttpDelegate
- (void)httpDidResponse:(Http *)http response:(NSURLResponse *)response
{
	NSHTTPURLResponse *httprespnse = (NSHTTPURLResponse *)response;
	NSInteger status = [httprespnse statusCode];
	NSLog(@"%ld", (long)status);
	
	if(http == _postHttp)
	{
		BOOL bPosted = NO;
		if(status == 200)
		{
			bPosted = YES;
		}
		
		if(_postingState == postingStatePostMessage || _postingState == postingStatePostRichMessage)
		{
			if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidPushMessage:)])
			{
				[self.delegate notiPusherDidPushMessage:bPosted];
			}
		}
		else if(_postingState == postingStateMarkAllUnreadAsRead)
		{
			if(bPosted)
			{
				// Reset badge number to 0
				[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
			}
			
			if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidMarkAllUnreadAsRead:)])
			{
				[self.delegate notiPusherDidMarkAllUnreadAsRead:bPosted];
			}
		}
		else if(_postingState == postingStateMarkMessageAsRead)
		{
			if(bPosted)
			{
				// Reset badge number to 0
				[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
			}
			
			if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidMarkMessageAsRead:)])
			{
				[self.delegate notiPusherDidMarkMessageAsRead:bPosted];
			}
		}
	}
	else if(http == _putHttp)
	{
		BOOL bPuted = NO;
		if(status == 200)
		{
			bPuted = YES;
		}
		NSLog(@"<< Setting Quiet-Time Result: %d", bPuted);
		
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidPutQuietTime:)])
		{
			[self.delegate notiPusherDidPutQuietTime:bPuted];
		}
	}

}
- (void)httpDidFinish:(Http *)http Data:(NSData *)data
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if(data == nil) return;

	NSString *jsonReturnString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"jsonReturnString : %@", jsonReturnString);
	
	if(http == _postHttp)
	{
		//暂时不处理返回值，保留位置
		_bPosting = NO;
	}
	else if(http == _getHttp)
	{
		_bGetting = NO;
		
		if(_gettingState == gettingStateAllMessages)
		{
		}
		else if(_gettingState == gettingStateAllUnreadMessagesIDs || 
				_gettingState == gettingStateNewestUnreadMessageID ||
				_gettingState == gettingStateMarkAllUnreadMessageAsRead)
		{
			NSArray *unreadArr = (NSArray*)[jsonReturnString JSONValue];
			if(unreadArr == nil) return;
			
			//解析所有unread的ID，并保存成数组allUnreadIDs
			NSMutableArray *allUnreadIDs = [[[NSMutableArray alloc] init] autorelease];
			for(NSDictionary *dic in unreadArr)
			{
				NSString *message_id = (NSString*)[dic objectForKey:@"message_id"];
				[allUnreadIDs addObject:message_id];
			}
			
			if(_gettingState == gettingStateAllUnreadMessagesIDs)
			{
				//return to delegate
				if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidLoadAllUnreadMessagesIDs:)])
				{
					[self.delegate notiPusherDidLoadAllUnreadMessagesIDs:allUnreadIDs];
				}
			}
			else if(_gettingState == gettingStateNewestUnreadMessageID)
			{
				//start load newest message
				NSString *newestMessageID = [allUnreadIDs objectAtIndex:0];
				NSLog(@"newestMessageID : %@", newestMessageID);
				
				[self getNewestUnreadMessageByID:newestMessageID];
			}
			else if(_gettingState == gettingStateMarkAllUnreadMessageAsRead)
			{
				[self markMessageAsReadForIDs:allUnreadIDs];
			}
			
		}
		else if(_gettingState == gettingStateSpecifyMessage || _gettingState == gettingStateNewestUnreadMessage)
		{
			NSDictionary *specDic = (NSDictionary*)[jsonReturnString JSONValue];
			
			RUAMessage *message = nil;
			if(specDic != nil) 
			{
				message = [[[RUAMessage alloc] init] autorelease];
				message.title	  = (NSString*)[specDic objectForKey:@"title"];
				message.content	  = (NSString*)[specDic objectForKey:@"message"];
				message.sendtime  = (NSString*)[specDic objectForKey:@"message_sent"];
				message.unread	  = [(NSNumber*)[specDic objectForKey:@"unread"] boolValue];
			}

			if(_gettingState == gettingStateSpecifyMessage)
			{
				if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidLoadSpecifyMessage:)])
				{
					[self.delegate notiPusherDidLoadSpecifyMessage:message];
				}
			}
			else if(_gettingState == gettingStateNewestUnreadMessage)
			{
				if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidLoadNewestUnreadMessage:)])
				{
					[self.delegate notiPusherDidLoadNewestUnreadMessage:message];
				}
			}
		}
	}
	else if(http == _createUserHttp)
	{
		NSDictionary *reDic = (NSDictionary*)[jsonReturnString JSONValue];
		if(reDic == nil) 
		{
			if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidCreateuser:password:)])
			{
				[self.delegate notiPusherDidCreateuser:nil password:nil];
			}
			return;
		}
		
		self.userID = (NSString*)[reDic objectForKey:@"user_id"];
		self.password = (NSString*)[reDic objectForKey:@"password"];
		
		if(self.userID != nil)
		{
			NSLog(@"<< user Created: (userID: %@, password: %@)", self.userID, self.password);
			
			[[NSUserDefaults standardUserDefaults] setObject:self.userID forKey:@"user_id"];
			[[NSUserDefaults standardUserDefaults] setObject:self.password forKey:@"password"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidCreateuser:password:)])
		{
			[self.delegate notiPusherDidCreateuser:self.userID password:self.password];
		}
	}
	
}
- (void)httpError:(Http *)http  Message:(NSString *)message
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if(http == _postHttp)
	{
		_bPosting = NO;
		
		NSLog(@"post Failed");
		if(_postingState == postingStatePostMessage || _postingState == postingStatePostRichMessage)
		{
			if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidPushMessage:)])
			{
				[self.delegate notiPusherDidPushMessage:NO];
			}
		}
	}
	else if(http == _getHttp)
	{
		_bGetting = NO;
		
		NSLog(@"getting Failed");
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherGetError)])
		{
			[self.delegate notiPusherGetError];
		}
	}
	else if(http == _createUserHttp)
	{
		NSLog(@"user Create Failed");
		
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidCreateuser:password:)])
		{
			[self.delegate notiPusherDidCreateuser:nil password:nil];
		}
	}
	else if(http == _putHttp)
	{
		NSLog(@"Set quiet-time failed");
		if(self.delegate &&[(NSObject*)self.delegate respondsToSelector:@selector(notiPusherDidPutQuietTime:)])
		{
			[self.delegate notiPusherDidPutQuietTime:NO];
		}
	}
}



@end
