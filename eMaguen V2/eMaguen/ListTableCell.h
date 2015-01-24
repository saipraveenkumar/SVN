//
//  ListTableCell.h
//  CERSAI14
//
//  Created by Rohit Yermalkar on 16/04/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableCell : UITableViewCell
{
    IBOutlet UILabel *mLabelDateTime;
    IBOutlet UILabel *mLabelTitle;
    IBOutlet UILabel *mLabelDescription;
    IBOutlet UILabel *mLabelComments;
    IBOutlet UIImageView *mType;
    
    IBOutlet UIButton *lButtonComments;
    
    
}

@property (nonatomic, retain) UILabel *labelDateTime;
@property (nonatomic, retain) UILabel *labelTitle;
@property (nonatomic, retain) UILabel *labelDescription;
@property (nonatomic, retain) UILabel *labelComments;
@property (nonatomic, retain) UIImageView *type;

@property (nonatomic, retain) UIButton *buttonComments;


@end
