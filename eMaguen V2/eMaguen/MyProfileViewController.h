//
//  MyProfileViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 06/09/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface MyProfileViewController : RootViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *txtFieldEmail;
    IBOutlet UIButton *bnUpdate;
}

- (IBAction)BnUpdateTapped:(id)sender;
- (IBAction)BnBackTapped:(id)sender;
@end
