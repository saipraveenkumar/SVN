//
//  PeopleOnMapViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 27/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RootViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface PeopleOnMapViewController : RootViewController<MKMapViewDelegate,UIAlertViewDelegate>{
    IBOutlet MKMapView *lMapView;
    IBOutlet UILabel *lblTitle;
}
- (void)setPersonDetails:(NSArray*)personDetails;
@end


