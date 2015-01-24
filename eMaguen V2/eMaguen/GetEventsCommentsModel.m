//
//  GetEventsCommentsModel.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 30/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "GetEventsCommentsModel.h"
#import "StringID.h"
#import "UserDataModel.h"
#import "NSString+SBJSON.h"
#import "NSObject+NSClassMethod.h"

#define  EVENTS_COMMENTS_URL @"ListaComentariosEvento?alias=%@&contrasenia=%@&idEvento=%d"

@implementation GetEventsCommentsModel
@synthesize arrayEventsComments = mArrayEventsComments;


static GetEventsCommentsModel *sGetEventsCommentsModel = nil;


+ (GetEventsCommentsModel *)getEventsCommentsModel{
    
    @synchronized(self)
    {
        if(sGetEventsCommentsModel == nil)
        {
            sGetEventsCommentsModel = [[GetEventsCommentsModel alloc] init];
        }
        return sGetEventsCommentsModel;
    }
}
- (BOOL)callGetEventsCommentsWebserviceWithEventId:(int)lEventId{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
//    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
    NSString *lLoginParams = [NSString stringWithFormat:EVENTS_COMMENTS_URL,[[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedUsername"], [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedPassword"], lEventId];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_EVENTS_COMMENTS_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_EVENTS_COMMENTS_FAILED object:self];
        [self resetConnection];
    }
    
}
- (void)parseResultFromConnection:(Connection *)connection{
    
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
    
    mArrayEventsComments = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [lJSONArray count]; i++){
        NSDictionary *lDictionary = [lJSONArray objectAtIndex:i];
        [mArrayEventsComments addObject:lDictionary];
    }
}

@end
