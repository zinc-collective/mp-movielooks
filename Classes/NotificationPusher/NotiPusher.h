//
//  NotiPusher.h
//  ePager
//
//  Created by rydring on 10-9-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
#import "Http.h"
#import "RUAMessage.h"


#define macro_use_rich_push_mode


// app settings from the http://go.urbanairship.com dashboard.

//redsafi develop
//#define  kApplicationKey    @"q7JcWmWGQIaj3aLuOr0-bg"
//#define  kApplicationSecret @"rYibGd-aSraV7Dzn0xFQBw"
//#define  kMasterSecret      @"QbRVN9zlRWC6ON5d9GV2Fg"

//RG product
#define  kApplicationKey    @"uA3Ctm8eSdmktgEg0o9Jug"
#define  kApplicationSecret @"UmPgJvTAQgyfuWFq-EAdYQ"
#define  kMasterSecret      @"bElh-BM1THuj-NW5noYGvQ"

//RG develop
//#define  kApplicationKey    @"uqmrAj6TRNur_WEmRPW5_Q"
//#define  kApplicationSecret @"ZvSLHm1kRV2xmjf-AknqIg"
//#define  kMasterSecret      @"6u0RJkhIRU69C2vh4tzOgA"



typedef enum{
	gettingStateNone,
	gettingStateAllMessages,
	gettingStateAllUnreadMessagesIDs,
	gettingStateNewestUnreadMessageID,
	gettingStateNewestUnreadMessage,
	gettingStateSpecifyMessage,
	gettingStateMarkAllUnreadMessageAsRead
} HttpGettingState;

typedef enum{
	postingStateNone,
	postingStatePostMessage,
	postingStatePostRichMessage,
	postingStateMarkAllUnreadAsRead,
	postingStateMarkMessageAsRead
} HttpPostingState;


@class NotiPusher;
@protocol NotiPusherDelegate <NSObject>
@optional
-(void)notiPusherDidPushMessage:(BOOL)bPushed;
-(void)notiPusherDidLoadAllMessages:(NSArray*)messages; //messages是由RUAMessage类组成的数组
-(void)notiPusherDidLoadAllUnreadMessagesIDs:(NSArray*)messagesIDs;//messagesIDs是由messageID组成的数组,字符串组成的数组
-(void)notiPusherDidLoadSpecifyMessage:(RUAMessage*)message;
-(void)notiPusherDidLoadNewestUnreadMessage:(RUAMessage*)message;
-(void)notiPusherDidCreateuser:(NSString*)createdUserID password:(NSString*)createdPassword; 
-(void)notiPusherDidMarkAllUnreadAsRead:(BOOL)bMarked; //是否mark所有unread的message为read
-(void)notiPusherDidMarkMessageAsRead:(BOOL)bMarked;   //是否mark了指定的message为read
-(void)notiPusherDidPutQuietTime:(BOOL)bPuted; //是否设置了安静时间

-(void)notiPusherGetError;

@end


@interface NotiPusher : NSObject <HttpDelegate> {

	NSString *deviceToken;
	NSString *deviceAlias;
	
	NSString *userID;
	NSString *password;
	
	NSMutableData *_receivedData;
	
	Http *_postHttp;
	Http *_createUserHttp;
	Http *_getHttp;
	Http *_putHttp;
	
	HttpGettingState _gettingState;
	HttpPostingState _postingState;
	
	BOOL _bGetting;
	BOOL _bPosting;
	
@private
	id _delegate;		
}
@property (assign) id<NotiPusherDelegate> delegate;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) NSString *deviceAlias;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *password;


#pragma mark -
#pragma mark system funcions
+(NotiPusher*)sharedNotiPusher;


#pragma mark -
#pragma mark in & out use functions PS: not only for push-notification
-(NSString*)base64forData:(NSData*)theData;


#pragma mark -
#pragma mark in use funcions
-(void)postTheNotification:(NSString*)pushString toSever:(NSString*)sever;//既可以发送所有人，也可以指定对象发送
-(void)getDataFromSever:(NSString*)sever;
-(void)getNewestUnreadMessageByID:(NSString*)messageID;
-(void)markMessageAsReadForIDs:(NSArray*)messageIDs;


#pragma mark -
#pragma mark out use funcions PS: only for push-notification
//nomal push-notification
-(void)pushBoradcastNotification:(NSString*)notification;      //发送普通push的广播给所有人  -> //-(void)notiPusherDidPushMessage:(BOOL)bPushed;

//rich push-notification
-(void)richCreateUser;										                   //创建用户 -> //-(void)notiPusherDidCreateuser:(NSString*)createdUserID password:(NSString*)createdPassword; 
-(void)richPushBoardcastNotification:(NSString*)notification; //发送rich－push的广播给所有人 -> //-(void)notiPusherDidPushMessage:(BOOL)bPushed;
-(void)getUnreadMessagesIDs;						//得到本机还没有读取过的消息的ID			 -> //-(void)notiPusherDidLoadAllUnreadMessagesIDs:(NSArray*)messagesIDs;
-(void)getNewestMessage;							//得到没读取过的最新的消息				 -> //-(void)notiPusherDidLoadNewestUnreadMessage:(RUAMessage*)message;
-(void)getSpecifyMessageByID:(NSString*)messageID;	//得到指定messageID对应的RUAMessage	 -> //-(void)notiPusherDidLoadSpecifyMessage:(RUAMessage*)message;
-(void)markAllUnreadMessagesAsRead;					//mark所有Unread的message为Read        -> //-(void)notiPusherDidMarkAllUnreadAsRead:(BOOL)bMarked;
-(void)markAsReadForMessageID:(NSString*)messageID; //把指定messageID对应的message标记为已读  -> //-(void)notiPusherDidMarkMessageAsRead:(BOOL)bMarked;
-(void)setQuietTimeFrom:(NSString*)startTime to:(NSString*)endTime; //设置安静时间          -> //-(void)notiPusherDidPutQuietTime:(BOOL)bPuted;


@end
