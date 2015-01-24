//
//  AddAlarmLocationViewController.h
//  eMaguen_V2
//
//  Created by Rushikesh Kulkarni on 11/11/14.
//  Copyright (c) 2014 PeleSystem. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RootViewController.h"

@interface AddAlarmLocationViewController : RootViewController<MKMapViewDelegate>
{
    IBOutlet MKMapView *lMapView;
    IBOutlet UIButton *lblClear;
}
- (void)setDetails:(NSArray*)alarmDetails;
- (IBAction)BnClearTapped;
@end
