//
//  AddCommentViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 14/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface AddCommentViewController : RootViewController<UITextViewDelegate,UIAlertViewDelegate>
{
    IBOutlet UITextView *lTextView;
}
-( IBAction)BnSubmitTapped:(id)sender;
-(void) setEventID:(int)lEventID;
-( IBAction)BnBackTapped:(id)sender;


@end
