//
//  NotificationDetailViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 14/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface NotificationDetailViewController : RootViewController
{
    IBOutlet UILabel *lDateTime;
    IBOutlet UILabel *lBlogTitle;
    IBOutlet UITextView *lDescription;
    IBOutlet UILabel *lComments;
    
    IBOutlet UIImageView *lImage;
    IBOutlet UIImageView *lImageType;
    IBOutlet UIButton *bnAddComment;
    IBOutlet UIButton *bnShowComments;
}

-(void) setEventID:(int)lEventID;
- (IBAction)BnBackTapped:(id)sender;
- (IBAction)BnCommentsTapped:(id)sender;
- (IBAction)BnAddTapped:(id)sender;
@end
