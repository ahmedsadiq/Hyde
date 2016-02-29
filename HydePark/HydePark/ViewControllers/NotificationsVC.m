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
#import "UserChannelModel.h"
#import "UserChannel.h"
#import "CommentsCell.h"
#import "CommentsVC.h"

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
    userChannelObj = [[UserChannelModel alloc]init];
    CommentsModelObj = [[CommentsModel alloc] init];
    videomodel = [[VideoModel alloc]init];
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
                    _notification.friend_ID         = [_notification.notificationsData objectForKey:@"friend_id"];
                    _notification.post_ID           = [_notification.notificationsData objectForKey:@"post_id"];
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
          [cell.notifyBtn addTarget:self action:@selector(getLikePost:) forControlEvents:UIControlEventTouchUpInside];
    }else if ([str1 isEqualToString:@"LIKE_COMMENT"]) {
        [cell.notifImage setImage:[UIImage imageNamed:@"like.png"]];
    }
    else if ([str1 isEqualToString:@"TAG_FRIENDS"]){
        [cell.notifImage setImage:[UIImage imageNamed:@"tag.png"]];
        
    }else if ([str1 isEqualToString:@"COMMENT_POST"]){
        [cell.notifImage setImage: [UIImage imageNamed:@"comment.png"]];
        [cell.notifyBtn addTarget:self action:@selector(getCommentsPost:) forControlEvents:UIControlEventTouchUpInside];
    }else if ([str1  isEqualToString:@"REQUEST_RECIEVED"]){
        [cell.notifImage setImage:[UIImage imageNamed:@"request.png"]];
        
    }else if([str1 isEqualToString:@"REQUEST_ACCEPTED"]){
        [cell.notifImage setImage:[UIImage imageNamed:@"accept-friend.png"]];
    }
    else if ([str1 isEqualToString:@"FOLLOWED"])
    {
        [cell.notifyBtn addTarget:self action:@selector(getuserChannelBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell.notifyBtn setTag:indexPath.row];
    //cell.message.frame = CGRectMake(cell.Name.frame.origin.x + cell.Name.frame.size.width + 20, cell.message.frame.origin.y, cell.message.frame.size.width, cell.message.frame.size.height);
    
    cell.bgView.layer.shadowColor   = [UIColor lightGrayColor].CGColor;
    cell.bgView.layer.shadowOffset  = CGSizeMake(1.0f, 3.0f);
    cell.bgView.layer.shadowOpacity = 2;
    cell.bgView.layer.shadowRadius  = 4.0;
    
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
-(void)getuserChannelBtn:(UIButton*)sender{
    UIButton *LikeBtn = (UIButton *)sender;
    currentSelectedIndex = LikeBtn.tag;
    NotificationsModel *notifiModel = [[NotificationsModel alloc]init];
    notifiModel  = [notifModel.notificationArray objectAtIndex:currentSelectedIndex];
    friendID = notifiModel.friend_ID;
    [self GetUsersChannel];
}
-(void)getCommentsPost:(UIButton*)sender{
    UIButton *LikeBtn = (UIButton *)sender;
    currentSelectedIndex = LikeBtn.tag;
    NotificationsModel *notifiModel = [[NotificationsModel alloc]init];
    notifiModel  = [notifModel.notificationArray objectAtIndex:currentSelectedIndex];
    postID = notifiModel.post_ID;
    [self getPost];
}
-(void)getLikePost:(UIButton*)sender{
    UIButton *LikeBtn = (UIButton *)sender;
    currentSelectedIndex = LikeBtn.tag;
    NotificationsModel *notifiModel = [[NotificationsModel alloc]init];
    notifiModel  = [notifModel.notificationArray objectAtIndex:currentSelectedIndex];
    NSDictionary *postDate = notifiModel.postData;
    videomodel.userName             = [postDate valueForKey:@"full_name"];
    videomodel.is_anonymous         = [postDate valueForKey:@"is_anonymous"];
    videomodel.title                = [postDate valueForKey:@"caption"];
    videomodel.comments_count       = [postDate valueForKey:@"comment_count"];
    videomodel.topic_id             = [postDate valueForKey:@"topic_id"];
    videomodel.user_id              = [postDate valueForKey:@"user_id"];
    videomodel.profile_image        = [postDate valueForKey:@"profile_link"];
    videomodel.like_count           = [postDate valueForKey:@"like_count"];
    videomodel.seen_count           = [postDate valueForKey:@"seen_count"];
    videomodel.video_link           = [postDate valueForKey:@"video_link"];
    videomodel.video_thumbnail_link = [postDate valueForKey:@"video_thumbnail_link"];
    videomodel.videoID              = [postDate valueForKey:@"id"];
    videomodel.Tags                 = [postDate valueForKey:@"tag_friends"];
    videomodel.video_length         = [postDate valueForKey:@"video_length"];
    videomodel.like_by_me           = [postDate valueForKey:@"like_by_me"];
    CommentsVC *commentController   = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
    commentController.commentsObj   = nil;
    commentController.postArray     = videomodel;
    [[self navigationController] pushViewController:commentController animated:YES];
}
-(void) getPost{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_POST_BY_ID,@"method",
                              token,@"session_token",postID,@"post_id",nil];
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
            NSDictionary *posts = [result objectForKey:@"post"];
            if(success == 1) {
                videomodel.userName = [posts objectForKey:@"full_name"];
                videomodel.is_anonymous = [posts objectForKey:@"is_anonymous"];
                videomodel.title = [posts objectForKey:@"caption"];
                videomodel.comments_count = [posts objectForKey:@"comment_count"];
                videomodel.topic_id = [posts objectForKey:@"topic_id"];
                videomodel.user_id = [posts objectForKey:@"user_id"];
                videomodel.profile_image = [posts objectForKey:@"profile_link"];
                videomodel.like_count = [posts objectForKey:@"like_count"];
                videomodel.seen_count = [posts objectForKey:@"seen_count"];
                videomodel.video_link = [posts objectForKey:@"video_link"];
                videomodel.video_thumbnail_link = [posts objectForKey:@"video_thumbnail_link"];
                videomodel.videoID = [posts objectForKey:@"id"];
                videomodel.Tags = [posts objectForKey:@"tag_friends"];
                videomodel.video_length = [posts objectForKey:@"video_length"];
                videomodel.like_by_me = [posts objectForKey:@"like_by_me"];
                [self getComments];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
-(void) getComments{
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_COMMENTS_BY_PARENT_ID,@"method",
                              token,@"Session_token",@"1",@"page_no",@"-1",@"parent_id",postID,@"post_id", nil];
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
            NSDictionary *users = [result objectForKey:@"comments"];
            
            if(success == 1) {
                
                //////Comments Videos Response //////
                CommentsArray = [result objectForKey:@"comments"];
                CommentsModelObj.CommentsArray = [[NSMutableArray alloc] init];
                CommentsModelObj.mainArray = [[NSMutableArray alloc]init];
                CommentsModelObj.ImagesArray = [[NSMutableArray alloc]init];
                CommentsModelObj.ThumbnailsArray = [[NSMutableArray alloc]init];
                
                for(NSDictionary *tempDict in CommentsArray){
                    
                    CommentsModel *_comment = [[CommentsModel alloc] init];
                    
                    _comment.title = [tempDict objectForKey:@"caption"];
                    _comment.comments_count = [tempDict objectForKey:@"comment_count"];
                    _comment.comment_like_count = [tempDict objectForKey:@"comment_like_count"];
                    _comment.userName = [tempDict objectForKey:@"full_name"];
                    _comment.topic_id = [tempDict objectForKey:@"topic_id"];
                    _comment.user_id = [tempDict objectForKey:@"user_id"];
                    _comment.profile_link = [tempDict objectForKey:@"profile_link"];
                    _comment.liked_by_me = [tempDict objectForKey:@"liked_by_me"];
                    _comment.mute = [tempDict objectForKey:@"mute"];
                    _comment.video_link = [tempDict objectForKey:@"video_link"];
                    _comment.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                    _comment.VideoID = [tempDict objectForKey:@"id"];
                    _comment.video_length = [tempDict objectForKey:@"video_length"];
                    _comment.timestamp = [tempDict objectForKey:@"timestamp"];
                    
                    [CommentsModelObj.ImagesArray addObject:_comment.profile_link];
                    [CommentsModelObj.ThumbnailsArray addObject:_comment.video_thumbnail_link];
                    [CommentsModelObj.mainArray addObject:_comment.video_link];
                    [CommentsModelObj.CommentsArray addObject:_comment];
                    
                    CommentsArray = CommentsModelObj.CommentsArray;
                    commentsVideosArray = CommentsModelObj.mainArray;
                    
                }
                CommentsVC *commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
                commentController.commentsObj = CommentsModelObj;
                commentController.postArray = videomodel;
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
#pragma mark - TableView Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(void) GetUsersChannel{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_USERS_CHANNEL,@"method",
                              token,@"Session_token",@"1",@"page_no",friendID,@"user_id", nil];
    
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
                
                
                //////My Videos Response //////
                
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
    [self.navigationController popViewControllerAnimated:YES];}


@end
