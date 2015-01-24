//
//  PendingInvitViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 04/12/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface PendingInvitViewController : RootViewController{
    IBOutlet UITableView *lTableView;
    NSArray *mNotificationsPending;
}
- (void)setData:(NSArray*)notificationsPend;
@end
