//
//  CommentsListCell.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 14/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "CommentsListCell.h"

@implementation CommentsListCell

@synthesize labelDateTime = mLabelDateTime;
@synthesize labelDescription = mLabelDescription;
@synthesize labelAuthor = mLabelAuthor;
@synthesize labelTime = mLabelTime;



- (void)setFrame:(CGRect)frame {
    frame.origin.y += 1;
    frame.size.height -= 2 * 4;
    [super setFrame:frame];
}


@end
