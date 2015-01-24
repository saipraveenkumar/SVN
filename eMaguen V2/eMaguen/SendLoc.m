//
//  SendLoc.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 17/12/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "SendLoc.h"
#import "StringID.h"
#import <CoreLocation/CoreLocation.h>
#import "MyAppAppDelegate.h"

@implementation SendLoc

static SendLoc *sSendLoc = nil;

@synthesize lattitude = mLatitude;
@synthesize longitude = mLongitude;
@synthesize location = mLocation;
@synthesize country = mCountry;

+ (SendLoc *)getSendLoc
{
    @synchronized(self)
    {
        if(sSendLoc == nil)
        {
            sSendLoc = [[SendLoc alloc] init];
        }
        return sSendLoc;
    }
}

- (void)initializeAllValuesForSharingLocation{
    //    [self callBGProcess];
    
    if(!bgTask){
        bgTask =
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        }];
        
        // Make sure you end the background task when you no longer need background execution:
        // [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        if(!locationManager)
            locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        if(!lUserData)
            lUserData = [NSUserDefaults standardUserDefaults];
        if(!request)
            request = [[NSMutableURLRequest alloc] init];
//        [self performSelector:@selector(getStartShareCurrentLocation) withObject:self afterDelay:0];
        [self getStartShareCurrentLocation];
        
        //        [self performSelectorInBackground:@selector(getStartShareCurrentLocation) withObject:self];
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //            [locationManager startUpdatingLocation];
        //            while (TRUE) {
        //                [NSThread sleepForTimeInterval:3.0];
        //                [self callBGProcess];
        //            }
        //        });
    }
}

- (void)shareCurrentLocation{
    [locationManager startUpdatingLocation];
    NSLog(@"Location sharing started.");
}

- (void)stopShareLocation{
    [locationManager stopUpdatingLocation];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getStartShareCurrentLocation) object:nil];
    NSLog(@"Location sharing stopped.");
}

-(CLLocationCoordinate2D) getLocation{
//    CLLocation *location = [locationManager location];
//    NSLog(@"%f,%f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
////    CLLocationCoordinate2D coordinate = [location coordinate];
    return [[locationManager location] coordinate];
}

- (void)getStartShareCurrentLocation{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (TRUE) {
            [NSThread sleepForTimeInterval:5.0];
            [self callBGProcess];
        }
    });
}

- (void)callBGProcess{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        coordinate = [self getLocation];
    mLatitude = coordinate.latitude;
    mLongitude = coordinate.longitude;
        NSLog(@"Latitude  = %f", coordinate.latitude);
        NSLog(@"Longitude = %f", coordinate.longitude);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       NSMutableString *str1;
                       if(!str1)
                           str1= [[NSMutableString alloc]init];
                       if (error) {
                           NSLog(@"Geocode failed with error: %@", error);
                           mLocation = @"Not Available.";
                           mCountry = @"";
                           return;
                       }
                       if (placemarks && placemarks.count > 0)
                       {
                           CLPlacemark *placemark = [placemarks lastObject];
                           NSDictionary *addressDictionary =
                           placemark.addressDictionary;
                           //might get error
                           BOOL isFirst = YES;
                           for(NSString *str in [addressDictionary objectForKey:@"FormattedAddressLines"]){
                               if(isFirst == YES){
                                   [str1 appendString:str];
                                   isFirst = NO;
                               }
                               else
                                   [str1 appendString:[NSString stringWithFormat:@", %@",str]];
                           }
                           mCountry = placemark.country;
                       }
                       mLocation = [NSString stringWithString:str1];
                       str1 = nil;
                       NSLog(@"%@",mLocation);
                   }];
        if([[lUserData objectForKey:@"kPrefKeyForLocationService"] intValue] == 1 && [CLLocationManager locationServicesEnabled] && (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways))){
            urlString = [NSString stringWithFormat:@"%@SetUsuarioUbicacion?Id=%@&Latitude=%f&Longitude=%f",lServiceURL,[lUserData objectForKey:@"kPrefKeyForCoId"],coordinate.latitude,coordinate.longitude];
            NSLog(@"%@",urlString);
            myJSONData =[urlString dataUsingEncoding:NSUTF8StringEncoding];
//            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:urlString]];
            [request setHTTPMethod:@"GET"];
            [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//            NSMutableData *body = [NSMutableData data];
            [body appendData:[NSData dataWithData:myJSONData]];
            [request setHTTPBody:body];
            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSLog(@"Output: %@",returnString);            
        }
        else{
            NSLog(@"Not sending Loc");
        }
//    });
}


//- (void) timerDidFire:(NSTimer *)timer
//{
//    NSLog(@"Timer did fire");
//    locationManager = nil;
//    [self getCurrentLocation];
//}

@end
