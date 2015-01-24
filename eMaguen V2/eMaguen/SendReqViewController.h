//
//  ConfigAddAlarmViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 15/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import <MessageUI/MessageUI.h>

@interface SendReqViewController : RootViewController<MFMessageComposeViewControllerDelegate>{
    IBOutlet UILabel *lblMobileNumber1;
    IBOutlet UILabel *lblMobileNumber2;
    IBOutlet UILabel *lblMobileNumber3;
    IBOutlet UIButton *BnYes;
    IBOutlet UIButton *BnNo;
}
- (IBAction)BnSendTapped:(id)sender;
- (IBAction)BnNoTapped:(id)sender;
- (void)setData:(NSArray*)alarmDetails;
@end
