//
//  CommentsVC.m
//  HydePark
//
//  Created by Apple on 18/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "CommentsVC.h"
#import "Constants.h"
#import "CommentsCell.h"
#import "NavigationHandler.h"
#import "Utils.h"
#import "UIImageView+RoundImage.h"
@interface CommentsVC ()

@end

@implementation CommentsVC

@synthesize commentsObj;
@synthesize postArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CommentsModelObj = [[CommentsModel alloc]init];
    videoModel = [[VideoModel alloc]init];
    [self initMainView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [commentsTable reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initMainView{
    UserImg.imageURL = [NSURL URLWithString:postArray.profile_image];
    coverimgComments.imageURL = [NSURL URLWithString:postArray.video_thumbnail_link];
    NSURL *url = [NSURL URLWithString:postArray.profile_image];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    NSURL *url1 = [NSURL URLWithString:postArray.video_thumbnail_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
    postID = postArray.videoID;
    Postusername.text = postArray.userName;
    videoLengthComments.text = postArray.video_length;
    titleComments.text = postArray.title;
    [UserImg roundImageCorner];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentsCell *cell;
    
    if (IS_IPAD) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell_iPad" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else{
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    commentsTable.contentSize = CGSizeMake(commentsTable.frame.size.width,commentsObj.CommentsArray.count * 250 +  + 30);
    CommentsModel *tempVideos = [[CommentsModel alloc]init];
    tempVideos  = [commentsObj.CommentsArray objectAtIndex:indexPath.row];
    cell.userName.text = tempVideos.userName;
    cell.VideoTitle.text = tempVideos.title;
    
    cell.CommentscountLbl.text = tempVideos.comments_count;
    cell.heartCountlbl.text = tempVideos.like_count;
    cell.seenLbl.text = tempVideos.seen_count;
    cell.userName.text = tempVideos.userName;
    
    //    appDelegate.videotitle = tempVideos.title;
    //    appDelegate.profile_pic_url = tempVideos.profile_link;
    
    tempVideos.video_link = [commentsObj.mainArray objectAtIndex:indexPath.row];
    cell.videoLength.text = tempVideos.video_length;
    
    //        cell.profileImage.imageURL = [NSURL URLWithString:tempVideos.profile_link];
    //
    //        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    
    cell.profileImage.imageURL = [NSURL URLWithString:tempVideos.profile_link];
    NSURL *url = [NSURL URLWithString:tempVideos.profile_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    
    cell.videoThumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    if([tempVideos.video_thumbnail_link isEqualToString:@""] )
    {
        cell.videoThumbnail.imageURL = [NSURL URLWithString:tempVideos.image_link];
        url1 = [NSURL URLWithString:tempVideos.image_link];
        cell.playVideo.hidden = YES;
    }
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
    
    
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
    for (UIView* subview in cell.profileImage.subviews)
        subview.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
    
    cell.profileImage.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.profileImage.layer.shadowOpacity = 0.7f;
    cell.profileImage.layer.shadowOffset = CGSizeMake(0, 5);
    cell.profileImage.layer.shadowRadius = 5.0f;
    cell.profileImage.layer.masksToBounds = NO;
    
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
    cell.profileImage.layer.masksToBounds = NO;
    cell.profileImage.clipsToBounds = YES;
    
    cell.profileImage.layer.backgroundColor = [UIColor clearColor].CGColor;
    cell.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.profileImage.layer.borderWidth = 0.0f;
    //
    cell.profileImagePost.layer.cornerRadius = cell.profileImagePost.frame.size.width / 2;
    for (UIView* subview in cell.profileImagePost.subviews)
        subview.layer.cornerRadius = cell.profileImagePost.frame.size.width / 2;
    
    cell.profileImagePost.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.profileImagePost.layer.shadowOpacity = 0.7f;
    cell.profileImagePost.layer.shadowOffset = CGSizeMake(0, 5);
    cell.profileImagePost.layer.shadowRadius = 5.0f;
    cell.profileImagePost.layer.masksToBounds = NO;
    
    cell.profileImagePost.layer.cornerRadius = cell.profileImagePost.frame.size.width / 2;
    cell.profileImagePost.layer.masksToBounds = NO;
    cell.profileImagePost.clipsToBounds = YES;
    
    cell.profileImagePost.layer.backgroundColor = [UIColor clearColor].CGColor;
    cell.profileImagePost.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.profileImagePost.layer.borderWidth = 0.0f;
    
    [cell.playVideo addTarget:self action:@selector(playVideoComments:) forControlEvents:UIControlEventTouchUpInside];
    [cell.playVideo setTag:indexPath.row];
    
    appDelegate.videotoPlay = [commentsObj.mainArray objectAtIndex:indexPath.row];
    
    [cell.heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([tempVideos.liked_by_me isEqualToString:@"1"]) {
        [cell.heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
    }else{
        [cell.heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
    }
    
    [cell.heart setTag:indexPath.row];
    cell.heartCountlbl.tag = indexPath.row;
    cell.commentsBtn.enabled = YES;
    [cell.commentsBtn addTarget:self action:@selector(ReplyCommentpressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentsBtn setTag:indexPath.row];
    
    cell.seenLbl.tag = indexPath.row;
    
    if(IS_IPHONE_6){
        cell.contentView.frame = CGRectMake(0, 0, 345, 220);
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 250;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  commentsObj.CommentsArray.count;
}
-(void)playVideoComments:(UIButton*)sender{
    UIButton *playBtn = (UIButton *)sender;
    currentSelectedIndex = playBtn.tag;
    CommentsModel *tempVideos = [commentsObj.CommentsArray objectAtIndex:currentSelectedIndex];
    appDelegate.videotoPlay = tempVideos.video_link;
    appDelegate.videoUploader = tempVideos.userName;
    appDelegate.videotitle = tempVideos.title;
    appDelegate.videotags = tempVideos.title;
    appDelegate.profile_pic_url = tempVideos.profile_link;
    //appDelegate.currentScreen = screen;
    postID = tempVideos.VideoID;
    [self SeenPost];
    [[NavigationHandler getInstance]MoveToPlayer];
}
-(void) ReplyCommentpressed:(UIButton *)sender{
    
    UIButton *CommentsBtn = (UIButton *)sender;
    CommentsBtn.enabled = false;
    currentSelectedIndex = CommentsBtn.tag;
    CommentsModel *tempVideos = [[CommentsModel alloc]init];
    tempVideos  = [commentsObj.CommentsArray objectAtIndex:currentSelectedIndex];
    ParentCommentID = tempVideos.VideoID;
    
    videoModel.videoID = tempVideos.VideoID;
    videoModel.video_thumbnail_link = tempVideos.video_thumbnail_link;
    videoModel.video_link = tempVideos.video_link;
    videoModel.profile_image =  tempVideos.profile_link;
    videoModel.userName = tempVideos.userName;
    videoModel.is_anonymous = tempVideos.is_anonymous;
    videoModel.title = tempVideos.title;
    videoModel.like_count = tempVideos.like_count;
    videoModel.like_by_me = tempVideos.liked_by_me;
    videoModel.seen_count = tempVideos.seen_count;
    videoModel.title = tempVideos.title;
    [self GetCommnetsOnPost];
}
-(void) GetCommnetsOnPost{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_COMMENTS_BY_PARENT_ID,@"method",
                              token,@"Session_token",@"1",@"page_no",ParentCommentID,@"parent_id",postID,@"post_id", nil];
    
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
                    _comment.image_link = [tempDict objectForKey:@"image_link"];
                    _comment.VideoID = [tempDict objectForKey:@"id"];
                    _comment.video_length = [tempDict objectForKey:@"video_length"];
                    _comment.timestamp = [tempDict objectForKey:@"timestamp"];
                    
                    [CommentsModelObj.ImagesArray addObject:_comment.profile_link];
                    [CommentsModelObj.ThumbnailsArray addObject:_comment.video_thumbnail_link];
                    [CommentsModelObj.mainArray addObject:_comment.video_link];
                    [CommentsModelObj.CommentsArray addObject:_comment];
                }
               // commentsObj = CommentsModelObj;
                CommentsVC *commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
                commentController.commentsObj = CommentsModelObj;
                commentController.postArray = videoModel;
                [[self navigationController] pushViewController:commentController animated:YES];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)MainPlayBtn:(id)sender {
    UIButton *playBtn = (UIButton *)sender;
    currentSelectedIndex = playBtn.tag;
    appDelegate.videotoPlay = postArray.video_link;
    appDelegate.videoUploader = postArray.userName;
    appDelegate.videotitle = postArray.title;
    appDelegate.videotags = postArray.title;
    appDelegate.profile_pic_url = postArray.profile_image;
    postID = postArray.videoID;
    [self SeenPost];
    [[NavigationHandler getInstance]MoveToPlayer];
}
- (void) SeenPost{
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_POST_SEEN,@"method",
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

        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
@end
