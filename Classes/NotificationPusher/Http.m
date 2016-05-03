//
//  Http.m
//  MSNBC
//
//  Created by Radar on 10-5-27.
//  Copyright 2010 RED/SAFI. All rights reserved.
//

#import "Http.h"

@implementation Http


@synthesize delegate=_delegate;
@synthesize m_bStop;


#pragma mark -
#pragma mark out use functions
//async
- (void)postRequestAsync:(NSString *)postString stringURL:(NSString *)httpURL contentType:(NSString*)contentType authorization:(NSString*)authorization
{
	if(httpURL == nil || [httpURL compare:@""] == NSOrderedSame) return;
	
	m_bStop = NO;
	
	//create request
	NSURL *url = [NSURL URLWithString:[httpURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
	[request setTimeoutInterval:10];
	
	//set header
	if(contentType != nil && [contentType compare:@""] != NSOrderedSame)
	{
		[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	}
	if(authorization != nil && [authorization compare:@""] != NSOrderedSame)
	{
		[request addValue:authorization forHTTPHeaderField:@"Authorization"];
	}
	
	//create connection
	[self shutConnection];
	urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];		
	[urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
- (void)getRequestAsync:(NSString *)httpURL contentType:(NSString*)contentType authorization:(NSString*)authorization
{
	if(httpURL == nil || [httpURL compare:@""] == NSOrderedSame) return;
	
	m_bStop = NO;
	
	//create request
	NSURL *url = [NSURL URLWithString:[httpURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[request setHTTPMethod:@"GET"];
	[request setTimeoutInterval:10];
	
	//set header
	if(contentType != nil && [contentType compare:@""] != NSOrderedSame)
	{
		[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	}
	if(authorization != nil && [authorization compare:@""] != NSOrderedSame)
	{
		[request addValue:authorization forHTTPHeaderField:@"Authorization"];
	}
	
	//create connection
	[self shutConnection];
	urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];		
	[urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
- (void)putRequestAsync:(NSString *)putString stringURL:(NSString *)httpURL contentType:(NSString*)contentType authorization:(NSString*)authorization
{
	if(httpURL == nil || [httpURL compare:@""] == NSOrderedSame) return;
	
	m_bStop = NO;
	
	//create request
	NSURL *url = [NSURL URLWithString:[httpURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[request setHTTPMethod:@"PUT"];
	[request setHTTPBody:[putString dataUsingEncoding:NSUTF8StringEncoding]];
	[request setTimeoutInterval:10];
	
	//set header
	if(contentType != nil && [contentType compare:@""] != NSOrderedSame)
	{
		[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	}
	if(authorization != nil && [authorization compare:@""] != NSOrderedSame)
	{
		[request addValue:authorization forHTTPHeaderField:@"Authorization"];
	}
	
	//create connection
	[self shutConnection];
	urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];		
	[urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
- (void)deleteRequestAsync:(NSString *)httpURL contentType:(NSString*)contentType authorization:(NSString*)authorization
{
	if(httpURL == nil || [httpURL compare:@""] == NSOrderedSame) return;
	
	m_bStop = NO;
	
	//create request
	NSURL *url = [NSURL URLWithString:[httpURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	[request setHTTPMethod:@"DELETE"];
	[request setTimeoutInterval:10];
	
	//set header
	if(contentType != nil && [contentType compare:@""] != NSOrderedSame)
	{
		[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
	}
	if(authorization != nil && [authorization compare:@""] != NSOrderedSame)
	{
		[request addValue:authorization forHTTPHeaderField:@"Authorization"];
	}
	
	//create connection
	[self shutConnection];
	urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];		
	[urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)shutHttp
{
	m_bStop = YES;
	[self shutConnection];
	[self clearReceiveData];
}



#pragma mark -
#pragma mark delegate functions
//NSURLConnection delegate
- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)response
{
	if(self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(httpDidResponse:response:)])
	{
		[self.delegate httpDidResponse:self response:response];
	}
	
	[self clearReceiveData];
	receivedData = [[NSMutableData alloc] initWithCapacity:1500];
}
- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)newData
{
	[receivedData appendData:newData];
}
- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error
{
	NSLog(@"%@", [error localizedDescription]);
	if(!m_bStop)
	{
		if(self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(httpError:Message:)])
		{
			[self.delegate httpError:self  Message:[error localizedDescription]];
		}
	}
	
	[self shutConnection];
	[self clearReceiveData];
	
}
- (void)connectionDidFinishLoading:(NSURLConnection *)_connection
{
	if(!m_bStop)
	{
		if(self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(httpDidFinish:Data:)])
		{		
			if([receivedData length] == 0) 
				[self.delegate httpDidFinish:self Data:(NSData*)nil];
			else 	
				[self.delegate httpDidFinish:self Data:(NSData*)receivedData];		
		}
	}
	
	[self shutConnection];
	[self clearReceiveData];
	
}




#pragma mark -
#pragma mark in use functions
- (void)shutConnection
{
	if(urlConnection != nil)
	{
		[urlConnection cancel];
		[urlConnection release];
		urlConnection = nil;
	}
}
- (void)clearReceiveData
{
	if(receivedData != nil)
	{
		[receivedData release];
		receivedData = nil;
	}
}



- (void)dealloc
{	
	[self shutConnection];
	[self clearReceiveData];
	
	m_bStop = NO;
	
	[super dealloc];
}



@end
