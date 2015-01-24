//
//  PeopleViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 18/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "SWTableViewCell.h"

@interface PeopleGroupViewController : RootViewController<UIGestureRecognizerDelegate,SWTableViewCellDelegate>{
    IBOutlet UITableView *lTableView;
    int mSelection;
}
@end
