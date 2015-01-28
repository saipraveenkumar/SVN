//
//  AddPeopleViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 26/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import <MessageUI/MessageUI.h>


@interface PeopleViewController : RootViewController<MFMessageComposeViewControllerDelegate,UIAlertViewDelegate, UIActionSheetDelegate>{
    IBOutlet UILabel *lblGroupName;
    IBOutlet UITableView *lTableView;
}
- (void)setGroupDetails:(NSArray*)groupDetails;
@end
