//
//  SendLoc.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 17/12/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SendLoc : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    UIBackgroundTaskIdentifier bgTask;
    NSTimer *_timer;
    int locationCounter;
    float mLatitude,mLongitude;
    NSUserDefaults *lUserData;
    NSString *urlString;
    NSData *myJSONData;
    NSMutableURLRequest *request;
    NSMutableData *body;
    CLLocationCoordinate2D coordinate;
    NSString *mLocation, *mCountry;
}
@property (nonatomic) float lattitude;
@property (nonatomic) float longitude;
@property (nonatomic, readonly) NSString *location;
@property (nonatomic, readonly) NSString *country;
+ (SendLoc *)getSendLoc;
- (void)initializeAllValuesForSharingLocation;
- (void)shareCurrentLocation;
- (void)stopShareLocation;
@end
