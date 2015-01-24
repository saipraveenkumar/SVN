//
//  AddAlarmViewController.h
//  eMaguen_V2
//
//  Created by Rushikesh Kulkarni on 11/11/14.
//  Copyright (c) 2014 PeleSystem. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ReverseGeocodeCountry.h"

@interface AddAlarmViewController : RootViewController<UITextFieldDelegate,UIAlertViewDelegate>
{
    IBOutlet UITextField *lblName;
    IBOutlet UITextField *lblSimNumber;
    IBOutlet UIButton *lblSubmit;
    IBOutlet UILabel *lblLattitude;
    IBOutlet UILabel *lblLongitude;
}
- (IBAction)BnSubmitTapped:(id)sender;
//- (void)setData:(int)chooseAlarmType;
@end
