//
//  FriendsVC.m
//  HydePark
//
//  Created by Apple on 04/04/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "FriendsVC.h"
#import "Constants.h"
#import "Followings.h"
#import "SearchCell.h"
#import "Utils.h"
#import "UserChannel.h"
@interface FriendsVC ()

@end

@implementation FriendsVC
@synthesize friendsArray,titles,NoFriends;
- (void)viewDidLoad {
    [super viewDidLoad];
    userChannelObj = [[UserChannelModel alloc]init];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear{
    [super viewWillAppear:YES];
    titleLabel.text = titles;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        if (IS_IPAD)
            return 93.0f;
        else
            return 83.0f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
          return  friendsArray.count;
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
    Followings *tempUsers = [[Followings alloc]init];
    tempUsers = [friendsArray objectAtIndex:indexPath.row];
    cell.friendsName.text = tempUsers.fullName;
    
    cell.profilePic.imageURL = [NSURL URLWithString:tempUsers.profile_link];
    NSURL *url = [NSURL URLWithString:tempUsers.profile_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    
    cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2;
    for (UIView* subview in cell.profilePic.subviews)
        subview.layer.cornerRadius = cell.profilePic.frame.size.width / 2;
    
    cell.profilePic.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.profilePic.layer.shadowOpacity = 0.7f;
    cell.profilePic.layer.shadowOffset = CGSizeMake(0, 5);
    // cell.profilePic.layer.shadowRadius = 5.0f;
    cell.profilePic.layer.masksToBounds = NO;
    
    cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2;
    cell.profilePic.layer.masksToBounds = NO;
    cell.profilePic.clipsToBounds = YES;
    
    cell.profilePic.layer.backgroundColor = [UIColor clearColor].CGColor;
    cell.profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.profilePic.layer.borderWidth = 0.0f;
    
    //[cell.statusImage addTarget:self action:@selector(statusPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.statusImage setTag:indexPath.row];
    cell.statusImage.hidden = false;
    cell.activityInd.hidden = true;
    [cell.activityInd stopAnimating];
    if ([tempUsers.status isEqualToString:@"ADD_FRIEND"]) {
        
        [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateHighlighted];
    }else if ([tempUsers.status isEqualToString:@"FRIEND"]){
        
        [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
        [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateHighlighted];
    }
    
    if ([tempUsers.status isEqualToString:@"PENDING"]) {
        cell.statusImage.hidden = true;
        cell.activityInd.hidden = false;
        [cell.activityInd startAnimating];
    }
    if([tempUsers.f_id isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"User_Id"]])
        cell.statusImage.hidden     = YES;
    [cell.friendsChannelBtn addTarget:self action:@selector(OpenFriendsChannelPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.friendsChannelBtn setTag:indexPath.row];
    [cell.tagbtn addTarget:self action:@selector(TagFriend:) forControlEvents:UIControlEventTouchUpInside];
    [cell.tagbtn setTag:indexPath.row];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)statusPressed:(UIButton *)sender{
    
    UIButton *statusBtn = (UIButton *)sender;
    currentSelectedIndex = statusBtn.tag;
    
    Followings *_responseData = [[Followings alloc] init];
    _responseData  = [friendsArray objectAtIndex:currentSelectedIndex];
    friendId = _responseData.f_id;
    
    [statusBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    
    if ([_responseData.status isEqualToString:@"ADD_FRIEND"]) {
        _responseData.status = @"PENDING";
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [_follwersAndFollwings reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        [self sendFriendRequest];
        
    }else if ([_responseData.status isEqualToString:@"PENDING"] || [_responseData.status isEqualToString:@"FRIEND"]){
        _responseData.status = @"PENDING";
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [_follwersAndFollwings reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
        [self sendDeleteFriend];
    }
}
- (void) sendFriendRequest{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    Followings *_responseData = [[Followings alloc] init];
    _responseData  = [friendsArray objectAtIndex:currentSelectedIndex];
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                    _responseData.status = @"FRIEND";
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [_follwersAndFollwings reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
        }else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
- (void) sendDeleteFriend{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    Followings *_responseData = [[Followings alloc] init];
    _responseData  = [friendsArray objectAtIndex:currentSelectedIndex];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_DELETE_FRIEND,@"method",
                              token,@"session_token",friendId,@"friend_id",nil];
    
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
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                    _responseData.status = @"ADD_FRIEND";
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [_follwersAndFollwings reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

-(void) OpenFriendsChannelPressed:(UIButton *)sender{
    
    UIButton *statusBtn = (UIButton *)sender;
    
    currentSelectedIndex = statusBtn.tag;
    Followings *_responseData = [[Followings alloc] init];
    _responseData  = [friendsArray objectAtIndex:currentSelectedIndex];
    friendId = _responseData.f_id;
    [self GetUsersChannel];
}
-(void) GetUsersChannel{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_USERS_CHANNEL,@"method",
                              token,@"Session_token",@"1",@"page_no",friendId,@"user_id", nil];
    
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
            NSDictionary *users = [result objectForKey:@"profile"];
            userChannelObj.state = [result objectForKey:@"state"];
            if(success == 1) {
                //////Profile Response //////
                
                UserChannelModel *_profile = [[UserChannelModel alloc] init];
                ///Saving Data
                userChannelObj.beams_count = [users objectForKey:@"beams_count"];
                userChannelObj.friends_count = [users objectForKey:@"following_count"];
                userChannelObj.full_name = [users objectForKey:@"full_name"];
                userChannelObj.cover_link = [users objectForKey:@"cover_link"];
                userChannelObj.user_id = [users objectForKey:@"id"];
                userChannelObj.profile_image = [users objectForKey:@"profile_link"];
                userChannelObj.likes_count = [users objectForKey:@"followers_count"];
                userChannelObj.gender = [users objectForKey:@"gender"];
                userChannelObj.email = [users objectForKey:@"email"];
                userChannelObj.is_celeb = [users objectForKey:@"is_celeb"];
                
                chPostArray = [result objectForKey:@"posts"];
                userChannelObj.trendingArray = [[NSMutableArray alloc] init];
                userChannelObj.mainArray = [[NSMutableArray alloc]init];
                userChannelObj.ImagesArray = [[NSMutableArray alloc]init];
                userChannelObj.ThumbnailsArray = [[NSMutableArray alloc]init];
                
                for(NSDictionary *tempDict in chPostArray){
                    
                    UserChannelModel *_Videos = [[UserChannelModel alloc] init];
                    
                    _Videos.title = [tempDict objectForKey:@"caption"];
                    _Videos.comments_count = [tempDict objectForKey:@"comment_count"];
                    _Videos.userName = [tempDict objectForKey:@"full_name"];
                    _Videos.topic_id = [tempDict objectForKey:@"topic_id"];
                    _Videos.user_id = [tempDict objectForKey:@"user_id"];
                    _Videos.profile_image = [tempDict objectForKey:@"profile_link"];
                    _Videos.like_count = [tempDict objectForKey:@"like_count"];
                    _Videos.seen_count = [tempDict objectForKey:@"seen_count"];
                    _Videos.video_angle = [[tempDict objectForKey:@"video_angle"] intValue];
                    _Videos.video_link = [tempDict objectForKey:@"video_link"];
                    _Videos.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                    _Videos.VideoID = [tempDict objectForKey:@"id"];
                    _Videos.Tags = [tempDict objectForKey:@"tag_friends"];
                    _Videos.video_length = [tempDict objectForKey:@"video_length"];
                    _Videos.like_by_me = [tempDict objectForKey:@"like_by_me"];
                    _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                    _Videos.reply_count  = [tempDict objectForKey:@"reply_count"];
                    [userChannelObj.ImagesArray addObject:_Videos.profile_image];
                    [userChannelObj.ThumbnailsArray addObject:_Videos.video_thumbnail_link];
                    [userChannelObj.mainArray addObject:_Videos.video_link];
                    [userChannelObj.trendingArray addObject:_Videos];
                    
                    chPostArray = userChannelObj.trendingArray;
                    chVideosArray = userChannelObj.mainArray;
                    chArrImage = userChannelObj.ImagesArray;
                    chArrThumbnail = userChannelObj.ThumbnailsArray;
                }
                UserChannel *commentController = [[UserChannel alloc] initWithNibName:@"UserChannel" bundle:nil];
                commentController.ChannelObj = userChannelObj;
                [[self navigationController] pushViewController:commentController animated:YES];
            }
        }
        else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
    
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
