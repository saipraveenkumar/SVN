//
//  ShowEventDetailsViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 27/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface ShowEventDetailsViewController : RootViewController
{
    IBOutlet UILabel *lDateTime;
    IBOutlet UILabel *lBlogTitle;
    IBOutlet UIImageView *lImage;
    IBOutlet UIImageView *lImageType;
    IBOutlet UIButton *lBnAddComm;
    IBOutlet UIButton *lBnComm;
    IBOutlet UITextView *lDescription;
}
-(void)setDetails:(NSString*)eventId;
@end
