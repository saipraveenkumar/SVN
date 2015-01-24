//
//  EditAlarmMapViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 25/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import <MapKit/MapKit.h>
#import "ReverseGeocodeCountry.h"
#import <MessageUI/MessageUI.h>

@interface EditAlarmMapViewController : RootViewController<MKMapViewDelegate,MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>{
    IBOutlet MKMapView *lMapViewTemp;
    IBOutlet UIButton *lblUpdateButton;
    IBOutlet UIButton *bnClear;
}
- (void)setAlarmDetails:(NSArray*)alarmDetails;
- (IBAction)BnClearTapped:(id)sender;
@end
