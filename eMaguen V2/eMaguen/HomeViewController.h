//
//  HomeViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface HomeViewController : RootViewController<CLLocationManagerDelegate,MFMailComposeViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIActionSheetDelegate,UIAlertViewDelegate>
{
    IBOutlet UIImageView *lblMenu;
    IBOutlet UILabel *lblUnreadNotifi;
    IBOutlet UIButton *lblAlarms;
    IBOutlet UIButton *lblPersonas;
    IBOutlet UIButton *lblSOS;
    IBOutlet UIButton *lblFastEvents;
    
    //testing
//    IBOutlet UILabel *lblLatt;
//    IBOutlet UILabel *lblLong;
}
- (void)alertMethodforPush:(NSDictionary *)payload;
@end
