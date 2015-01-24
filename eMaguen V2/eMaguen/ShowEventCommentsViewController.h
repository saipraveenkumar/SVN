//
//  ShowEventCommentsViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 29/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface ShowEventCommentsViewController : RootViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *lTableView;
}
- (IBAction)BnBackTapped;
- (IBAction)BnAddComment:(id)sender;
-(void) setEventID:(int)lEventID;
@end
