//
//  NSObject+NSClassMethod.m
//
//  Created by Neeraj Singh on 21/04/13.
//  Copyright (c) 2013 Aptara Inc. All rights reserved.
//

#import "NSObject+NSClassMethod.h"

@implementation NSObject (NSClassMethod)

-(NSDictionary*) getDictionary
{
    if(self && [self isKindOfClass: [NSDictionary class]])
        return (NSDictionary*) self;
    return NULL;
}

-(NSArray*) getArray
{
    if(self && [self isKindOfClass: [NSArray class]])
        return (NSArray*) self;
    return NULL;
}

-(NSString*) getString
{
    if(self && [self isKindOfClass: [NSString class]])
        return (NSString*) self;
    if (self && [self isKindOfClass: [NSNumber class]])
    {
        NSNumber *lNumber =(NSNumber*) self;
        return lNumber.stringValue;
    }

    return NULL;
}

-(NSNumber*) getNumber
{
    if(self && [self isKindOfClass: [NSNumber class]])
        return (NSNumber*) self;
    return NULL;
}


-(NSDecimalNumber*) getDecimalNumber
{
    if(self && [self isKindOfClass: [NSDecimalNumber class]])
    return (NSDecimalNumber*) self;
    return NULL;
}

-(BOOL) getBool
{
    if(self && [self isKindOfClass: [NSString class]])
    {
        return [(NSString*)self boolValue];
    }
    else if(self && [self isKindOfClass: [NSNumber class]])
    {
        return [(NSNumber*)self boolValue];
    }
    return NO;
}

-(void) logObject
{
    NSLog(@"%@", [self class]);
    NSLog(@"%@", [self description]);
}



@end
