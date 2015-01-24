//
//  ConnectionFile.h
//
//  Created by Rohit Yermalkar on 21/04/13.
//  Copyright (c) 2013 Aptara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

@interface ConnectionFile : Connection 
{
	NSOutputStream	*mFileStream;
	NSString		*mResponceFilePath;
	
}

@property (readonly) NSString *ResponceFilePath;
@end
