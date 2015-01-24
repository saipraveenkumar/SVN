//
//  NSObject.h
//
//  Created by Neeraj Singh on 21/04/13.
//  Copyright (c) 2013 Aptara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSClassMethod)

-(NSDictionary*) getDictionary;
-(NSArray*) getArray;
-(NSString*) getString;
-(NSNumber*) getNumber;
-(NSDecimalNumber*) getDecimalNumber;
-(BOOL) getBool;
-(void) logObject;
@end
