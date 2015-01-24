//
//  MobileNumberViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 09/01/15.
//  Copyright (c) 2015 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface MobileNumberViewController : RootViewController
{
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblEmail;
    IBOutlet UITextField *lblMoibleNumber;
    IBOutlet UIButton *lblRegister;
    IBOutlet UIImageView *lblProfileImage;
}
- (void)setFBUserData:(NSArray *)fbUserDetails;
@end
