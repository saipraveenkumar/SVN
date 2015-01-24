//
//  GetEventsCommentsCountModel.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 31/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "GetEventsCommentsCountModel.h"
#import "StringID.h"
#import "UserDataModel.h"
#import "NSString+SBJSON.h"
#import "NSObject+NSClassMethod.h"

#define  EVENTS_COMMENTS_COUNT_URL @"EventoDetalhes?eventoID=%@"

@implementation GetEventsCommentsCountModel

@synthesize arrayEventsCommentsCount = mArrayEventsCommentsCount;

static GetEventsCommentsCountModel *sGetEventsCommentsCountModel = nil;

+(GetEventsCommentsCountModel *)getEventsCommentsCountModel{
    @synchronized(self){
        if(sGetEventsCommentsCountModel == nil){
            sGetEventsCommentsCountModel = [[GetEventsCommentsCountModel alloc]init];
        }
        return sGetEventsCommentsCountModel;
    }
}

- (BOOL)callGetEventsCommentsCountWebserviceWithEventId:(NSString*)eventId{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
    NSString *lLoginParams = [NSString stringWithFormat:EVENTS_COMMENTS_COUNT_URL,eventId];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_EVENTS_COMMENTS_COUNT_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_EVENTS_COMMENTS_COUNT_FAILED object:self];
        [self resetConnection];
    }
    
}
- (void)parseResultFromConnection:(Connection *)connection{
    
    NSString *lResponseBody = [[NSString alloc] initWithData:connection.ResponceData encoding:NSUTF8StringEncoding];
    lResponseBody = [lResponseBody stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    lResponseBody = [lResponseBody substringToIndex:[lResponseBody length] - 1];
    lResponseBody = [lResponseBody substringFromIndex:1];
//        NSLog(@"Events Response: %@",lResponseBody);
    
    NSData* data = [lResponseBody dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSDictionary *lJSONArray = [NSJSONSerialization
                           JSONObjectWithData:data
                           options:kNilOptions
                           error:&error];
    NSLog(@"Data:%@",lJSONArray);
    
    mArrayEventsCommentsCount = [[NSMutableDictionary alloc]initWithDictionary:lJSONArray];
    
//    NSLog(@"Json:%@",mArrayEventsCommentsCount);
}

@end
