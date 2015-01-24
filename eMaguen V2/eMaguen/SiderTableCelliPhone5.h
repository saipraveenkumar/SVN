//
//  SiderTableCelliPhone5.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 13/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SiderTableCelliPhone5 : UITableViewCell
{
    IBOutlet UILabel *mEventName;
    IBOutlet UIImageView *mEventIcon;
    IBOutlet UIImageView *mEventSelect;
}
@property (nonatomic,retain) UILabel *eventName;
@property (nonatomic,retain) UIImageView *eventIcon;
@property (nonatomic,retain) UIImageView *eventSelect;
@end
