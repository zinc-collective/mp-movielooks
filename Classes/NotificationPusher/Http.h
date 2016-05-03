//
//  Http.h
//  MSNBC
//
//  Created by Radar on 10-5-27.
//  Copyright 2010 RED/SAFI. All rights reserved.
//



#import <UIKit/UIKit.h>
@class Http;
@protocol HttpDelegate <NSObject>
@optional
- (void)httpDidResponse:(Http *)http response:(NSURLResponse *)response;
- (void)httpDidFinish:(Http *)http Data:(NSData *)data;
- (void)httpError:(Http *)http  Message:(NSString *)message;
@end


@interface Http : NSObject {
	NSURLConnection *urlConnection;
	NSMutableData *receivedData;
	BOOL m_bStop;

@private
	id _delegate;		
}

@property(assign) id<HttpDelegate> delegate;
@property BOOL m_bStop;


#pragma mark -
#pragma mark in use functions
- (void)shutConnection;
- (void)clearReceiveData;


#pragma mark -
#pragma mark out use functions
- (void)postRequestAsync:(NSString *)postString stringURL:(NSString *)httpURL contentType:(NSString*)contentType authorization:(NSString*)authorization;
- (void)getRequestAsync:(NSString *)httpURL contentType:(NSString*)contentType authorization:(NSString*)authorization;
- (void)putRequestAsync:(NSString *)putString stringURL:(NSString *)httpURL contentType:(NSString*)contentType authorization:(NSString*)authorization;
- (void)deleteRequestAsync:(NSString *)httpURL contentType:(NSString*)contentType authorization:(NSString*)authorization;
- (void)shutHttp; //这个函数仅用在dealloc的release前面即可，其他地方不需要使用，为了防止释放的时候http类被释放，导致返回的内容没有目标地址而引起crash

@end
