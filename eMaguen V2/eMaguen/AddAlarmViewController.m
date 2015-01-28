//
//  AddAlarmViewController.m
//  eMaguen_V2
//
//  Created by Rushikesh Kulkarni on 11/11/14.
//  Copyright (c) 2014 PeleSystem. All rights reserved.
//

#import "AddAlarmViewController.h"
#import "MyAppAppDelegate.h"
#import "StringID.h"
#import "CountryNumberModel.h"
#import "ListAlarmsModel.h"
#import "SendLoc.h"

static NSString *kPrefKeyForCountryNumber = @"kPrefKeyForCountryNumber";

#define MAX_LENGTH 15

MyAppAppDelegate *mAppDelegate;
NSString *countryName;

@interface AddAlarmViewController (){
    //    CLLocationManager *locationManager;
    //    float currentLatitude, currentLongitude;
    CountryNumberModel *lCountryNumber;
    ReverseGeocodeCountry *reverseGeocode;
    UITapGestureRecognizer *tap;
    NSString *almName, *almSimNumber;
    SendLoc *loc;
    UIAlertView *alertBox;
}

@end

@implementation AddAlarmViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
    }
    return self;
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_COUNTRYNUMBER_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_COUNTRYNUMBER_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    NSLog(@"%@",lCountryNumber.countryNumber);
    NSLog(@"Country Number:%@",[lCountryNumber.countryNumber objectForKey:@"CountryCode"]);
    if([[lCountryNumber.countryNumber objectForKey:@"Response"] isEqualToString:@"Success"]){
        NSArray *mobileNumbers = [[lCountryNumber.countryNumber objectForKey:@"Numbers"] subarrayWithRange:NSMakeRange(0,[[lCountryNumber.countryNumber objectForKey:@"NumbersCount"] intValue])];
        if((NSNull*)[lCountryNumber.countryNumber objectForKey:@"CountryCode"]!= [NSNull null]){
            NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
            int match = 0;
            if([mobileNumbers count] == 1){
                match = 0;
            }
            else{
                for(int i = 1; i<[mobileNumbers count];i++){
                    NSString *mobile;
                    mobile = [mobileNumbers objectAtIndex:i];
                    NSLog(@"%@ == %@",mobile,[lData objectForKey:@"kPrefKeyForPhone"]);
                    if([mobile rangeOfString:[lData objectForKey:@"kPrefKeyForPhone"]].location != NSNotFound){
                        match = 2;
                        break;
                    }
                    else{
                        match = 1;
                    }
                    NSLog(@"match = %d",match);
                }
            }
            
            if( match == 0 ){//[lCountryNumber.countryNumber length]>0
                NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
                [lData setObject:[lCountryNumber.countryNumber objectForKey:@"CountryCode"] forKey:kPrefKeyForCountryNumber];
                NSLog(@"\n%@\n%@",lblName.text,lblSimNumber.text);
                
                [mAppDelegate setAddAlarmLocationVCWithAlarmDetails:[NSArray arrayWithObjects:almName, almSimNumber, @"0",nil]];
            }
            else if( match == 1 ){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Este número de alarma ya está asociado con el Sistema eMaguen, usted no tiene permiso para modificar esta alarma ...!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
            }
            else if ( match == 2 ){
                [mAppDelegate setAddAlarmLocationVCWithAlarmDetails:[NSArray arrayWithObjects:almName, almSimNumber, lCountryNumber.countryNumber, @"1",nil]];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Error de red." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Error de red." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    lblName.self.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    reverseGeocode = [[ReverseGeocodeCountry alloc] init];
    
    if(!loc)
        loc = [SendLoc getSendLoc];
    
    lblSubmit.enabled = NO;//-34.903328,-56.131311
    
    [self addProgressIndicator];
    [self showProgressIndicator];
    mLabelLoading.text = @"Buscando...";
    [self performSelectorInBackground:@selector(checkCountryName) withObject:nil];
    
    lblName.delegate = self;
    lblSimNumber.delegate = self;
    
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
    lCountryNumber = [CountryNumberModel getCountryNumberModel];
}

- (void)checkCountryName{
    NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
    int check = [mAppDelegate alertSharingLocation];
    if(check == 0){
        countryName = [reverseGeocode getCountry:loc.lattitude :loc.longitude];
        if([[SendLoc alloc] init].country.length > 0){
            [self hideProgressIndicator];
            countryName = [SendLoc alloc].country;
            lblSubmit.enabled = YES;
        }
        else if (countryName.length > 0){
            [self hideProgressIndicator];
            lblSubmit.enabled = YES;
        }
        else{
            NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ip-api.com/json"]];
            NSURLResponse * response = nil;
            NSError * error = nil;
            NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                                  returningResponse:&response
                                                              error:&error];
            countryName = [[NSJSONSerialization
                            JSONObjectWithData:data
                            options:kNilOptions
                            error:&error] objectForKey:@"country"];
            [self hideProgressIndicator];
            if(countryName.length <= 0){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No se puede obtener el código de país. Inténtalo de nuevo." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
            }
            else{
                lblSubmit.enabled = YES;
            }
        }
        NSLog(@"Contry Name:%@",countryName);
    }
    else{
        NSString *alertMessage;
        NSString *alertOkButton;
        if(check == 1){
           alertMessage = @"Comparte tu ubicación";
           alertOkButton = @"Aceptar";
        }
        else if (check == 2){
            alertMessage = @"Activar servicios de ubicación";
            alertOkButton = @"Ajustes";
        }
       else if (check == 3){
            alertMessage = @"Set Location Service to allow.";
            alertOkButton = @"Ajustes";
        }
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Attention" message:alertMessage delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:alertOkButton , nil];
        alert.tag = 100 + check;
        [alert show];
    }
}

- (void)handleTap:(id)sender{
    [self.view endEditing:YES];
}

- (IBAction)BnSubmitTapped:(id)sender{
    //    option = 1;
    almName = lblName.text;
    almSimNumber = lblSimNumber.text;
    if( almSimNumber.length != 0 && almName.length != 0 ){
        NSLog(@"Country Name:%@",countryName);
        [self addProgressIndicator];
        [self showProgressIndicator];
        [lCountryNumber callGetCountryNumberWebserviceWithMobileNo:[NSArray arrayWithObjects:countryName,almSimNumber, nil]];
        mLabelLoading.text = @"Validación...";
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Introduce ambas Nombre de alarma y número" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setChooseAlarmViewController];
}

-(void)cancel{
    [lblSimNumber resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1){
        [lblSimNumber becomeFirstResponder];
    }
    else if(alertView.tag == 101){
        if(buttonIndex == 1){
            NSUserDefaults *lSetCellIndex = [NSUserDefaults standardUserDefaults];
            [lSetCellIndex setObject:@"3" forKey:@"kPrefKeyForCellIndex"];
            [mAppDelegate setProfileVCAsWindowRootVC];
        }
    }
    else if (alertView.tag == 102){
        if(buttonIndex == 1){
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
            }
            else{
                [[[UIAlertView alloc]initWithTitle:@"Attention" message:@"Turn on Location Services to perform any action.\nSettings -> Privacy -> Location Services (ON)" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil] show];
            }
        }
    }
    else if (alertView.tag == 103){
        if(buttonIndex == 1){
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
            }
            else{
                [[[UIAlertView alloc]initWithTitle:@"Attention" message:@"Turn on Location Services to perform any action.\nSettings -> Privacy -> Location Services (ON)" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil] show];
            }
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(lblSimNumber==textField)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                [textField resignFirstResponder];
                alertBox = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Sólo números permitidos." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                alertBox.tag = 1;
                [alertBox show];
                return NO;
            }
        }
        return YES;
    }
    if(lblName==textField)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-0123456789 "];
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
                        case '_':
                        case '-':
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
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    return newLength <= MAX_LENGTH || returnKey;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if([textField.text isEqualToString:@"\n"]){
        return NO;
    }
    return YES;
}

@end
