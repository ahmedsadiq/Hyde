//
//  SearchFriendsVCViewController.m
//  HydePark
//
//  Created by Mr on 15/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "SearchFriendsVC.h"
#import "SearchCell.h"
#import "Constants.h"
#import "SVProgressHUD.h"
#import "Utils.h"
#import "PopularUsersModel.h"

@interface SearchFriendsVC ()

@end

@implementation SearchFriendsVC

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
    SearchTable.delegate = self;
    SearchTable.dataSource = self;
    
    UsersModel = [[PopularUsersModel alloc]init];
    
    if (IS_IPHONE_6) {
        
        self.view.frame = CGRectMake(0, 0, 375, 667);
    }
    
}

-(void) SearchFriends{
    [SVProgressHUD showWithStatus:@"Searching..."];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_SEARCH_FRIEND,@"method",
                              token,@"Session_token",@"",@"friend_id",@"1",@"page_no",searchField.text,@"keyword", nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            [SVProgressHUD dismiss];
            
            int success = [[result objectForKey:@"success"] intValue];
            NSString *users = [result objectForKey:@"users_found"];
            
            if(success == 1) {
                
                usersArray = [result objectForKey:@"users_found"];
                UsersModel.PopUsersArray = [[NSMutableArray alloc] init];
                UsersModel.imagesArray = [[NSMutableArray alloc] init];
                
                for(NSDictionary *tempDict in usersArray){
                    
                    PopularUsersModel *_Popusers = [[PopularUsersModel alloc] init];
                    _Popusers.full_name = [tempDict objectForKey:@"full_name"];
                    _Popusers.friendID = [tempDict objectForKey:@"id"];
                    _Popusers.profile_link = [tempDict objectForKey:@"profile_link"];
                    _Popusers.profile_type = [tempDict objectForKey:@"profile_type"];
                    _Popusers.status = [tempDict objectForKey:@"state"];
                    
                    [UsersModel.imagesArray addObject:_Popusers.profile_link];
                    [UsersModel.PopUsersArray addObject:_Popusers];
                    usersArray = UsersModel.PopUsersArray;
                    arrImages = UsersModel.imagesArray;
                }
                
                NSLog(@"%@",UsersModel.PopUsersArray);
                [SearchTable reloadData];

            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
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
        returnValue = 100.0f;
    else
        returnValue = 83.0f;
    
    return returnValue;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [usersArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    SearchCell *cell;
    
    if (IS_IPAD) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchCell_iPad" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else{
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    PopularUsersModel *tempUsers = [[PopularUsersModel alloc]init];
    tempUsers  = [usersArray objectAtIndex:indexPath.row];
    cell.friendsName.text = tempUsers.full_name;
    
    cell.profilePic.imageURL = [NSURL URLWithString:[arrImages objectAtIndex:indexPath.row]];
    NSURL *url = [NSURL URLWithString:[arrImages objectAtIndex:indexPath.row]];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    
    cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2;
    for (UIView* subview in cell.profilePic.subviews)
        subview.layer.cornerRadius = cell.profilePic.frame.size.width / 2;
    
    cell.profilePic.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.profilePic.layer.shadowOpacity = 0.7f;
    cell.profilePic.layer.shadowOffset = CGSizeMake(0, 5);
    cell.profilePic.layer.shadowRadius = 5.0f;
    cell.profilePic.layer.masksToBounds = NO;
    
    cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2;
    cell.profilePic.layer.masksToBounds = NO;
    cell.profilePic.clipsToBounds = YES;
    
    cell.profilePic.layer.backgroundColor = [UIColor clearColor].CGColor;
    cell.profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.profilePic.layer.borderWidth = 3.0f;
    
//    if ([tempUsers.status isEqualToString:@"ADD_FRIEND"]) {
//        [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
//    }
    [cell.statusImage addTarget:self action:@selector(statusPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.statusImage setTag:indexPath.row];
    
    if ([tempUsers.status isEqualToString:@"ADD_FRIEND"]) {
        
        [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    }else if ([tempUsers.status isEqualToString:@"PENDING"]){
        
        [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
    }
    
    return cell;
}
-(void) SearchCorners{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    searchKeyword = searchField.text;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_SEARCH_FRIEND,@"method",
                              token,@"Session_token",@"1",@"page_no",searchKeyword,@"keyword", nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            [SVProgressHUD dismiss];
            
            int success = [[result objectForKey:@"success"] intValue];
            NSString *users = [result objectForKey:@"users_found"];
            
            if(success == 1) {
                searchField.text = nil;
               
                
                usersArray = [result objectForKey:@"users_found"];
                UsersModel.PopUsersArray = [[NSMutableArray alloc] init];
                UsersModel.imagesArray = [[NSMutableArray alloc] init];
                
                for(NSDictionary *tempDict in usersArray){
                    
                    PopularUsersModel *_Popusers = [[PopularUsersModel alloc] init];
                    _Popusers.full_name = [tempDict objectForKey:@"full_name"];
                    _Popusers.friendID = [tempDict objectForKey:@"id"];
                    _Popusers.profile_link = [tempDict objectForKey:@"profile_link"];
                    _Popusers.profile_type = [tempDict objectForKey:@"profile_type"];
                    _Popusers.status = [tempDict objectForKey:@"state"];
                    
                    [UsersModel.imagesArray addObject:_Popusers.profile_link];
                    [UsersModel.PopUsersArray addObject:_Popusers];
                    usersArray = UsersModel.PopUsersArray;
                    arrImages = UsersModel.imagesArray;
                }
                
                NSLog(@"%@",UsersModel.PopUsersArray);
                [SearchTable reloadData];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
    
}
- (void)statusPressed:(UIButton *)sender{
    
    UIButton *statusBtn = (UIButton *)sender;
    currentSelectedIndex = statusBtn.tag;
    
    PopularUsersModel *PopUser = [[PopularUsersModel alloc]init];
    PopUser  = [UsersModel.PopUsersArray objectAtIndex:currentSelectedIndex];
    friendId = PopUser.friendID;
    
    [statusBtn setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    
    if ([PopUser.status isEqualToString:@"ADD_FRIEND"]) {
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        [self sendFriendRequest];
        
    }else if ([PopUser.status isEqualToString:@"PENDING"]){
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
        [self sendCancelRequest];
        
    }else if ([PopUser.status isEqualToString:@"FRIEND"]){
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
        [self sendDeleteFriend];
        
    }else if ([PopUser.status isEqualToString:@"ACCEPT_REQUEST"]){
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        [self sendDeleteFriend];
        
    }
}
- (void) sendDeleteFriend{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_DELETE_FRIEND,@"method",
                              token,@"session_token",friendId,@"friend_id",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                
                [self SearchCorners];
                [SearchTable reloadData];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}


- (void) sendCancelRequest{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_DELETE_REQUEST,@"method",
                              token,@"session_token",friendId,@"friend_id",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                
                [self SearchCorners];
                [SearchTable reloadData];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}

- (void) sendFriendRequest{
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_SEND_REQUEST,@"method",
                              token,@"session_token",friendId,@"friend_id",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                [self SearchCorners];
                [SearchTable reloadData];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}


#pragma mark - TableView Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    
}



- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)Searchbtn:(id)sender {
    
    [self SearchFriends];
    
}

//////////////Hiding Keyboard Touching Backgground/////////////

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([searchField isFirstResponder] && [touch view] != searchField) {
        [searchField resignFirstResponder];
        
    }
    [super touchesBegan:touches withEvent:event];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [searchField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [searchField resignFirstResponder];
    return YES;
}
@end
