//
//  AddAlarmModel.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 16/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "AddAlarmModel.h"
#import "StringID.h"
#import "NSString+SBJSON.h"
#import "NSObject+NSClassMethod.h"

#define ADDALARM_URL @"AlarmAgregar?AlarmName=%@&AlarmPhoneNumber=%@&Lat=%@&Lang=%@&Number1=%@&Number2=%@&Number3=%@&Number4=%@&UserNumber=%@&UserName=%@&OwnerNumber=%@"

#define UPDATEALARM_URL @"AlarmAgregar?AlarmName=%@&AlarmPhoneNumber=%@&Lat=%@&Lang=%@&Number1=%@&Number2=%@&Number3=%@&Number4=%@&UserNumber=%@&UserName=%@&OwnerNumber=%@"

@implementation AddAlarmModel

@synthesize alarmAdd = mAlarmAdd;
@synthesize alarmZoneId = mAlarmZoneId;
@synthesize alarmSettings = mAlarmSettings;

static AddAlarmModel *sGetAddAlarmModel = nil;


+ (AddAlarmModel *)getAddAlarmModel{
    
    @synchronized(self)
    {
        if(sGetAddAlarmModel == nil)
        {
            sGetAddAlarmModel = [[AddAlarmModel alloc] init];
        }
        return sGetAddAlarmModel;
    }
}

- (BOOL)callGetAddAlarmWebservice:(AlarmParam *)param{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
    //    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
    NSString *lLoginParams = [NSString stringWithFormat:ADDALARM_URL,param.alarmName,param.alarmNumber,param.lattitude,param.longitude,param.number1,param.number2,param.number3,param.number4,param.userNumber,param.username,param.ownerNumber];
    NSString *newString = [lLoginParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,newString];
    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL1];
    
    mLoginConnection = [[Connection alloc] initWithURL: lURL];
    [mLoginConnection addJSONHeader];
    
    [mLoginConnection setOwner:self];
    [mLoginConnection ConnectionStart];
    
    return lResult;
    
}

- (BOOL)callGetUpdateAlarmWebservice:(AlarmParam *)param{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
    //    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
    NSString *lLoginParams = [NSString stringWithFormat:UPDATEALARM_URL,param.alarmName,param.alarmNumber,param.lattitude,param.longitude,param.number1,param.number2,param.number3,param.number4,param.userNumber,param.username,param.ownerNumber];
    NSString *newString = [lLoginParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,newString];
    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL1];
    
    mUpdateConnection = [[Connection alloc] initWithURL: lURL];
    [mUpdateConnection addJSONHeader];
    
    [mUpdateConnection setOwner:self];
    [mUpdateConnection ConnectionStart];
    
    return lResult;
}

- (void)resetConnection{
    if(mLoginConnection != nil)
    {
        [mLoginConnection setOwner:nil];
        mLoginConnection = nil;
    }
    else if(mUpdateConnection != nil)
    {
        [mUpdateConnection setOwner:nil];
        mUpdateConnection = nil;
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
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_ADDALARM_FINISHED object:self];
        [self resetConnection];
    }
    if([connetion isEqual: mUpdateConnection])
    {
        [self parseResultFromConnection: connetion];
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_UPDATEALARM_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_ADDALARM_FAILED object:self];
        [self resetConnection];
    }
    if([connetion isEqual: mUpdateConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_UPDATEALARM_FAILED object:self];
        [self resetConnection];
    }
}

- (void)parseResultFromConnection:(Connection *)connection{
    
    if(connection == mLoginConnection){
        NSError *error;
        mAlarmSettings = [NSJSONSerialization
                               JSONObjectWithData:connection.ResponceData
                               options:kNilOptions
                               error:&error];
    }
    else if (connection == mUpdateConnection){
        NSError *error;
        mAlarmSettings = [NSJSONSerialization
                                    JSONObjectWithData:connection.ResponceData
                                    options:kNilOptions
                                    error:&error];
    }
}

@end


@implementation AlarmParam

@synthesize username = mUsername;
@synthesize userNumber = mUserNumber;
@synthesize number1 = mNumber1;
@synthesize number2 = mNumber2;
@synthesize number3 = mNumber3;
@synthesize number4 = mNumber4;
@synthesize lattitude = mLattitude;
@synthesize longitude = mLongitude;
@synthesize alarmName = mAlarmName;
@synthesize alarmNumber = mAlarmNumber;
@synthesize ownerNumber = mOwnerNumber;

- (void)dealloc
{
    self.username = nil;
    self.userNumber = nil;
    self.number1 = nil;
    self.number2 = nil;
    self.number3 = nil;
    self.number4 = nil;
    self.lattitude = nil;
    self.longitude = nil;
    self.alarmName = nil;
    self.alarmNumber = nil;
    self.ownerNumber = nil;
}

@end