//
//  PendingNotiTableCellTableViewCell.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 04/12/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingNotiTableViewCell : UITableViewCell
{
    IBOutlet UILabel *mLabelGroup;
    IBOutlet UILabel *mLabelOwner;
}
@property (nonatomic, retain) UILabel *labelGroup;
@property (nonatomic, retain) UILabel *labelOwner;
@end
