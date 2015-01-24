//
//  MyApp.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 16/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "ListAlarmsModel.h"
#import "StringID.h"
#import "UserDataModel.h"
#import "NSString+SBJSON.h"
#import "NSObject+NSClassMethod.h"

#define  LISTALARM_URL @"AlarmAssociated?PhoneNumber=%@"

@implementation ListAlarmsModel
@synthesize arrayAlarms = mArrayAlarms;

static ListAlarmsModel *sGetListAlarmsModel = nil;


+ (ListAlarmsModel *)getListAlarmModel{
    
    @synchronized(self)
    {
        if(sGetListAlarmsModel == nil)
        {
            sGetListAlarmsModel = [[ListAlarmsModel alloc] init];
        }
        return sGetListAlarmsModel;
    }
}
- (BOOL)callGetListAlarmWebserviceWithMobileNo:(NSString *)mobileNumber{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
//    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
    NSString *lLoginParams = [NSString stringWithFormat:LISTALARM_URL,mobileNumber];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_LIST_ALARM_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_LIST_ALARM_FAILED object:self];
        [self resetConnection];
    }
    
}
- (void)parseResultFromConnection:(Connection *)connection{
    
    NSString *lResponseBody = [[NSString alloc] initWithData:connection.ResponceData encoding:NSUTF8StringEncoding];
    lResponseBody = [lResponseBody stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    lResponseBody = [lResponseBody substringToIndex:[lResponseBody length] - 1];
    lResponseBody = [lResponseBody substringFromIndex:1];
    NSData* data = [lResponseBody dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *lJSONArray = [NSJSONSerialization
                           JSONObjectWithData:data
                           options:kNilOptions
                           error:&error];
    
    mArrayAlarms = [[NSMutableArray alloc] init];
    
//    for(NSDictionary *dict in lJSONArray){
//        [mArrayAlarms addObject:dict];
//    }
    
    for (int i = 0; i < [lJSONArray count]; i++){
        NSDictionary *lDictionary = [lJSONArray objectAtIndex:i];
        [mArrayAlarms addObject:lDictionary];
    }

}


@end
