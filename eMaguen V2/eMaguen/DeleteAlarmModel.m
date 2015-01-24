//
//  DeleteAlarmModel.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 21/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "DeleteAlarmModel.h"
#import "StringID.h"
#import "NSString+SBJSON.h"
#import "NSObject+NSClassMethod.h"

#define DELETEALARM_URL @"AlarmEliminar?AlarmPhoneNumber=%@&UserNumber=%@"

@implementation DeleteAlarmModel

@synthesize alarmDelete = mAlarmDelete;

static DeleteAlarmModel *sGetDeleteAlarmModel = nil;


+ (DeleteAlarmModel *)getDeleteAlarmModel{
    
    @synchronized(self)
    {
        if(sGetDeleteAlarmModel == nil)
        {
            sGetDeleteAlarmModel = [[DeleteAlarmModel alloc] init];
        }
        return sGetDeleteAlarmModel;
    }
}
- (BOOL)callGetAddAlarmWebservice:(NSArray *)alarmDeleteDetails{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
    //    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
    NSString *lLoginParams = [NSString stringWithFormat:DELETEALARM_URL,[alarmDeleteDetails objectAtIndex:0],[alarmDeleteDetails objectAtIndex:1]];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_DELETEALARM_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_DELETEALARM_FAILED object:self];
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
    NSDictionary *lJSONArray = [NSJSONSerialization
                            JSONObjectWithData:data
                            options:kNilOptions
                            error:&error];

    NSLog(@"Alarm: %@",lJSONArray);
    mAlarmDelete = [lJSONArray objectForKey:@"Mensaje"];
    
//    mAlarmAdd = [lResponseBody substringWithRange:NSMakeRange(1, lResponseBody.length-1)];
//    mAlarmAdd = [mAlarmAdd substringWithRange:NSMakeRange(0, mAlarmAdd.length-1)];
    
    //
    //    NSError *error;
    //    mCountryNumber = lResponseBody;
    
    
    //    mArrayAlarms = [[NSMutableArray alloc] init];
    //
    //    for(NSDictionary *dict in lJSONArray){
    //        [mArrayAlarms addObject:dict];
    //    }
    
    //    for (int i = 0; i < [lJSONArray count]; i++){
    //        NSDictionary *lDictionary = [lJSONArray objectAtIndex:i];
    //        [mArrayAlarms addObject:lDictionary];
    //    }
}


@end
