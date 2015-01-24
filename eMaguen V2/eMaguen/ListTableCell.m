//
//  ListTableCell.m
//  CERSAI14
//
//  Created by Rohit Yermalkar on 16/04/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "ListTableCell.h"

@implementation ListTableCell

@synthesize labelDateTime = mLabelDateTime;
@synthesize labelDescription = mLabelDescription;
@synthesize labelTitle = mLabelTitle;
@synthesize labelComments = mLabelComments;
@synthesize type = mType;
@synthesize buttonComments = lButtonComments;

- (void)setFrame:(CGRect)frame {
    frame.origin.y += 3;
    frame.size.height -= 2 * 4;
    [super setFrame:frame];
}



@end
