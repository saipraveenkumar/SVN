//
//  PeopleSendInvitationViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 27/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "RootViewController.h"

@interface PeopleAcceptInvitationViewController : RootViewController<UIAlertViewDelegate>{
    IBOutlet UILabel *lblName;
    IBOutlet UIButton *lblYes;
    IBOutlet UIButton *lblNo;
}
- (void)setInvitaionDetails:(NSDictionary*)invitationDetails;

@end
