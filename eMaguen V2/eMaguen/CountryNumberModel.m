//
//  AlarmNumber1Model.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 16/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "CountryNumberModel.h"
#import "StringID.h"
#import "UserDataModel.h"
#import "NSString+SBJSON.h"
#import "NSObject+NSClassMethod.h"

#define  COUNTRYNUMBER_URL @"{\"CountryName\":\"%@\",\"AlarmPhoneNumber\":\"%@\"}"

@implementation CountryNumberModel
@synthesize countryNumber = mCountryNumber;

static CountryNumberModel *sGetCountryNumberModel = nil;


+ (CountryNumberModel *)getCountryNumberModel{
    
    @synchronized(self)
    {
        if(sGetCountryNumberModel == nil)
        {
            sGetCountryNumberModel = [[CountryNumberModel alloc] init];
        }
        return sGetCountryNumberModel;
    }
}
- (BOOL)callGetCountryNumberWebserviceWithMobileNo:(NSArray *)alarmData{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
    //    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
//    NSString *lLoginParams = [NSString stringWithFormat:COUNTRYNUMBER_URL,[mobileNumber objectAtIndex:0],[mobileNumber objectAtIndex:1]];
//    NSString *newString = [lLoginParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,newString];
    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL];
    
    mAlarmData = alarmData;
    
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
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_COUNTRYNUMBER_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_COUNTRYNUMBER_FAILED object:self];
        [self resetConnection];
    }
    
}
- (void)parseResultFromConnection:(Connection *)connection{
    
    NSString *urlString = [NSString stringWithFormat:@"%@CountryAssociated",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:COUNTRYNUMBER_URL,[mAlarmData objectAtIndex:0],[mAlarmData objectAtIndex:1]];
    
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    
    NSData *myJSONData =[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[NSData dataWithData:myJSONData]];
    [request setHTTPBody:body];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSError *error;
    mCountryNumber = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&error];
    NSLog(@"Country number Response: %@",mCountryNumber);
}

@end
