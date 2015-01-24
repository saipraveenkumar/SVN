//
//  ShareEventViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 13/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface ShareEventViewController : RootViewController<UIAlertViewDelegate,UIDocumentInteractionControllerDelegate>

@property(nonatomic,retain) UIDocumentInteractionController *documentationInteractionController;
-(void)DtlsToShare:(NSString *)category and:(NSString*)dateTime and:(NSString*)description and:(NSString*)image and:(NSString*)url;
-(IBAction)BnFacebookTapped:(id)sender;
-(IBAction)BnTwitterTapped:(id)sender;
-(IBAction)BnWhatsappTapped:(id)sender;
@end
