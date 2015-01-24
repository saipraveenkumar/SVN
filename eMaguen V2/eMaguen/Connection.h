//
//  Connection.h
//  Created by Rohit Yermalkar on 21/04/13.
//  Copyright (c) 2013 Aptara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Connection;

@protocol ConnectionDelegate <NSObject>

-(void) ConnectionFinished:(Connection*) connetion;
-(void) ConnectionFailed:(Connection*) connetion;

@optional
-(void) connectionDownloadedTheDataInAmount:(float)amt;

@end


@interface Connection : NSObject <NSURLConnectionDelegate>
{
	
	NSMutableURLRequest		*mRequest;
	NSURLConnection			*mConnection;
	NSMutableData			*mResponceData;	
	NSError					*mConnectionError;
	id<ConnectionDelegate>	mOwner;
	BOOL					mFlgActiveConnection;
	NSMutableDictionary     *mConnectionHeaders;
    BOOL					mIsDataAvailable;
    NSData                  *mHTTPBodyData;
    BOOL                    mIsPostRequest;
    NSHTTPURLResponse       *mHTTPResponse;
    long long               mDownloadSize;
}

@property (retain, readonly) NSMutableData          *ResponceData;
@property (nonatomic, retain) NSData                *HTTPBodyData;
@property (nonatomic, readonly) NSMutableURLRequest *URLRequest;
@property (nonatomic, readonly) NSHTTPURLResponse   *HTTPURLResponse;


- (id) initWithURL:(NSURL*)serverURL;
- (id) initWithPostURL:(NSURL*)serverURL;

-(void) addJSONHeader;

-(BOOL)ConnectionStart;
-(BOOL)ConnectionClose;

-(void) setOwner:(id<ConnectionDelegate>) owner;
-(void) RestartConnection:(NSNotification*)sender;
-(void) ConnectionClosed:(NSNotification*)sender;
-(NSString*) getErrorMessage;
-(NSError*) getError;

-(void) setConnectionHeader:(NSString*) headerName Value:(NSString*) lValue;
-(BOOL) isDataAvailable;
@end
