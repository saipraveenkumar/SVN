//
//  AddPeopleToAlarmViewController.h
//  eMaguen_V2
//
//  Created by Rushikesh Kulkarni on 11/11/14.
//  Copyright (c) 2014 PeleSystem. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>


@interface AddPeopleToAlarmViewController : RootViewController<CLLocationManagerDelegate,ABPeoplePickerNavigationControllerDelegate,UIAlertViewDelegate,MFMessageComposeViewControllerDelegate,ABPersonViewControllerDelegate,UIActionSheetDelegate>
{
    IBOutlet UIButton *contact1;
    IBOutlet UIButton *contact2;
    IBOutlet UIButton *contact3;
    IBOutlet UIButton *contactDelete1;
    IBOutlet UIButton *contactDelete2;
    IBOutlet UIButton *contactDelete3;
    IBOutlet UIImageView *contactDelete1IV;
    IBOutlet UIImageView *contactDelete2IV;
    IBOutlet UIImageView *contactDelete3IV;
    IBOutlet UILabel *lblContactName1, *lblContactName2, *lblContactName3;
    IBOutlet UILabel *lblContactNumber1, *lblContactNumber2, *lblContactNumber3;
    
    IBOutlet UILabel *lblUserNumber;
    
}
- (void)setData:(NSArray*)alarmDetails;
@end


