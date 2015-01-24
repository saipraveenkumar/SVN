//
//  PendingNotiTableCellTableViewCell.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 04/12/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "PendingNotiTableViewCell.h"

@implementation PendingNotiTableViewCell

@synthesize labelGroup = mLabelGroup;
@synthesize labelOwner = mLabelOwner;

- (void)setFrame:(CGRect)frame {
    frame.origin.y += 3;
    frame.size.height -= 2 * 4;
    [super setFrame:frame];
}

@end
