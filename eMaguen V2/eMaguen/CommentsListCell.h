//
//  CommentsListCell.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 14/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsListCell : UITableViewCell
{
    IBOutlet UILabel *mLabelDateTime;
    IBOutlet UILabel *mLabelTime;
    
    IBOutlet UILabel *mLabelDescription;
    IBOutlet UILabel *mLabelAuthor;
    
}

@property (nonatomic, retain) UILabel *labelDateTime;
@property (nonatomic, retain) UILabel *labelTime;
@property (nonatomic, retain) UILabel *labelDescription;
@property (nonatomic, retain) UILabel *labelAuthor;



@end
