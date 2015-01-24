//
//  ConfigAlarmViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 14/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "SWTableViewCell.h"

@interface ChooseAlarmViewController : RootViewController<UIGestureRecognizerDelegate,SWTableViewCellDelegate, UIAlertViewDelegate>{
    IBOutlet UITableView *lTableView;
}
@end
