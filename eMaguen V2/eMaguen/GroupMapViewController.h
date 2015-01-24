//
//  GroupMapViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 12/12/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GroupMapViewController : RootViewController<CLLocationManagerDelegate,MKMapViewDelegate>{
    IBOutlet MKMapView *lMapView;
    IBOutlet UILabel *lblTitle;
}
- (void)setGroupDetails:(NSArray*)groupDetails;
@end
