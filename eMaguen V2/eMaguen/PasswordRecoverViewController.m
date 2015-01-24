//
//  PasswordRecoverViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "PasswordRecoverViewController.h"
#import "MyAppAppDelegate.h"
#import "UserDataModel.h"
#import "StringID.h"

MyAppAppDelegate *mAppDelegate;

@interface PasswordRecoverViewController (){
    UITapGestureRecognizer *tap;
}

@end

@implementation PasswordRecoverViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
        [self addProgressIndicator];
        [self hideProgressIndicator];
    }
    return self;
}

//Customizing Textfield
-(void)CustomizeTextField:(UITextField *)myTextField
{
    myTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    CGRect rect = myTextField.bounds;
    UIBezierPath *path;
    path = [UIBezierPath bezierPathWithRoundedRect:rect
                                     byRoundingCorners:UIRectCornerTopLeft |UIRectCornerTopRight|UIRectCornerBottomRight|UIRectCornerBottomLeft
                                           cornerRadii:CGSizeMake(8.0, 8.0)];
   
    CAShapeLayer *layers = [CAShapeLayer layer];
    layers.frame = rect;
    layers.path = path.CGPath;
    myTextField.layer.mask = layers;
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: PASSWORD_RECOVER_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: PASSWORD_RECOVER_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
    if([lUserDataModel.userMessage isEqualToString:@"Entered email is not registered email for the user."]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Correo electrónico que no estuviese registrada de correo electrónico del usuario." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Fue enviado un link a su dirección de correo para cambiar su contraseña." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}
-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}


- (IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setLoginVCAsWindowRootVC];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    UIColor *blueColor = [self colorFromHexString:@"#2871b4"];
    [bnSend setTitleColor:blueColor forState:UIControlStateHighlighted];
    if(iPhone5)
        [bnSend setBackgroundImage:[UIImage imageNamed:@"i5_button_on.png"] forState:UIControlStateHighlighted];
    else if(iPhone)
        [bnSend setBackgroundImage:[UIImage imageNamed:@"i4_button_on.png"] forState:UIControlStateHighlighted];
    
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap:(id)sender{
    [self.view endEditing:YES];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (IBAction)BnSubmitTapped:(id)sender{
    if([self validateEmail:lTextField.text]){
        UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
        UserRegisterParam *lUserRegisterParam = [[UserRegisterParam alloc] init];
        lUserRegisterParam.userEmail = lTextField.text;
        [lUserDataModel callForgotPasswordWebservice:lUserRegisterParam];
        [self showProgressIndicator];
        mLabelLoading.text = @"Autorizar Email Id...";
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Ingrese email-id válidas." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

- (BOOL)validateEmail:(NSString *)inputText {
    NSString *emailRegex = @"[A-Z0-9a-z][A-Z0-9a-z._%+-]*@[A-Za-z0-9][A-Za-z0-9.-]*\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    NSRange aRange;
    if([emailTest evaluateWithObject:inputText]) {
        aRange = [inputText rangeOfString:@"." options:NSBackwardsSearch range:NSMakeRange(0, [inputText length])];
        int indexOfDot = (int)aRange.location;
        //NSLog(@"aRange.location:%d - %d",aRange.location, indexOfDot);
        if(aRange.location != NSNotFound) {
            NSString *topLevelDomain = [inputText substringFromIndex:indexOfDot];
            topLevelDomain = [topLevelDomain lowercaseString];
            //NSLog(@"topleveldomains:%@",topLevelDomain);
            NSSet *TLD;
            TLD = [NSSet setWithObjects:@".aero", @".asia", @".biz", @".cat", @".com", @".coop", @".edu", @".gov", @".info", @".int", @".jobs", @".mil", @".mobi", @".museum", @".name", @".net", @".org", @".pro", @".tel", @".travel", @".ac", @".ad", @".ae", @".af", @".ag", @".ai", @".al", @".am", @".an", @".ao", @".aq", @".ar", @".as", @".at", @".au", @".aw", @".ax", @".az", @".ba", @".bb", @".bd", @".be", @".bf", @".bg", @".bh", @".bi", @".bj", @".bm", @".bn", @".bo", @".br", @".bs", @".bt", @".bv", @".bw", @".by", @".bz", @".ca", @".cc", @".cd", @".cf", @".cg", @".ch", @".ci", @".ck", @".cl", @".cm", @".cn", @".co", @".cr", @".cu", @".cv", @".cx", @".cy", @".cz", @".de", @".dj", @".dk", @".dm", @".do", @".dz", @".ec", @".ee", @".eg", @".er", @".es", @".et", @".eu", @".fi", @".fj", @".fk", @".fm", @".fo", @".fr", @".ga", @".gb", @".gd", @".ge", @".gf", @".gg", @".gh", @".gi", @".gl", @".gm", @".gn", @".gp", @".gq", @".gr", @".gs", @".gt", @".gu", @".gw", @".gy", @".hk", @".hm", @".hn", @".hr", @".ht", @".hu", @".id", @".ie", @" No", @".il", @".im", @".in", @".io", @".iq", @".ir", @".is", @".it", @".je", @".jm", @".jo", @".jp", @".ke", @".kg", @".kh", @".ki", @".km", @".kn", @".kp", @".kr", @".kw", @".ky", @".kz", @".la", @".lb", @".lc", @".li", @".lk", @".lr", @".ls", @".lt", @".lu", @".lv", @".ly", @".ma", @".mc", @".md", @".me", @".mg", @".mh", @".mk", @".ml", @".mm", @".mn", @".mo", @".mp", @".mq", @".mr", @".ms", @".mt", @".mu", @".mv", @".mw", @".mx", @".my", @".mz", @".na", @".nc", @".ne", @".nf", @".ng", @".ni", @".nl", @".no", @".np", @".nr", @".nu", @".nz", @".om", @".pa", @".pe", @".pf", @".pg", @".ph", @".pk", @".pl", @".pm", @".pn", @".pr", @".ps", @".pt", @".pw", @".py", @".qa", @".re", @".ro", @".rs", @".ru", @".rw", @".sa", @".sb", @".sc", @".sd", @".se", @".sg", @".sh", @".si", @".sj", @".sk", @".sl", @".sm", @".sn", @".so", @".sr", @".st", @".su", @".sv", @".sy", @".sz", @".tc", @".td", @".tf", @".tg", @".th", @".tj", @".tk", @".tl", @".tm", @".tn", @".to", @".tp", @".tr", @".tt", @".tv", @".tw", @".tz", @".ua", @".ug", @".uk", @".us", @".uy", @".uz", @".va", @".vc", @".ve", @".vg", @".vi", @".vn", @".vu", @".wf", @".ws", @".ye", @".yt", @".za", @".zm", @".zw", nil];
            if(topLevelDomain != nil && ([TLD containsObject:topLevelDomain])) {
                return TRUE;
            }
        }
    }
    return FALSE;
}

@end
