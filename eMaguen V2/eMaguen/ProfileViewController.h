//
//  ProfileViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface ProfileViewController : RootViewController <UITextFieldDelegate>
{
    IBOutlet UILabel *lblServiceStatus;
    IBOutlet UISwitch *lSwitchService;
    
}

- (IBAction)BnMyProfileTapped:(id)sender;

@end
