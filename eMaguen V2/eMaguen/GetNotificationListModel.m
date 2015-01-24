//
//  GetNotificationListModel.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 11/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "GetNotificationListModel.h"
#import "StringID.h"
#import "UserDataModel.h"
#import "NSString+SBJSON.h"
#import "NSObject+NSClassMethod.h"
//#import "SendLoc.h"

#define  NOTIFICATIONS_URL @"ListaBlog?alias=%@&contrasenia=%@"
#define  NOTIFICATION_DETAIL_URL @"BuscarBlog?alias=%@&contrasenia=%@&idBlog=%@"


@implementation GetNotificationListModel

@synthesize arrayNotifications = mArrayNotifcations;
@synthesize notificationData = mNotificationData;


static GetNotificationListModel *sGetNotificationListModel = nil;


+ (GetNotificationListModel *)getGetNotificationListModel{

    @synchronized(self)
    {
        if(sGetNotificationListModel == nil)
        {
            sGetNotificationListModel = [[GetNotificationListModel alloc] init];
        }
        return sGetNotificationListModel;
    }
}

//- (void)stopShareLocationApp{
//    SendLoc *loc = [SendLoc getSendLoc];
//    [loc stopShareLocation];
//}
//
//- (void)startSharingLocation{
//    SendLoc *loc = [SendLoc getSendLoc];
//    [loc shareCurrentLocation];
//}

- (BOOL)callGetNotificationsWebservice{
//    [self stopShareLocationApp];
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
//    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
    
    NSString *lLoginParams = [NSString stringWithFormat:NOTIFICATIONS_URL,[lData objectForKey:@"kPrefKeyForUpdatedUsername"],[lData objectForKey:@"kPrefKeyForUpdatedPassword"]];
    NSString *newString = [lLoginParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,newString];
    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL1];
    
    mLoginConnection = [[Connection alloc] initWithURL: lURL];
    [mLoginConnection addJSONHeader];
    
    [mLoginConnection setOwner:self];
    [mLoginConnection ConnectionStart];
    
    return lResult;

}

- (BOOL)callGetNotificationDetailWebservice:(NSString *)notificationId{
//    [self stopShareLocationApp];
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
//    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
    NSString *lLoginParams = [NSString stringWithFormat:NOTIFICATION_DETAIL_URL,[[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedUsername"], [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedPassword"],notificationId];
    NSString *newString = [lLoginParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,newString];
    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL1];
    
    mNotificationDetailConnection = [[Connection alloc] initWithURL:lURL];
    [mNotificationDetailConnection addJSONHeader];
    
    [mNotificationDetailConnection setOwner:self];
    [mNotificationDetailConnection ConnectionStart];
    
    return lResult;
    
}

- (void)resetConnection{
    if(mLoginConnection != nil)
    {
        [mLoginConnection setOwner:nil];
        mLoginConnection = nil;
    }
    if(mNotificationDetailConnection != nil)
    {
        [mNotificationDetailConnection setOwner:nil];
        mNotificationDetailConnection = nil;
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
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_NOTIFICATIONS_FINISHED object:self];
        [self resetConnection];
    }
    if([connetion isEqual: mNotificationDetailConnection])
    {
        [self parseResultFromConnection: connetion];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DETAIL_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_NOTIFICATIONS_FAILED object:self];
        [self resetConnection];
    }
    if([connetion isEqual: mNotificationDetailConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DETAIL_FAILED object:self];
        [self resetConnection];
    }
}

- (void)parseResultFromConnection:(Connection *)connection{
    
    if(connection == mLoginConnection){
        
        NSString *lResponseBody = [[NSString alloc] initWithData:connection.ResponceData encoding:NSUTF8StringEncoding];
        lResponseBody = [lResponseBody stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        lResponseBody = [lResponseBody substringToIndex:[lResponseBody length] - 1];
        lResponseBody = [lResponseBody substringFromIndex:1];
        NSData* data = [lResponseBody dataUsingEncoding:NSUTF8StringEncoding];
        
        //    NSLog(@"Response: %@",lResponseBody);
        NSError *error;
        NSArray *lJSONArray = [NSJSONSerialization
                               JSONObjectWithData:data
                               options:kNilOptions
                               error:&error];
        
        mArrayNotifcations = [[NSMutableArray alloc] init];
        
        for(NSDictionary *lDictionary in lJSONArray){
            [mArrayNotifcations addObject:lDictionary];
        }
    }
    if(connection == mNotificationDetailConnection){
        NSString *lResponseBody = [[NSString alloc] initWithData:connection.ResponceData encoding:NSUTF8StringEncoding];
        lResponseBody = [lResponseBody stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        lResponseBody = [lResponseBody substringToIndex:[lResponseBody length] - 1];
        lResponseBody = [lResponseBody substringFromIndex:1];
        NSData* data = [lResponseBody dataUsingEncoding:NSUTF8StringEncoding];
        
        //    NSLog(@"Response: %@",lResponseBody);
        NSError *error;
        mNotificationData = [NSJSONSerialization
                               JSONObjectWithData:data
                               options:kNilOptions
                               error:&error];
    }
//    [self startSharingLocation];
}



@end
