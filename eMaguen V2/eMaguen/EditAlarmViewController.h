//
//  EditAlarmViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 20/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import <MessageUI/MessageUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ReverseGeocodeCountry.h"

@interface EditAlarmViewController : RootViewController<ABPeoplePickerNavigationControllerDelegate,UITextFieldDelegate,UIAlertViewDelegate,MFMessageComposeViewControllerDelegate>
{
    IBOutlet UITextField *lblAlarmName;
    IBOutlet UILabel *lblContact1;
    IBOutlet UILabel *lblContact2;
    IBOutlet UILabel *lblContact3;
    IBOutlet UIButton *bnContact1;
    IBOutlet UIButton *bnContact2;
    IBOutlet UIButton *bnContact3;
    IBOutlet UILabel *lblUserNumber;
}
- (void)setDetails:(NSArray*)alarmDetails;
- (IBAction)BnDetailsUpdate:(id)sender;
- (IBAction)BnBackTapped:(id)sender;
@end
