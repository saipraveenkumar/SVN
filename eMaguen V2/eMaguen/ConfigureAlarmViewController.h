//
//  ConfigureAlarmViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 14/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "RootViewController.h"

@interface ConfigureAlarmViewController : RootViewController<UIPickerViewDataSource,UIPickerViewDelegate,MFMessageComposeViewControllerDelegate>
{
    IBOutlet UILabel *lblTitle;
    IBOutlet UIImageView *lblVolumeImage;
    IBOutlet UILabel *lblDelay;
}
- (void)setData:(NSArray *)alarmDetails;
@end
