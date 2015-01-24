//
//  AddEventModel.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 11/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "AddEventModel.h"
#import "StringID.h"

#define ADD_EVENT_URL @"AgregarEvento"

@implementation AddEventModel

static AddEventModel *sAddEventModel = nil;



+ (AddEventModel *)getAddEventModel
{
    @synchronized(self)
    {
        if(sAddEventModel == nil)
        {
            sAddEventModel = [[AddEventModel alloc] init];
        }
        return sAddEventModel;
    }
}


- (BOOL)callAddEventWebservice:(EventAddParam *)param{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
   
    
    
    NSString *urlString = [NSString stringWithFormat:@"http://emaguenwcfm3.cloudapp.net/JsonService.svc/AgregarEvento"];
    NSString *jsonString = [NSString stringWithFormat:@"{\"alias\":\"Daniel Do Carmo2\",\"contrasenia\":\"daniel\",\"idCategoria\":\"16\",\"nombre\":\"Evento S.O.S\",\"ubicacion\":\"WCFTestApplication\",\"fecha\":\"2014-15-08 15:48:30\",\"descripcion\":\"testImage\",\"latitud\":\"8.99390183523933\",\"longitud\":\"-79.5106978121536\",\"idBarrio\":\"12\",\"Foto\":\"\"}"];
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    
    //NSLog(@"Request: %@",jsonString);
    
    NSData *myJSONData =[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[NSData dataWithData:myJSONData]];
    [request setHTTPBody:body];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Output: %@",returnString);
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_EVENT_FINISHED object:self];
    
    
    
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
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_EVENT_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_EVENT_FAILED object:self];
        [self resetConnection];
    }
   
}
- (void)parseResultFromConnection:(Connection *)connection{
    
//    NSString *lResponseBody = [[NSString alloc] initWithData:connection.ResponceData encoding:NSUTF8StringEncoding];
//    lResponseBody = [lResponseBody stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
//    lResponseBody = [lResponseBody substringToIndex:[lResponseBody length] - 1];
//    lResponseBody = [lResponseBody substringFromIndex:1];
//    //NSLog(@"Response: %@",lResponseBody);
}


@end

@implementation EventAddParam


@synthesize description = mDescription;
@synthesize barrioID = mBarrioId;
@synthesize categoryID = mCategoryId;
@synthesize dateTime = mDateTime;
@synthesize latitude = mLatitutde;
@synthesize location = mLocation;
@synthesize longitude = mLongitude;
@synthesize name = mName;
@synthesize userName = mUserName;
@synthesize userPassword = mUserPassword;
@synthesize image = mImage;

@end