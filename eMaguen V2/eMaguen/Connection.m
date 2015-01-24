//
//  Connection.m
//  Created by Rohit Yermalkar on 21/04/13.
//  Copyright (c) 2013 Aptara Inc. All rights reserved.
//


#import "Connection.h"


@implementation Connection

@synthesize ResponceData    = mResponceData;
 @synthesize URLRequest      = mRequest;
@synthesize HTTPURLResponse = mHTTPURLResponse;


#pragma mark 
#pragma mark ConnectionStart
#pragma mark 

- (id) initWithURL:(NSURL*)serverURL 
{
	self = [super init];
	if (self != nil) 
	{		
		mRequest = [NSMutableURLRequest requestWithURL: serverURL];
		[mRequest retain];
		mResponceData = [[NSMutableData alloc] init] ;
		mOwner = nil;
	}
	return self;
}

- (id) initWithPostURL:(NSURL*)serverURL
{
    self = [self initWithURL: serverURL];
    if(self != nil)
    {
        mIsPostRequest = YES;
        [mRequest setHTTPMethod:@"POST"];
    }
    return self;
}



- (void) setOwner: (id<ConnectionDelegate>) owner
{
#if RetainOwner
	[mOwner release];
	mOwner = nil;
	mOwner = [owner retain];
#else
	mOwner = owner;
#endif	
}

- (void) setConnectionHeader:(NSString*) headerName Value:(NSString*) lValue
{
    if(mConnectionHeaders == NULL)
    {
        mConnectionHeaders = [[NSMutableDictionary alloc] init];
    }
    
    [mConnectionHeaders setObject: lValue forKey: headerName];
}

- (BOOL) isDataAvailable
{
    return mIsDataAvailable;
}

-(void) addJSONHeader
{
    [mRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
}

- (BOOL)ConnectionStart
{
	if(!mRequest) return NO;
	mFlgActiveConnection = YES;
    mIsDataAvailable = NO;
    [mRequest setTimeoutInterval: 40.0];
	mConnection  = [NSURLConnection connectionWithRequest:mRequest delegate:self];
    if(self.HTTPBodyData)
    {
        [mRequest setHTTPBody: self.HTTPBodyData];
        [mRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.HTTPBodyData length]] forHTTPHeaderField:@"Content-Length"];
        
        //NSLog(@"Request: %@",mRequest);
    }

    
	[mConnection retain];
	return (mConnection != nil);
	
}

- (BOOL)ConnectionClose
{
	[mConnection cancel];
	[mConnection release];
	mConnection = nil;
	return YES;
}

- (void) RestartConnection: (NSNotification*)sender
{
		
	if (mFlgActiveConnection && !(mConnection))
		[self ConnectionStart];
	
	
}

- (void) ConnectionClosed:(NSNotification*)sender
{
	if (mFlgActiveConnection && mConnection)
		[self ConnectionClose];
	

}

#pragma mark HTTP Resonse Start


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if([response isKindOfClass: [NSHTTPURLResponse class]])
    {
        [mHTTPURLResponse release];
        mHTTPURLResponse = nil;
        mHTTPURLResponse = (NSHTTPURLResponse*)[response retain];
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        int statusCode = (int)[httpResponse statusCode];
        if (statusCode == 200)
        {
            mDownloadSize = [response expectedContentLength];
//          NSLog(@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++");
//          NSLog(@"Starting call for URL: %@",[connection currentRequest].URL);
//          NSLog(@"Total Download Size: %lld Kb",mDownloadSize);
        }
    }
	[mResponceData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[mResponceData appendData:data];
    double lSize = mDownloadSize;
    double lResponse = (double)[mResponceData length];
    float progress = (float)(lResponse / lSize);
    
    if(mOwner && [mOwner respondsToSelector: @selector(connectionDownloadedTheDataInAmount:)])
	{
        [mOwner connectionDownloadedTheDataInAmount:progress];
    }
//    NSLog(@"Data Length: %f",(float)[mResponceData length]);
//    NSLog(@"Total Length: %f",(float)mDownloadSize);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	mConnectionError = [error retain];
    NSLog(@"%@", [mConnectionError localizedFailureReason]);
	NSLog(@"%@", [error.userInfo description]);

#if DEBUG_MESSAGE
	NSLog(@"%@", [mConnectionError localizedFailureReason]);
	NSLog(@"%@", [error.userInfo description]);
#endif
	
	mFlgActiveConnection = NO;
	if(mOwner && [mOwner respondsToSelector: @selector(ConnectionFailed:)])
	{
		[mOwner performSelector: @selector(ConnectionFailed:) withObject: self];	
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	mFlgActiveConnection = NO;
    mIsDataAvailable = YES;
    
    //NSString *lResponseBody = [[NSString alloc] initWithData: self.ResponceData encoding:NSUTF8StringEncoding];
    if(mOwner && [mOwner respondsToSelector:@selector(ConnectionFinished:)])
	{
		[mOwner performSelector:@selector(ConnectionFinished:) withObject: self];	
	}
}

- (NSString*)getErrorMessage
{
	if(mConnectionError)
	{
		return [mConnectionError localizedFailureReason];
	}
	
	return nil;
}

- (NSError*)getError
{
	return [[mConnectionError retain] autorelease];
}



#pragma mark HTTP Resonse End

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[mResponceData release];
	mResponceData = nil;
	
#if RetainOwner	
	[mOwner release];
	mOwner = nil;
#else
	mOwner = nil;
#endif	
	
	[mConnection cancel];
	[mConnection release];
	mConnection = nil;	
	
	[mRequest release];
	mRequest = nil;
	
	[mConnectionError release];
	mConnectionError = nil;
    
    [mConnectionHeaders release];
    mConnectionHeaders = nil;
    
    [mHTTPURLResponse release];
    mHTTPURLResponse = nil;
    
    self.HTTPBodyData = nil;

	[super dealloc];
}

@end
