//
//  UserChannel.m
//  HydePark
//
//  Created by Apple on 22/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "UserChannel.h"
#import "NavigationHandler.h"
#import "Utils.h"
#import "UIImageView+RoundImage.h"
#import "AVFoundation/AVFoundation.h"
#import "AsyncImageView.h"
#import "ChannelCell.h"
#import "Constants.h"
#import "CommentsVC.h"

@interface UserChannel ()

@end

@implementation UserChannel
@synthesize ChannelObj;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    videomodel = [[VideoModel alloc]init];
    CommentsModelObj = [[CommentsModel alloc] init];
    [self initViewWithData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initViewWithData{
    friendsImage.imageURL = [NSURL URLWithString:ChannelObj.profile_image];
    NSURL *url = [NSURL URLWithString:ChannelObj.profile_image];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    appDelegate.IS_celeb = ChannelObj.is_celeb;
    friendId = ChannelObj.user_id;
    
    friendsCover.imageURL = [NSURL URLWithString:ChannelObj.profile_image];
    NSURL *url1 = [NSURL URLWithString:ChannelObj.profile_image];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
    
    if ([ChannelObj.state isEqualToString:@"ADD_FRIEND"]) {
        UIImage *buttonBackground = [UIImage imageNamed:@"follow.png"];
        [friendsStatusbtn setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    }
    else{
        UIImage *buttonBackground = [UIImage imageNamed:@"unfollow.png"];
        [friendsStatusbtn setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    }
    friendsNamelbl.text = ChannelObj.full_name;
    friendsBeamcount.text = [[NSString alloc]initWithFormat:@"%@ Beams",ChannelObj.beams_count ];
    friendsFollowings.text = [[NSString alloc]initWithFormat:@"%@ Following",ChannelObj.friends_count];
    friendsFollowers.text = [[NSString alloc]initWithFormat:@"%@ Followers",ChannelObj.likes_count];
    [friendsImage roundImageCorner];
    
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  250.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  ChannelObj.trendingArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChannelCell *cell;
    
    if (IS_IPAD) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChannelCell_iPad" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else{
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChannelCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    UserChannelModel *tempVideos = [[UserChannelModel alloc]init];
    
    tempVideos  = [ChannelObj.trendingArray objectAtIndex:indexPath.row];
    cell.CH_userName.text = tempVideos.userName;
    
    cell.CH_VideoTitle.text = tempVideos.title;
    cell.CH_CommentscountLbl.text = tempVideos.comments_count;
    cell.CH_heartCountlbl.text = tempVideos.like_count;
    cell.CH_seen.text = tempVideos.seen_count;
    
    appDelegate.videotitle = tempVideos.title;
    appDelegate.videotags = tempVideos.Tags;
    appDelegate.profile_pic_url = tempVideos.profile_image;
    cell.Ch_videoLength.text = tempVideos.video_length;
    tempVideos.video_link = [ChannelObj.mainArray objectAtIndex:indexPath.row];
    
    cell.CH_profileImage.imageURL = [NSURL URLWithString:[ChannelObj.ImagesArray objectAtIndex:indexPath.row]];
    NSURL *url = [NSURL URLWithString:[ChannelObj.ImagesArray objectAtIndex:indexPath.row]];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    
    cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:[ChannelObj.ThumbnailsArray objectAtIndex:indexPath.row]];
    NSURL *url1 = [NSURL URLWithString:[ChannelObj.ThumbnailsArray objectAtIndex:indexPath.row]];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
    
    cell.CH_profileImage.layer.cornerRadius = cell.CH_profileImage.frame.size.width / 2;
    for (UIView* subview in cell.CH_profileImage.subviews)
        subview.layer.cornerRadius = cell.CH_profileImage.frame.size.width / 2;
    
    cell.CH_profileImage.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.CH_profileImage.layer.shadowOpacity = 0.7f;
    cell.CH_profileImage.layer.shadowOffset = CGSizeMake(0, 5);
    cell.CH_profileImage.layer.shadowRadius = 5.0f;
    cell.CH_profileImage.layer.masksToBounds = NO;
    
    cell.CH_profileImage.layer.cornerRadius = cell.CH_profileImage.frame.size.width / 2;
    cell.CH_profileImage.layer.masksToBounds = NO;
    cell.CH_profileImage.clipsToBounds = YES;
    
    cell.CH_profileImage.layer.backgroundColor = [UIColor clearColor].CGColor;
    cell.CH_profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.CH_profileImage.layer.borderWidth = 0.0f;
    
    
    //    [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    //    appDelegate.videotoPlay = [userChannelObj.mainArray objectAtIndex:indexPath.row];
    //    [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
    //    [cell.CH_flag addTarget:self action:@selector(editPost:) forControlEvents:UIControlEventTouchUpInside];
    //    [cell.CH_playVideo setTag:indexPath.row];
    //    [cell.CH_heart setTag:indexPath.row];
    //    [cell.CH_flag setTag:indexPath.row];
    
    if ([tempVideos.like_by_me isEqualToString:@"1"]) {
        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
    }else{
        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
    }
    
    
    [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.CH_commentsBtn setTag:indexPath.row];
    
    
    return cell;
}
- (IBAction)UserStatusbtnPressed:(id)sender {
    
    if ([ChannelObj.state isEqualToString:@"ADD_FRIEND"]) {
        [self sendFriendRequest];
        
    }
    else  {
        [self sendDeleteFriend];
    }
}
- (void) sendFriendRequest{
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1) {
                UIImage *buttonBackground = [UIImage imageNamed:@"unfollow.png"];
                [friendsStatusbtn setBackgroundImage:buttonBackground forState:UIControlStateNormal];
                
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
        {[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1) {
                UIImage *buttonBackground = [UIImage imageNamed:@"follow.png"];
                [friendsStatusbtn setBackgroundImage:buttonBackground forState:UIControlStateNormal];
            }
        }else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}

#pragma mark Get Comments

-(void) ShowCommentspressed:(UIButton *)sender{
    
    UIButton *CommentsBtn = (UIButton *)sender;
    currentSelectedIndex = CommentsBtn.tag;
    
    UserChannelModel *tempVideos = [[UserChannelModel alloc]init];
    tempVideos  = [ChannelObj.trendingArray objectAtIndex:currentSelectedIndex];
    
    videomodel.videoID = tempVideos.VideoID;
    videomodel.video_thumbnail_link = tempVideos.video_thumbnail_link;
    videomodel.video_link = tempVideos.video_link;
    videomodel.profile_image =  tempVideos.profile_image;
    videomodel.userName = tempVideos.userName;
    videomodel.is_anonymous = tempVideos.is_anonymous;
    videomodel.title = tempVideos.title;
    videomodel.like_count = tempVideos.like_count;
    videomodel.like_by_me = tempVideos.like_by_me;
    videomodel.seen_count = tempVideos.seen_count;
    videomodel.title = tempVideos.title;
    
    postID = tempVideos.VideoID;
    
    ParentCommentID = @"-1";
    [self GetCommnetsOnPost];
    
}
-(void) GetCommnetsOnPost{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
