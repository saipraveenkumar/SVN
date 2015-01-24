//
//  PasswordRecoverViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface PasswordRecoverViewController : RootViewController
{
    IBOutlet UITextField *lTextField;
    IBOutlet UIButton *bnSend;
}
- (IBAction)BnBackTapped:(id)sender;
- (IBAction)BnSubmitTapped:(id)sender;
@end
