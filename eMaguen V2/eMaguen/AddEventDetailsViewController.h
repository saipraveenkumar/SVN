//
//  AddEventViewControllerDetailsViewController.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 13/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface AddEventDetailsViewController : RootViewController<UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UIActionSheetDelegate,UIActionSheetDelegate>
{
    IBOutlet UITextView *lTextView;
    IBOutlet UILabel *lLabelDateTime;
    IBOutlet UILabel *lLabelCategory, *lLabelPhoto, *lLabelGallery;
    IBOutlet UIButton *lButtonGuardar, *lButtonOpenCamera, *lButtonOpenGallery, *lButtonBack, *lButtonEvents;
    IBOutlet UIImageView *lImageCategory, *lImageVImg, *lImgVewBack, *lImgViewChooseEvent;
    IBOutlet UIImageView *previewImg, *textViewImageView;
}
-(void)CoordDetails:(float)latt and:(float)longi;
-(IBAction )BnDateTimeTapped;
-(IBAction)BnSelectEvent;

@end
