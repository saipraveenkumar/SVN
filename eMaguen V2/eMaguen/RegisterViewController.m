//
//  RegisterViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "RegisterViewController.h"
#import "MyAppAppDelegate.h"
#import "StringID.h"
#import "UserDataModel.h"
#import "SendLoc.h"

#define NAME_LENGTH 15
#define MOBILE_LENGTH 15
#define EMAIL_LENGTH 50
#define PASSWORD_MIN_LENGTH 6
#define PASSWORD_MAX_LENGTH 16


MyAppAppDelegate *mAppDelegate;


@interface RegisterViewController (){
    UITapGestureRecognizer *tap;
    BOOL isPwd, isRPwd, isLogin;
    NSArray *mUserData;
    UIAlertView *alertBox;
}
@end

@implementation RegisterViewController

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

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: USER_REGISTER_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: USER_REGISTER_FAILED object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: USER_LOGIN_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: USER_LOGIN_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
//    if(isLogin == YES){
//        if(![lUserDataModel isUserloggedIn])
//        {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:lUserDataModel.userMessage delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
//            [alert show];
//        }
//        else{
//            NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
//            //        UserDataModel *lUserData = [UserDataModel getUserDataModel];
//            NSLog(@"%@-%@",lUserDataModel.userEmail,lUserDataModel.userName);
//            [lData setValue:lUserDataModel.userName forKey:@"kPrefKeyForUpdatedUsername"];
//            NSUserDefaults *lUserDefaults = [NSUserDefaults standardUserDefaults];
//            [lUserDefaults setValue:lUserDataModel.userTelephone forKey:@"kPrefKeyForPhone"];
//            [lUserDefaults setValue:@"0" forKey:@"kPrefKeyForOptionSelection"];
//            [lUserDefaults setValue:lUserDataModel.userNotificationCount forKey:@"kPrefKeyForNotificationCount"];
//            //user Login or not
//            [lUserDefaults setValue:@"1" forKey:@"kPrefKeyForUserLogin"];
//            [lUserDefaults setValue:[NSString stringWithFormat:@"%d",lUserDataModel.userID] forKey:@"kPrefKeyForCoId"];
//            NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:[lUserDefaults objectForKey:@"kPrefKeyForAlarmZoneIds"]];
//            [arr addObject:[lUserDefaults objectForKey:@"kPrefKeyForCoId"]];
//            
//            [[SendLoc getSendLoc] initializeAllValuesForSharingLocation];
//            
//            [mAppDelegate registerForPushWithTag:arr];
//            
//            [mAppDelegate setHomeVCAsWindowRootVC];
//            arr = nil;
//        }
//    }
//    else{
        if(![lUserDataModel isUserRegistered])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Información" message:lUserDataModel.userMessage delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
        else{
            NSUserDefaults *lUserData = [NSUserDefaults standardUserDefaults];
            [lUserData setValue:@"0" forKey:@"kPrefKeyForLocationService"];
            [lUserData setValue:lTextFieldEmail.text forKey:@"kPrefKeyForUpdatedeMail"];
            [lUserData setValue:lTextFieldPassword.text forKey:@"kPrefKeyForUpdatedPassword"];
            [lUserData setValue:@"1" forKey:@"kPrefKeyForUpdatedFlag"];            
            [mAppDelegate setLoginVCAsWindowRootVC];
//            isLogin = YES;
//            UserLoginParam *lUserLoginParam = [[UserLoginParam alloc] init];
//            lUserLoginParam.userName = lTextFieldEmail.text;
//            lUserLoginParam.userPassword = lTextFieldPassword.text;
//            [self addProgressIndicator];
//            [self showProgressIndicator];
//            mLabelLoading.text = @"Autorizando...";
//            UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
//            [lUserDataModel callLoginWebservice:lUserLoginParam];
            //        alertBox = [[UIAlertView alloc]initWithTitle:@"Información" message:@"Usuario registrado correctamente!!!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            //        alertBox.tag = 1;
            //        [alertBox show];
        }
//    }
}

-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)setDetails:(NSArray *)userData{
    mUserData = userData;
    if([[mUserData lastObject] intValue] == 1){
        lTextFieldEmail.text = [mUserData objectAtIndex:1];
        lTextFieldUsername.text = [mUserData objectAtIndex:0];
        lTextFieldEmail.textColor = [UIColor grayColor];
        [lTextFieldEmail setEnabled:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    UIColor *blueColor = [self colorFromHexString:@"#2871b4"];
    [bnRegUsr setTitleColor:blueColor forState:UIControlStateHighlighted];
    if(iPhone5)
        [bnRegUsr setBackgroundImage:[UIImage imageNamed:@"i5_button_on.png"] forState:UIControlStateHighlighted];
    else if(iPhone)
        [bnRegUsr setBackgroundImage:[UIImage imageNamed:@"i4_button_on.png"] forState:UIControlStateHighlighted];
    
    isLogin = NO;
    
    lTextFieldEmail.delegate = self;
    lTextFieldPassword.delegate = self;
    lTextFieldRepeatPassword.delegate = self;
    lTextFieldTelephone.delegate = self;
    lTextFieldUsername.delegate = self;
    
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
    isPwd = NO;
    isRPwd = NO;
}

- (void)handleTap:(id)sender{
    [self.view endEditing:YES];
    if(isPwd == YES){
        [self passwordValidation:lTextFieldPassword];
    }
    if (isRPwd == YES){
        [self passwordValidation:lTextFieldRepeatPassword];
    }
}

- (IBAction)BnTermsTapped:(id)sender{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:TERMS_OF_USE]];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (IBAction)BnRegisterTapped:(id)sender{
    
    if(lTextFieldUsername.text.length == 0 || lTextFieldPassword.text.length == 0 || lTextFieldEmail.text.length == 0 || lTextFieldRepeatPassword.text.length == 0 || lTextFieldTelephone.text.length == 0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Información" message:@"Todos los campos son obligatorios" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else if(![lTextFieldPassword.text isEqualToString:lTextFieldRepeatPassword.text]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Información" message:@"La contraseña no coincide" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
        if([self validateEmail:lTextFieldEmail.text]){
            
            NSString *nameString = lTextFieldUsername.text;
            nameString = [nameString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSString *passwordString = lTextFieldPassword.text;
            passwordString = [passwordString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSString *emailString = lTextFieldEmail.text;
            emailString = [emailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSString *codeString = lTextFieldTelephone.text;
            codeString = [codeString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            
            UserRegisterParam *lUserLoginParam = [[UserRegisterParam alloc] init];
            lUserLoginParam.userName = nameString;
            lUserLoginParam.userPassword = passwordString;
            lUserLoginParam.userEmail = emailString;
            lUserLoginParam.userPhone = codeString;
            
            
            UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
            [lUserDataModel callRegisterWebservice:lUserLoginParam];
            [self showProgressIndicator];
            mLabelLoading.text = @"Registrando...";
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Información" message:@"Ingrese email-id válidas" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
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

- (IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setLoginVCAsWindowRootVC];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    bnBackTap.hidden = YES;
    lblCrtUsr.hidden = YES;
    lBackImg.hidden = YES;
    [lScrollView setFrame:CGRectMake(31, 40, 259, 186)];
    lScrollView.scrollEnabled = NO;
    lImageLogo.hidden = YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    CGRect tempFrame = textField.frame;
    tempFrame.origin.y = 0;
    CGPoint scrollPoint = CGPointMake(0.0, tempFrame.origin.y);
    [lScrollView setContentOffset:scrollPoint animated:YES];
    if(iPhone)
        [lScrollView setFrame:CGRectMake(31, 145, 259, 186)];
    else if (iPhone5){
        [lScrollView setFrame:CGRectMake(31, 175, 259, 186)];
    }
    bnBackTap.hidden = NO;
    lblCrtUsr.hidden = NO;
    lBackImg.hidden = NO;
    lImageLogo.hidden = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField.text.length >= NAME_LENGTH &&  textField.tag == 1){
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= NAME_LENGTH || returnKey;
    }
    else if (textField.text.length >= EMAIL_LENGTH && textField.tag == 3){
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= EMAIL_LENGTH || returnKey;
    }
    else if (textField.text.length >= MOBILE_LENGTH && textField.tag == 2){
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= MOBILE_LENGTH || returnKey;
    }
    else if (textField.text.length >= PASSWORD_MAX_LENGTH && textField.tag == 4){
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= PASSWORD_MAX_LENGTH || returnKey;
    }
    else if (textField.text.length >= PASSWORD_MAX_LENGTH && textField.tag == 5){
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= PASSWORD_MAX_LENGTH || returnKey;
    }
    switch (textField.tag) {
        case 4:
            isPwd = YES;
            break;
        case 5:
            isRPwd = YES;
            break;
        default:
            break;
    }
    
    if(textField==lTextFieldTelephone)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                return NO;
            }
        }
        return YES;
    }
    if(textField==lTextFieldUsername)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"qwertyuioplkjhgfdsazxcvbnmQWERTYUIOPLKJHGFDSAZXCVBNM0123456789._ "];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                return NO;
            }
            else{
                if(textField.text.length == 0){
                    switch (c) {
                        case '.':
                        case '_':
                        case ' ':
                            return NO;
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        return YES;
    }
    if(textField==lTextFieldEmail)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"qwertyuioplkjhgfdsazxcvbnmQWERTYUIOPLKJHGFDSAZXCVBNM0123456789._@"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                return NO;
            }
            else{
                if(textField.text.length == 0){
                    switch (c) {
                        case '.':
                        case '_':
                        case '@':
                            return NO;
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        return YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if([textField.text isEqualToString:@"\n"]){
        return NO;
    }
    return YES;
}

- (void)passwordValidation:(UITextField *)textField {
    if(textField == lTextFieldPassword){
        if([lTextFieldPassword.text length]<PASSWORD_MIN_LENGTH){
            alertBox = [[UIAlertView alloc]initWithTitle:@"Contraseña" message:@"Longitud mínima : 6 and maxima : 16" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            alertBox.tag = 4;
            [alertBox show];
        }
        isPwd = NO;
    }
    else if(textField == lTextFieldRepeatPassword){
        if([lTextFieldRepeatPassword.text length]<PASSWORD_MIN_LENGTH){
            alertBox = [[UIAlertView alloc]initWithTitle:@"Repetir Contraseña" message:@"Longitud mínima : 6 and maxima : 16" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            alertBox.tag = 3;
            [alertBox show];
        }
        else if (![lTextFieldPassword.text isEqualToString:lTextFieldRepeatPassword.text]){
            alertBox = [[UIAlertView alloc]initWithTitle:@"Contraseña" message:@"Contraseña no coincide." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            alertBox.tag = 2;
            [alertBox show];
        }
        isRPwd = NO;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1){
        [mAppDelegate setLoginVCAsWindowRootVC];
    }
    else if (alertView.tag == 2){
        lTextFieldRepeatPassword.text = @"";
        lTextFieldPassword.text = @"";
        [lTextFieldPassword becomeFirstResponder];
    }
    else if (alertView.tag == 3){
        [lTextFieldRepeatPassword becomeFirstResponder];
    }
    else if (alertView.tag == 4){
        [lTextFieldPassword becomeFirstResponder];
    }
}


@end









