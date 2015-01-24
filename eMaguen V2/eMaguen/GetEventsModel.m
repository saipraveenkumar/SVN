//
//  GetEventsModel.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 13/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "GetEventsModel.h"
#import "StringID.h"
#import "UserDataModel.h"
#import "NSString+SBJSON.h"
#import "NSObject+NSClassMethod.h"
//#import "SendLoc.h"

#define  EVENTS_URL @"ListaEventosMiGrupo?alias=%@&contrasenia=%@"


@implementation GetEventsModel

@synthesize arrayEvents = mArrayEvents;



static GetEventsModel *sGetEventsModel = nil;


+ (GetEventsModel *)getGetEventsModel{
    
    @synchronized(self)
    {
        if(sGetEventsModel == nil)
        {
            sGetEventsModel = [[GetEventsModel alloc] init];
        }
        return sGetEventsModel;
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

- (BOOL)callGetEventsWebservice{
//    [self stopShareLocationApp];
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
//    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
    
    //    //
    //    NSString *lLoginParams = [NSString stringWithFormat:LOGIN_URL,param.userName,param.userPassword];
    //    NSString *newString = [lLoginParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,newString];
    //    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL1];
    //
    
    NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
    
    NSString *lLoginParams = [NSString stringWithFormat:EVENTS_URL,[lData objectForKey:@"kPrefKeyForUpdatedUsername"],[lData objectForKey:@"kPrefKeyForUpdatedPassword"]];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_EVENTS_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_EVENTS_FAILED object:self];
        [self resetConnection];
    }
    
}
- (void)parseResultFromConnection:(Connection *)connection{
    
    NSString *lResponseBody = [[NSString alloc] initWithData:connection.ResponceData encoding:NSUTF8StringEncoding];
    lResponseBody = [lResponseBody stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    lResponseBody = [lResponseBody substringToIndex:[lResponseBody length] - 1];
    lResponseBody = [lResponseBody substringFromIndex:1];
//    NSLog(@"Events Response: %@",lResponseBody);
    
    NSData* data = [lResponseBody dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSArray *lJSONArray = [NSJSONSerialization
                           JSONObjectWithData:data
                           options:kNilOptions
                           error:&error];
    
//    NSLog(@"Response:%@",lJSONArray);
    
    mArrayEvents = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [lJSONArray count]; i++){
        NSDictionary *lDictionary = [lJSONArray objectAtIndex:i];
//        NSLog(@"Date:%@",[lDictionary objectForKey:@"Fecha"]);
        [mArrayEvents addObject:lDictionary];
    }
//    [self startSharingLocation];
}


@end





