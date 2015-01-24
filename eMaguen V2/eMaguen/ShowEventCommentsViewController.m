//
//  ShowEventCommentsViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 29/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "ShowEventCommentsViewController.h"
#import "CommentsListCell.h"
#import "StringID.h"
#import "MyAppAppDelegate.h"
#import "GetEventsCommentsModel.h"
#import "GetEventsModel.h"

MyAppAppDelegate *mAppDelegate;

@interface ShowEventCommentsViewController ()
{
    int mEventID, count;
    NSArray *lArray,*lArray2;
    NSString *lDateTime;
    NSString *lTitle;
    NSString *lDescription;
    NSString *lCategory;
    NSString *lImage;
    int flag;
}
@end

@implementation ShowEventCommentsViewController
-(void) setEventID:(int)lEventID{
    mEventID  = lEventID;
//    flag = filter;
//    NSLog(@"%d",mEventID);
    [self getData];
}
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

-(void)loadEventData{
    int i = 0;
    GetEventsModel *lGetEventsModel = [GetEventsModel getGetEventsModel];
    lArray2 = [[NSArray alloc]initWithArray:lGetEventsModel.arrayEvents];
    //    [lArray addObjectsFromArray:lGetEventsModel.arrayEvents];
    for(i = 0; i<[lArray2 count]; i++){
//        NSLog(@"Event id:%d",[[[lArray2 objectAtIndex:i] objectForKey:@"Id"] intValue]);
        if([[[lArray2 objectAtIndex:i] objectForKey:@"Id"] intValue] == mEventID){
//            NSLog(@"The event id:%d,%d",mEventID,i);
//            NSLog(@"The details are:%@",[lArray2 objectAtIndex:i]);
            NSDictionary *lArray1 = [lArray2 objectAtIndex:i];
            lDateTime = [lArray1 objectForKey:@"Fecha"];
            lTitle = [lArray1 objectForKey:@"BarrioNmb"];
            lDescription = [lArray1 objectForKey:@"Descripcion"];
            lCategory = [lArray1 objectForKey:@"Categoria"];
            lImage = [lArray1 objectForKey:@"Foto"];
        }
//        else{
//            NSLog(@"I=%d",i);
//        }
    }
//    NSLog(@"Details:%@,%@,%@,%@,%@,%@",lDateTime,lTitle,lDescription,lCategory,lImage,[NSString stringWithFormat:@"%d",mEventID]);
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_EVENTS_COMMENTS_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_EVENTS_COMMENTS_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self loadData];
}
-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void) loadData{
    GetEventsCommentsModel *lGetEventsCommentsModel = [GetEventsCommentsModel getEventsCommentsModel];
    [lGetEventsCommentsModel callGetEventsCommentsWebserviceWithEventId:mEventID];
    lArray = [[NSArray alloc] initWithArray:lGetEventsCommentsModel.arrayEventsComments];
    count = (int)[lArray count];
//    NSLog(@"Count:%d",count);
//    NSLog(@"The comments:%@",lArray);
    NSLog(@"Comments:%@",lArray);
    [lTableView reloadData];
}

- (IBAction)BnBackTapped{
//    NSLog(@"Details:%@,%@,%@,%@,%@,%@",lDateTime,lTitle,lDescription,lCategory,lImage,[NSString stringWithFormat:@"%d",mEventID]);
    [mAppDelegate ShowEventDetailsVCAsWindowRootVC:[NSString stringWithFormat:@"%d",mEventID]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    count = 0;
    lTableView.delegate = self;
}

- (void) getData{
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    GetEventsCommentsModel *lGetEventsCommentsModel = [GetEventsCommentsModel getEventsCommentsModel];
    [lGetEventsCommentsModel callGetEventsCommentsWebserviceWithEventId:mEventID];
    [self showProgressIndicator];
    mLabelLoading.text = @"Buscando...";
    
    [self loadEventData];
}

//- (IBAction)BnAddTapped:(id)sender{
//    [mAppDelegate setAddCommentsVCAsWindowRootVCWithEventId:mEventID];
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [lArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = 0;
    height = 230;
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"tblCellView";
    CommentsListCell *cell = (CommentsListCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        NSArray * MyCustomCellNib;
        MyCustomCellNib = [[NSBundle mainBundle] loadNibNamed:@"CommentsListCell_iPhone" owner:self options:nil];
        cell = (CommentsListCell *)[MyCustomCellNib lastObject];
    }
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *lArray1 = [lArray objectAtIndex:indexPath.row];
    
    NSString *lDateTimeString =[lArray1 objectForKey:@"Fecha"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSDate *dateTimeString = [format dateFromString:lDateTimeString];
    [format setDateFormat:@"dd/MM/yyyy"];
    
    NSString *date = [format stringFromDate:dateTimeString];
    [format setDateFormat:@"HH:mm"];
    
    NSString *time = [format stringFromDate:dateTimeString];
    
    
    
    
    NSString *lDateTime1 = [NSString stringWithFormat:@"%@",date];
    NSString *lTime = [NSString stringWithFormat:@"%@",time];
    
    NSString *lAuthor = [lArray1 objectForKey:@"CoPropietarioNmb"] ;
    NSString *lDescription1 = [lArray1 objectForKey:@"Nota"];
//    NSLog(@"Description in event comments:%@",lDescription1);
    //stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString *newString = [testString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    cell.labelDateTime.text = lDateTime1;
    cell.labelTime.text = lTime;
    cell.labelAuthor.text = lAuthor;
    cell.labelDescription.text = lDescription1;
    
    
    cell.labelAuthor.textColor = [self colorFromHexString:@"#2871b4"];
    
    return cell;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (IBAction)BnAddComment:(id)sender{
    [mAppDelegate setShowEventAddCommentViewController:mEventID];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
