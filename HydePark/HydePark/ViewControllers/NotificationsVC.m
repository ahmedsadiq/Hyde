//
//  NotificationsVC.m
//  HydePark
//
//  Created by ME on 15/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "NotificationsVC.h"
#import "NotificationsCell.h"
#import "Constants.h"
#import "NotificationsModel.h"
#import "NavigationHandler.h"
#import "Utils.h"
#import "ASIFormDataRequest.h"
@interface NotificationsVC ()

@end

@implementation NotificationsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    notifModel = [NotificationsModel alloc];
    
    //notifModel.notificationArray = [[NSMutableArray alloc] initWithObjects:@"Sara",@"Fatima",@"Samia",@"Samra",@"Fiza",@"Rimsha", nil];
    [self getNotigications];
    
}
-(void) getNotigications{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_NOTIFICATIONS,@"method",
                              token,@"session_token",@"1",@"page_no",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            
            if(success == 1){
                notificationsArray = [result objectForKey:@"notifications"];
                notifModel.notificationArray = [[NSMutableArray alloc] init];
                
                for(NSDictionary *tempDict in notificationsArray){
                    
                    NotificationsModel *_notification = [[NotificationsModel alloc] init];
                    
                    _notification.notificationsData = [tempDict objectForKey:@"response"];
                    _notification.notif_ID          = [tempDict objectForKey:@"id"];
                    _notification.time              = [tempDict objectForKey:@"timestamp"];
                    _notification.seen              = [tempDict objectForKey:@"seen"];
                    _notification.notificationType  = [tempDict objectForKey:@"type"];
                    _notification.message           = [_notification.notificationsData objectForKey:@"message"];
                    _notification.postData          = [_notification.notificationsData objectForKey:@"post"];
                   
                    
                    [notifModel.notificationArray addObject:_notification];
                }
                
                [notificationsTbl reloadData];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
            
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----------------------
#pragma mark TableView Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    float returnValue;
    if (IS_IPAD)
        returnValue = 93.0f;
    else
        returnValue = 80.0f;
    
    return returnValue;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [notifModel.notificationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NotificationsCell *cell;
    
    if (IS_IPAD) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NotificationsCell_iPad" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else{
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NotificationsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    if (IS_IPHONE_6) {
        cell.frame = CGRectMake(0, 0, 375, 667);
        cell.contentView.frame = CGRectMake(0, 0, 375, 667);
    }
    
    NotificationsModel *notifiModel = [[NotificationsModel alloc]init];
    notifiModel  = [notifModel.notificationArray objectAtIndex:indexPath.row];
    cell.Time.text = notifiModel.time;
    NSString *str1 = [NSString stringWithFormat:@"%@",notifiModel.notificationType];
    cell.message.text = notifiModel.message;
    if([notifiModel.seen isEqualToString:@"1"]){
        cell.message.textColor = [UIColor redColor];
    }
    if ([str1 isEqualToString:@"LIKE_POST"]) {
        [cell.notifImage setImage:[UIImage imageNamed:@"like.png"]];
    
    }else if ([str1 isEqualToString:@"LIKE_COMMENT"]) {
        [cell.notifImage setImage:[UIImage imageNamed:@"like.png"]];
    }
    else if ([str1 isEqualToString:@"TAG_FRIENDS"]){
        [cell.notifImage setImage:[UIImage imageNamed:@"tag.png"]];
    }else if ([str1 isEqualToString:@"COMMENT_POST"]){
        [cell.notifImage setImage: [UIImage imageNamed:@"comment.png"]];
    }else if ([str1  isEqualToString:@"REQUEST_RECIEVED"]){
        [cell.notifImage setImage:[UIImage imageNamed:@"request.png"]];
        
    }else if([str1 isEqualToString:@"REQUEST_ACCEPTED"]){
        [cell.notifImage setImage:[UIImage imageNamed:@"accept-friend.png"]];
    }
    //cell.message.frame = CGRectMake(cell.Name.frame.origin.x + cell.Name.frame.size.width + 20, cell.message.frame.origin.y, cell.message.frame.size.width, cell.message.frame.size.height);
    
    cell.bgView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    cell.bgView.layer.shadowOffset = CGSizeMake(1.0f, 3.0f);
    cell.bgView.layer.shadowOpacity = 2;
    cell.bgView.layer.shadowRadius = 4.0;
    
    return cell;
}
-(void)cellSwiped:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        UITableViewCell *cell = (UITableViewCell *)gestureRecognizer.view;
        NSIndexPath* index = [notificationsTbl indexPathForCell:cell];
        //..
        [notificationsTbl deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

#pragma mark - TableView Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (IBAction)back:(id)sender {
    
    [[NavigationHandler getInstance]NavigateToHomeScreen];
}


@end
