//
//  ConnectionFile.m
//
//  Created by Rohit Yermalkar on 21/04/13.
//  Copyright (c) 2013 Aptara Inc. All rights reserved.
//




#import "ConnectionFile.h"

static NSString *sCacheTempFolderPath = nil;

@implementation ConnectionFile

@synthesize ResponceFilePath = mResponceFilePath;

-(void) removeAllCacheFiles
{
#if DELETE_CACHE_AT_START
    if(sCacheTempFolderPath)
    {
        NSFileManager *lFileManager = [NSFileManager defaultManager];
        NSArray *fileList = [lFileManager contentsOfDirectoryAtPath: sCacheTempFolderPath error: nil];
        for(NSString *filePath in fileList)
        {
            if(filePath)
            {
                NSString *fullFilePath = [sCacheTempFolderPath stringByAppendingPathComponent: filePath] ;
                [lFileManager removeItemAtPath: fullFilePath error: nil];
            }
        }
    }
#endif
}

-(NSString*) getCacheTempDirectory
{
    if(!sCacheTempFolderPath)
    {
        NSString * tempDirectory = NSTemporaryDirectory();
        if(tempDirectory)
        {
            tempDirectory = [tempDirectory stringByAppendingPathComponent: @"CacheImages"];
            NSFileManager *lFileManager = [NSFileManager defaultManager];
            [lFileManager createDirectoryAtPath: tempDirectory withIntermediateDirectories: YES attributes: nil error: nil];
            sCacheTempFolderPath = [tempDirectory copy];
            [self removeAllCacheFiles];
        }
    }
    return sCacheTempFolderPath;
}

-(NSString*) getFilePathToBeCreated
{
	NSString *extension = @"pdf";
    NSString *uniqeFileName = [[NSProcessInfo processInfo] globallyUniqueString];
	NSString *fileNameWithExt = [NSString stringWithFormat: @"%@.%@", uniqeFileName, extension];
	NSString *path = [[self getCacheTempDirectory] stringByAppendingPathComponent: fileNameWithExt];
	return path;
}

#pragma mark 
#pragma mark ConnectionStart
#pragma mark 


- (id) initWithURL:(NSURL*)serverURL
{
	self = [super initWithURL:serverURL ];
	if (self != nil) 
	{		
		mResponceFilePath = [self getFilePathToBeCreated];
		[mResponceFilePath retain];
	}
	return self;
}



-(BOOL)ConnectionStart
{
	return [super ConnectionStart];
}

-(BOOL)ConnectionClose
{
	return [super ConnectionClose];
}




#pragma mark HTTP Resonse Start


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if(mFileStream)
	{
		[mFileStream close];
		[mFileStream release];
		mFileStream = nil;
	}

	assert(mResponceFilePath);
	mFileStream = [NSOutputStream outputStreamToFileAtPath: mResponceFilePath append:NO];
	[mFileStream retain];
	[mFileStream open];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	assert(mFileStream);
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
	
    assert(mConnection == connection);
    
    dataLength = [data length];
    dataBytes  = (const uint8_t *)[data bytes];
	
    bytesWrittenSoFar = 0;
    do 
	{
        bytesWritten = [mFileStream write: &dataBytes[bytesWrittenSoFar] maxLength: dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) 
		{
            break;
        } 
		else
		{
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if(mFileStream)
	{
		[mFileStream close];
		[mFileStream release];
		mFileStream = nil;
	}
	[super connection: connection didFailWithError: error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if(mFileStream)
	{
		[mFileStream close];
		[mFileStream release];
		mFileStream = nil;
	}

    if([super respondsToSelector: @selector(connectionDidFinishLoading:)])
    {
        [super performSelector:@selector(connectionDidFinishLoading:) withObject: connection];
    }
}

#pragma mark HTTP Resonse End



- (void) dealloc
{
	[mResponceFilePath release];
	mResponceFilePath = nil;
	if(mFileStream)
	{
		[mFileStream close];
		[mFileStream release];
		mFileStream = nil;
	}	

	[super dealloc];
}



@end
