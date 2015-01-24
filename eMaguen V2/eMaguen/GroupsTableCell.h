//
//  GroupsTableCell.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 02/12/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupsTableCell : UITableViewCell
{
    IBOutlet UILabel *mPersonName;
    IBOutlet UIImageView *mPendingIcon;
}
@property (nonatomic,retain) UILabel *personName;
@property (nonatomic,retain) UIImageView *pendingIcon;
@end
