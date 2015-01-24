//
//  ShowEventAddCommentViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 29/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface ShowEventAddCommentViewController : RootViewController<UITextViewDelegate>
{
    IBOutlet UITextView *lTextView;
}
-( IBAction)BnSubmitTapped:(id)sender;
-( IBAction)BnBackTapped:(id)sender;
-(void)setEventID:(int)lEventID;
@end
