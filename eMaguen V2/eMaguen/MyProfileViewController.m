//
//  MyProfileViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 06/09/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "MyProfileViewController.h"
#import "MyAppAppDelegate.h"
#import "UserDataModel.h"
#import "StringID.h"

#define MAX_LENGTH 55

MyAppAppDelegate *mAppDelegate;


@interface MyProfileViewController (){
    UITapGestureRecognizer *tap;
}

@end

@implementation MyProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
        [self addProgressIndicator];
        [self hideProgressIndicator];
    }
    return self;
}

-(void) addNotificationHandlers{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: UPDATE_PROFILE_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: UPDATE_PROFILE_FAILED object: nil];
}

-(void) removeNotificationHandlers{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification{
    [self hideProgressIndicator];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Perfil Actualizado correctamente!!!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    [alert show];
}


-(void)onLoginFailed:(NSNotification*) lNotification{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    txtFieldEmail.text = lUserDataModel.userSOSEmail;
    
//    [self CustomizeTextField:txtFieldEmail];
    txtFieldEmail.delegate = self;
    txtFieldEmail.layer.borderColor = [[UIColor blueColor] CGColor];
    
    bnUpdate.layer.cornerRadius = 5.0f;
    bnUpdate.clipsToBounds = YES;
    
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)handleTap:(id)sender{
    [self.view endEditing:YES];
}

- (IBAction)BnUpdateTapped:(id)sender{
    [self.view endEditing:YES];
    
    if([self validateEmail:txtFieldEmail.text]){
        [[UserDataModel getUserDataModel] callUpdateProfileWebservice:txtFieldEmail.text];
        [self showProgressIndicator];
        mLabelLoading.text = @"Actualizando...";
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Información" message:@"Ingrese email-id válidas" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
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

- (IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setProfileVCAsWindowRootVC];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
