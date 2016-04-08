//
//  PopularUsersVC.m
//  HydePark
//
//  Created by Mr on 24/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "PopularUsersVC.h"
#import "Constants.h"
#import "SearchCell.h"
#import "NavigationHandler.h"
#import "Utils.h"
#import "SVProgressHUD.h"
#import "PopularUsersModel.h"
#import "AsyncImageView.h"
#import "UIImageView+RoundImage.h"

@interface PopularUsersVC ()

@end

@implementation PopularUsersVC
//who to follow
- (id)init
{
    if (IS_IPAD) {
        self = [super initWithNibName:@"PopularUsersVC_iPad" bundle:Nil];
    }else if(IS_IPHONE_6 || IS_IPHONE_5 || IS_IPHONE_4){
        
        self = [super initWithNibName:@"PopularUsersVC_iPhone6" bundle:Nil];
    }
    else if (IS_IPHONE_6Plus){
        self = [super initWithNibName:@"PopularUsersVC" bundle:Nil];
    }
    
    return self;
}

- (void)viewWillAppear {
    [super viewWillAppear:YES];
    serverCall = false;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    PopularUserTbl.delegate = self;
    PopularUserTbl.dataSource = self;
    PopUsers = [[PopularUsersModel alloc]init];
    
    pageNum = 1;
    
    [searchField setValue:[UIColor whiteColor]
                    forKeyPath:@"_placeholderLabel.textColor"];
    PopularUserTbl.backgroundColor = [UIColor clearColor];
    PopularUserTbl.opaque = NO;
    [self getFamousUsers];
    if (IS_IPHONE_5 || IS_IPHONE_6) {
        self.view.frame = CGRectMake(0, 0, 375, 667);
        PopularUserTbl.frame = CGRectMake(0, 50, 375, 620);
        
    }
    else if(IS_IPHONE_6Plus)
    {
        PopularUserTbl.frame = CGRectMake(0, 55, 414, 685);
    }
   
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getFamousUsers{
    serverCall = TRUE;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSString *pageStr = [NSString stringWithFormat:@"%d",pageNum];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_FAMOUS_USERS,@"method",
                              token,@"session_token",pageStr,@"page_no",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSLog(@"%@",result);
            if(success == 1) {
                serverCall = FALSE;
                usersArray = [result objectForKey:@"users"];
                
                if([usersArray isKindOfClass:[NSArray class]])
                {
                    if(pageNum == 1) {
                        PopUsers.PopUsersArray = [[NSMutableArray alloc] init];
                        PopUsers.imagesArray = [[NSMutableArray alloc] init];
                    }
                    for(NSDictionary *tempDict in usersArray){
                        PopularUsersModel *_Popusers = [[PopularUsersModel alloc] init];
                        _Popusers.full_name = [tempDict objectForKey:@"full_name"];
                        _Popusers.friendID = [tempDict objectForKey:@"id"];
                        _Popusers.profile_link = [tempDict objectForKey:@"profile_link"];
                        _Popusers.profile_type = [tempDict objectForKey:@"profile_type"];
                        _Popusers.status = [tempDict objectForKey:@"state"];
                        
                        [PopUsers.imagesArray addObject:_Popusers.profile_link];
                        [PopUsers.PopUsersArray addObject:_Popusers];
                        
                    }
                    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                    int startIndex = (pageNum-1) *10;
                    for (int i = startIndex ; i < startIndex+10; i++) {
                        if(i<PopUsers.PopUsersArray.count) {
                            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                        }
                    }
                    [PopularUserTbl beginUpdates];
                    [PopularUserTbl insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [PopularUserTbl endUpdates];
                }
                else {
                    cannotScroll = true;
                }
                
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }else{
            serverCall = FALSE;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

#pragma mark ----------------------
#pragma mark TableView Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    float returnValue;
    if (IS_IPAD)
        returnValue = 121.0f;
    else
        returnValue = 83.0f;
    
    return returnValue;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [PopUsers.PopUsersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    SearchCell *cell;
    float returnValue = 83;
    if(IS_IPAD)
        returnValue = 124;
    PopularUserTbl.contentSize = CGSizeMake(PopularUserTbl.frame.size.width,PopUsers.PopUsersArray.count * returnValue );
    if (IS_IPAD) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchCell_iPad" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else{
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    PopularUsersModel *tempUsers = [[PopularUsersModel alloc]init];
    tempUsers  = [PopUsers.PopUsersArray objectAtIndex:indexPath.row];
    cell.friendsName.text = tempUsers.full_name;
    
    cell.profilePic.imageURL = [NSURL URLWithString:[PopUsers.imagesArray objectAtIndex:indexPath.row]];
    NSURL *url = [NSURL URLWithString:[PopUsers.imagesArray objectAtIndex:indexPath.row]];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    
    [cell.profilePic roundImageCorner];
    
    cell.profilePic.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.profilePic.layer.shadowOpacity = 0.7f;
    cell.profilePic.layer.shadowOffset = CGSizeMake(0, 5);
    cell.profilePic.layer.shadowRadius = 5.0f;
    cell.profilePic.layer.masksToBounds = YES;
    
    cell.profilePic.layer.backgroundColor = [UIColor clearColor].CGColor;
    cell.profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.profilePic.layer.borderWidth = 3.0f;
    
    cell.statusImage.hidden = false;
    cell.activityInd.hidden = true;
    [cell.activityInd stopAnimating];
    [cell.statusImage addTarget:self action:@selector(statusPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.statusImage setTag:indexPath.row];
    
    if ([tempUsers.status isEqualToString:@"ADD_FRIEND"]) {
        
        [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    }else if ([tempUsers.status isEqualToString:@"FRIEND"]){
        
        [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
    }
    
    if ([tempUsers.status isEqualToString:@"PENDING"]) {
        cell.statusImage.hidden = true;
        cell.activityInd.hidden = false;
        [cell.activityInd startAnimating];
    }
    
    
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    NSArray *visibleRows = [PopularUserTbl visibleCells];
    UITableViewCell *lastVisibleCell = [visibleRows lastObject];
    NSIndexPath *path = [PopularUserTbl indexPathForCell:lastVisibleCell];
    if(path.section == 0 && path.row == PopUsers.PopUsersArray.count-1)
    {
        if(!cannotScroll && !serverCall) {
            if(goSearch) {
                searchPageNum++;
            }
            else {
                pageNum++;
                [self getFamousUsers];
            }
        }
        
    }
}

#pragma mark - TableView Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}
- (void)statusPressed:(UIButton *)sender{
    
    UIButton *statusBtn = (UIButton *)sender;
    currentSelectedIndex = statusBtn.tag;
    
    PopularUsersModel *PopUser = [[PopularUsersModel alloc]init];
    PopUser  = [PopUsers.PopUsersArray objectAtIndex:currentSelectedIndex];
    friendId = PopUser.friendID;
    
    [statusBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    
    if ([PopUser.status isEqualToString:@"ADD_FRIEND"]) {
        
        PopUser.status = @"PENDING";
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [PopularUserTbl reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        [self sendFriendRequest:PopUser];
        
    }else if ([PopUser.status isEqualToString:@"PENDING"] || [PopUser.status isEqualToString:@"FRIEND"]){
        
        PopUser.status = @"PENDING";
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [PopularUserTbl reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
        [self sendCancelRequest];
    }
}

- (void) sendCancelRequest{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    PopularUsersModel *PopUser = [[PopularUsersModel alloc]init];
    PopUser  = [PopUsers.PopUsersArray objectAtIndex:currentSelectedIndex];
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
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if(success == 1) {
                
                PopUser.status = @"ADD_FRIEND";
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                [PopularUserTbl reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}

- (void) sendFriendRequest : (PopularUsersModel*) pUser{

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                //[self getFamousUsers];
                //[PopularUserTbl reloadData];
                //[SVProgressHUD dismiss];
                
                pUser.status = @"FRIEND";
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                [PopularUserTbl reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
        }else{
            pUser.status = @"ADD_FRIEND";
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
            [PopularUserTbl reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (IBAction)back:(id)sender {
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"newSignup"])
    {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"newSignup"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NavigationHandler getInstance]NavigateToHomeScreen];
    }
    else{
        [self.navigationController popViewControllerAnimated:true];
    }
}

- (IBAction)Searchbtn:(id)sender {
    
    if(searchField.text.length > 1) {
    
        goSearch = true;
        cannotScroll = false;
        searchPageNum = 1;
        NSString *pageNum = [NSString stringWithFormat:@"%d",searchPageNum];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSURL *url = [NSURL URLWithString:SERVER_URL];
        NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
        
        NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_SEARCH_FRIEND,@"method",
                                  token,@"Session_token",pageNum,@"page_no",searchField.text,@"keyword", nil];
        
        NSData *postData = [Utils encodeDictionary:postDict];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
            if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
            {
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                int success = [[result objectForKey:@"success"] intValue];
                
                if(success == 1) {
                    
                    usersArray = [result objectForKey:@"users_found"];
                    
                    if([usersArray isKindOfClass:[NSArray class]])
                    {
                        if(searchPageNum == 1) {
                            PopUsers.PopUsersArray = [[NSMutableArray alloc] init];
                            PopUsers.imagesArray = [[NSMutableArray alloc] init];
                        }
                        for(NSDictionary *tempDict in usersArray){
                            PopularUsersModel *_Popusers = [[PopularUsersModel alloc] init];
                            _Popusers.full_name = [tempDict objectForKey:@"full_name"];
                            _Popusers.friendID = [tempDict objectForKey:@"id"];
                            _Popusers.profile_link = [tempDict objectForKey:@"profile_link"];
                            _Popusers.profile_type = [tempDict objectForKey:@"profile_type"];
                            _Popusers.status = [tempDict objectForKey:@"state"];
                            
                            [PopUsers.imagesArray addObject:_Popusers.profile_link];
                            [PopUsers.PopUsersArray addObject:_Popusers];
                        }
                        [PopularUserTbl reloadData];
                    }
                    
                    
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                }
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }
    else {
        goSearch = false;
        pageNum = 1;
        
        [self getFamousUsers];
    }
    
}

#pragma - mark TextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}




@end
