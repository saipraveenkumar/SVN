//
//  GetPeoplesLocationModel.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 28/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "GetPeoplesLocationModel.h"
#import "StringID.h"
#import "UserDataModel.h"
#import "NSString+SBJSON.h"
#import "NSObject+NSClassMethod.h"

#define  PEOPLE_LOCATION_DETAILS_URL @"GetUsuarioUbicacion?Id=%@"

@implementation GetPeoplesLocationModel

@synthesize peopleLocation = mPeopleLocation;

static GetPeoplesLocationModel *sGetGetPeoplesLocationModel = nil;


+ (GetPeoplesLocationModel *)getGetPeoplesLocationModel{
    
    @synchronized(self)
    {
        if(sGetGetPeoplesLocationModel == nil)
        {
            sGetGetPeoplesLocationModel = [[GetPeoplesLocationModel alloc] init];
        }
        return sGetGetPeoplesLocationModel;
    }
}
- (BOOL)callGetPeoplesLocationModelWebserviceWithUserId:(NSString *)userId{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
    //    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
    NSString *lLoginParams = [NSString stringWithFormat:PEOPLE_LOCATION_DETAILS_URL,userId];
    NSString *newString = [lLoginParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,newString];
    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL1];
    
    mLoginConnection = [[Connection alloc] initWithURL: lURL];
    [mLoginConnection addJSONHeader];
    
    [mLoginConnection setOwner:self];
    [mLoginConnection ConnectionStart];
    
    return lResult;
    
}

- (void)resetConnection{
    if(mLoginConnection != nil)
    {
        [mLoginConnection setOwner:nil];
        mLoginConnection = nil;
    }
}

- (void)resetData{
}



#pragma mark -
#pragma mark - ConnectionDelegate Method

- (void)ConnectionFinished:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [self parseResultFromConnection: connetion];
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_PEOPLE_LOCATION_DETAILS_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_PEOPLE_LOCATION_DETAILS_FAILED object:self];
        [self resetConnection];
    }
    
}
- (void)parseResultFromConnection:(Connection *)connection{
    
    NSString *lResponseBody = [[NSString alloc] initWithData:connection.ResponceData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",lResponseBody);
    NSMutableString *res = [[NSMutableString alloc]initWithString:[lResponseBody substringWithRange:NSMakeRange(1, lResponseBody.length-2)]];
    mPeopleLocation = [res componentsSeparatedByString:@","];
    
}

@end
