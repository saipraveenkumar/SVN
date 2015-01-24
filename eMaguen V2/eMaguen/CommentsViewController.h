//
//  CommentsViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 14/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface CommentsViewController : RootViewController
{
    IBOutlet UITableView *lTableView;
    IBOutlet UIImageView *lblTitleBgClr;
    IBOutlet UILabel *lblEventTitle;
}
-(void) setEventID:(int)lEventID andNotificationTitle:(NSString*)notifiTitle;
- (IBAction)BnBackTapped;
//- (IBAction)BnAddTapped:(id)sender;

- (IBAction)BnAddComment:(id)sender;


@end
