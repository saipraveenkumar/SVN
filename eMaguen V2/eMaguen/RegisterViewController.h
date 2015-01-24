//
//  RegisterViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface RegisterViewController : RootViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *lTextFieldUsername;
    IBOutlet UITextField *lTextFieldEmail;
    IBOutlet UITextField *lTextFieldPassword;
    IBOutlet UITextField *lTextFieldRepeatPassword;
    IBOutlet UITextField *lTextFieldTelephone;
    
    IBOutlet UIScrollView *lScrollView;
    
    IBOutlet UIImageView *lImageLogo;
    IBOutlet UIImageView *lBackImg;
    IBOutlet UIButton *bnBackTap;
    IBOutlet UILabel *lblCrtUsr;
    IBOutlet UIButton *bnRegUsr;
}
- (void)setDetails:(NSArray*)userData;
- (IBAction)BnRegisterTapped:(id)sender;
- (IBAction)BnBackTapped:(id)sender;
@end
