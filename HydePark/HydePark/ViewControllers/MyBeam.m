//
//  MyBeam.m
//  HydePark
//
//  Created by Mr on 22/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "MyBeam.h"
#import "HomeCell.h"
#import "Constants.h"
#import "DrawerVC.h"
#import "Utils.h"
#import "SVProgressHUD.h"
#import "NavigationHandler.h"
#import "CommentsCell.h"
#import "CommentsVC.h"
#import "VideoPlayerVC.h"
#import "VideoModel.h"
#import "BeamUploadVC.h"
@interface MyBeam ()

@end

@implementation MyBeam

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
    mybeamsObj = [[myBeamsModel alloc]init];
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CommentsModelObj = [[CommentsModel alloc] init];
    pageNum = 1;
    videomodel = [[VideoModel alloc]init];
    _TableBeams.backgroundColor = [UIColor clearColor];
    videoObj = [[NSMutableArray alloc] init];
    _TableBeams.opaque = NO;
//    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
//    [tempImageView setFrame:_TableBeams.frame];
//    _TableBeams.backgroundView = tempImageView;
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    //[self getmyBeams];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [editView setHidden:YES];
    [self getmyBeams];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [editView setHidden:YES];
}
- (void) getmyBeams{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *pageStr = [NSString stringWithFormat:@"%d",pageNum];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_MY_BEAMS,@"method",
                              token,@"session_token",pageStr,@"page_no",nil];
    
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
            NSDictionary *beams = [result objectForKey:@"beams"];
            
            if(success == 1) {
                
                NSArray *tempArray = [result objectForKey:@"beams"];
                
                if(tempArray.count> 0) {
                    beamsArray = [result objectForKey:@"beams"];
                    if(pageNum == 1) {
                        mybeamsObj.trendingArray = [[NSMutableArray alloc] init];
                        mybeamsObj.mainArray = [[NSMutableArray alloc]init];
                        mybeamsObj.imagesArray = [[NSMutableArray alloc]init];
                        mybeamsObj.ThumbnailsArray = [[NSMutableArray alloc]init];
                    }
                    
                    
                    for(NSDictionary *tempDict in beamsArray){
                        
                        myBeamsModel *_Videos = [[myBeamsModel alloc] init];
                        
                        _Videos.title = [tempDict objectForKey:@"caption"];
                        _Videos.comments_count = [tempDict objectForKey:@"comment_count"];
                        _Videos.userName = [tempDict objectForKey:@"full_name"];
                        _Videos.topic_id = [tempDict objectForKey:@"topic_id"];
                        _Videos.user_id = [tempDict objectForKey:@"user_id"];
                        _Videos.profile_image = [tempDict objectForKey:@"profile_link"];
                        _Videos.like_count = [tempDict objectForKey:@"like_count"];
                        _Videos.seen_count = [tempDict objectForKey:@"seen_count"];
                        _Videos.video_angle = [[tempDict objectForKey:@"video_angle"] integerValue];
                        _Videos.video_link = [tempDict objectForKey:@"video_link"];
                        _Videos.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                        _Videos.VideoID = [tempDict objectForKey:@"id"];
                        _Videos.video_length = [tempDict objectForKey:@"video_length"];
                        _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                        _Videos.like_by_me = [tempDict objectForKey:@"liked_by_me"];
                        _Videos.reply_count = [tempDict objectForKey:@"reply_count"];
                        [mybeamsObj.imagesArray addObject:_Videos.profile_image];
                        [mybeamsObj.ThumbnailsArray addObject:_Videos.video_thumbnail_link];
                        [mybeamsObj.mainArray addObject:_Videos.video_link];
                        [mybeamsObj.trendingArray addObject:_Videos];
                        
                        beamsArray = mybeamsObj.trendingArray;
                        videosArray = mybeamsObj.mainArray;
                        arrImages = mybeamsObj.imagesArray;
                        arrThumbnail = mybeamsObj.ThumbnailsArray;
                        
                    }
                    [_TableBeams reloadData];
                }
                else {
                    cannotScroll = true;
                }
                
            }
        }
        else{
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
        returnValue = 400.0f;
    else
        returnValue = 230.0f;
    
    if(tableView.tag == 30) {
        
        if (IS_IPAD)
            returnValue = 362.0f;
        else
            returnValue = 250.0f;
    }
    
    return returnValue;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSUInteger rows;
    if (tableView.tag == 0) {
        rows =[beamsArray count];
    }else{
        rows =[CommentsArray count];
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 0) {
        
        HomeCell *cell;
        
        if (IS_IPAD) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        myBeamsModel *tempVideos = [[myBeamsModel alloc]init];
        tempVideos  = [beamsArray objectAtIndex:indexPath.row];
        cell.userName.text = tempVideos.userName;
        
        cell.VideoTitle.text = tempVideos.title;
        cell.CommentscountLbl.text = tempVideos.comments_count;
        cell.heartCountlbl.text = tempVideos.like_count;
        
        tempVideos.video_link = [videosArray objectAtIndex:indexPath.row];
        cell.videoLength.text = tempVideos.video_length;
        
        cell.profileImage.imageURL = [NSURL URLWithString:[arrImages objectAtIndex:indexPath.row]];
        NSURL *url = [NSURL URLWithString:[arrImages objectAtIndex:indexPath.row]];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        
        cell.videoThumbnail.imageURL = [NSURL URLWithString:[arrThumbnail objectAtIndex:indexPath.row]];
        NSURL *url1 = [NSURL URLWithString:[arrThumbnail objectAtIndex:indexPath.row]];
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
        cell.profileImage.layer.borderWidth = 3.0f;
        
        [cell.playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.playVideo setTag:indexPath.row];
        
        appDelegate.videotoPlay = [tempVideos.mainArray objectAtIndex:indexPath.row];
        
        [cell.heart addTarget:self action:@selector(Hearts:) forControlEvents:UIControlEventTouchUpInside];
        [cell.heart setTag:indexPath.row];
        cell.heartCountlbl.tag = indexPath.row;
        
        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
            [cell.heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        [cell.editBtn addTarget:self action:@selector(editbtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.editBtn setTag:indexPath.row];
        [cell.commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.commentsBtn setTag:indexPath.row];
        
        //        [cell.flag addTarget:self action:@selector(Flag:) forControlEvents:UIControlEventTouchUpInside];
        //          [cell.flag setTag:indexPath.row];
        cell.seenLbl.tag = indexPath.row;
        
        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:sgr];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    if(tableView.tag == 30){
        CommentsCell *cell;
        
        if (IS_IPAD) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        CommentsModel *tempVideos = [[CommentsModel alloc]init];
        tempVideos  = [CommentsArray objectAtIndex:indexPath.row];
        cell.userName.text = tempVideos.userName;
        cell.VideoTitle.text = tempVideos.title;
       
        cell.CommentscountLbl.text = tempVideos.comments_count;
        cell.heartCountlbl.text = tempVideos.like_count;
        cell.seenLbl.text = tempVideos.seen_count;
        
        appDelegate.videotitle = tempVideos.title;
        appDelegate.profile_pic_url = tempVideos.profile_link;
        
        tempVideos.video_link = [tempVideos.mainArray objectAtIndex:indexPath.row];
        cell.videoLength.text = tempVideos.video_length;
        
        cell.profileImage.imageURL = [NSURL URLWithString:tempVideos.profile_link];
        NSURL *url = [NSURL URLWithString:tempVideos.profile_link];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        
        cell.profileImagePost.imageURL = [NSURL URLWithString:tempVideos.profile_link];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        
        cell.videoThumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
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
        cell.profileImage.layer.borderWidth = 3.0f;
        
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
        cell.profileImagePost.layer.borderWidth = 3.0f;
        
        [cell.playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.playVideo setTag:indexPath.row];
        
        appDelegate.videotoPlay = [tempVideos.mainArray objectAtIndex:indexPath.row];
        cell.heart.enabled = YES;
        cell.commentsBtn.enabled = YES;
        [cell.heart addTarget:self action:@selector(Hearts:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([tempVideos.liked_by_me isEqualToString:@"1"]) {
            [cell.heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        
        [cell.heart setTag:indexPath.row];
        cell.heartCountlbl.tag = indexPath.row;
        
        [cell.commentsBtn addTarget:self action:@selector(ReplyCommentpressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.commentsBtn setTag:indexPath.row];
        
        cell.seenLbl.tag = indexPath.row;
        
        if(IS_IPHONE_6){
            cell.contentView.frame = CGRectMake(0, 0, 375, 220);
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
    
}
-(void)cellSwiped:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        UITableViewCell *cell = (UITableViewCell *)gestureRecognizer.view;
        NSIndexPath* index = [self.TableBeams indexPathForCell:cell];
        //..
        _optionsView.hidden = NO;
        [self.view addSubview:self.optionsView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    NSArray *visibleRows = [_TableBeams visibleCells];
    UITableViewCell *lastVisibleCell = [visibleRows lastObject];
    NSIndexPath *path = [_TableBeams indexPathForCell:lastVisibleCell];
    if(path.section == 0 && path.row == beamsArray.count-1)
    {
        if(!cannotScroll) {
            if(goSearch) {
                searchPageNum++;
            }
            else {
                pageNum++;
                [self getmyBeams];
            }
        }
        
    }
}

#pragma mark - TableView Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)playVideo:(UIButton*)sender{
    UIButton *playBtn = (UIButton *)sender;
    currentSelectedIndex = playBtn.tag;
    [videoObj removeAllObjects];
    for(int i = 0; i < mybeamsObj.trendingArray.count ; i++){
        myBeamsModel *model = [mybeamsObj.trendingArray objectAtIndex:i];
        VideoModel *temp = [[VideoModel alloc] init];
        temp.is_anonymous           = model.is_anonymous;
        temp.title                  = model.title;
        temp.comments_count         = model.comments_count;
        temp.userName               = model.userName;
        temp.topic_id               = model.topic_id;
        temp.user_id                = model.user_id;
        temp.profile_image          = model.profile_image;
        temp.video_link             = model.video_link;
        temp.video_thumbnail_link   = model.video_thumbnail_link;
        temp.videoID                = model.VideoID;
        temp.video_length           = model.video_length;
        temp.like_count             = model.like_count;
        temp.like_by_me             = model.like_by_me;
        temp.seen_count             = model.seen_count;
        [videoObj addObject:temp];
    }
    VideoPlayerVC *videoPlayer;
    if(IS_IPAD)
        videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPad" bundle:nil];
    else if(IS_IPHONE_6Plus)
        videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPhonePlus" bundle:nil];
    else
        videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
    videoPlayer.videoObjs       = videoObj;
    videoPlayer.indexToDisplay  = currentSelectedIndex;
    videoPlayer.isComment       = FALSE;
    videoPlayer.isFirst         = TRUE;
    videoPlayer.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.6
                     animations:^{
                         [self.view addSubview:videoPlayer.view];
                         videoPlayer.view.transform=CGAffineTransformMakeScale(1, 1);
                     }
                     completion:^(BOOL finished){
                         [videoPlayer.view removeFromSuperview];
                         [self.navigationController pushViewController:videoPlayer animated:NO];
                     }];
    
    [self SeenPost];
}

- (void)Hearts:(UIButton*)sender{
    
    UIButton *LikeBtn = (UIButton *)sender;
    currentSelectedIndex = LikeBtn.tag;
    LikeBtn.enabled = NO;
    myBeamsModel *tempVideos = [[myBeamsModel alloc]init];
    tempVideos  = [mybeamsObj.trendingArray objectAtIndex:currentSelectedIndex];
    
    postID = tempVideos.VideoID;
    [self LikePost];
    
    if (liked == YES) {
        
        [LikeBtn setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        
    }else if (liked == NO){
        
        [LikeBtn setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
    }
    
}

- (void) LikePost{
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_LIKE_POST,@"method",
                              token,@"session_token",postID,@"post_id",nil];
    
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
            NSString *message = [result objectForKey:@"message"];
            
            if(success == 1) {
                if ([message isEqualToString:@"Post is Successfully liked."]) {
                    
                    liked = YES;
                }else if ([message isEqualToString:@"Post is Successfully unliked by this user."])
                    liked = NO;
            }
            [self getmyBeams];
            
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
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
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
           
            int success = [[result objectForKey:@"success"] intValue];
            NSString *message = [result objectForKey:@"message"];
            
            if(success == 1) {
                if ([message isEqualToString:@"Post is Successfully liked."]) {
                    seenPost = YES;
                }else if ([message isEqualToString:@"Post is Successfully unliked by this user."])
                    seenPost = NO;
                
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
#pragma mark editTapped
-(void) editbtnTapped:(UIButton *)sender{
    editView.hidden = NO;
    CGAffineTransform gameModViewTransform = editView.transform;
    editView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [UIView animateWithDuration:0.3/2.0 animations:^{
        editView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            editView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                editView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
    editView.transform = gameModViewTransform;
    UIButton *editbtn = (UIButton *)sender;
    currentSelectedIndex = editbtn.tag;
}
- (IBAction)CancelEditBtn:(id)sender{
    [editView removeFromSuperview];
}
- (IBAction)editBeam:(id)sender{
    myBeamsModel *tempVideos = [[myBeamsModel alloc]init];
    tempVideos  = [beamsArray objectAtIndex:currentSelectedIndex];
    NSString *postIDs = tempVideos.VideoID;
    BeamUploadVC *uploadController = [[BeamUploadVC alloc] initWithNibName:@"BeamUploadVC" bundle:nil];
    uploadController.video_thumbnail = tempVideos.video_thumbnail_link;
    uploadController.postID = postIDs;
    appDelegate.hasbeenEdited = TRUE;
    [[self navigationController] pushViewController:uploadController animated:YES];
}
-(IBAction)DeleteBtn:(id)sender{
    [editView setHidden:YES];
    myBeamsModel *tempVideos = [[myBeamsModel alloc]init];
    tempVideos  = [beamsArray objectAtIndex:currentSelectedIndex];
    NSString *postIDs = tempVideos.VideoID;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"deletePost",@"method",
                              token,@"session_token",postIDs,@"post_id",nil];
    
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
            NSString *message = [result objectForKey:@"message"];
            if(success == 1){
                [mybeamsObj.trendingArray removeObjectAtIndex:currentSelectedIndex];
                beamsArray = mybeamsObj.trendingArray;
                [_TableBeams reloadData];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done" message:message
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
#pragma mark Get Comments

-(void) ShowCommentspressed:(UIButton *)sender{
    UIButton *CommentsBtn = (UIButton *)sender;
    currentSelectedIndex = CommentsBtn.tag;
    
    myBeamsModel *tempVideos = [[myBeamsModel alloc]init];
    tempVideos  = [beamsArray objectAtIndex:currentSelectedIndex];
    
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
    videomodel.reply_count = tempVideos.reply_count;
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
                CommentsVC *commentController ;
                if(IS_IPAD)
                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC_iPad" bundle:nil];
                else
                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
                commentController.commentsObj = CommentsModelObj;
                commentController.postArray = videomodel;
                [[self navigationController] pushViewController:commentController animated:YES];
                
                //                [commentsTable reloadData];
                //                [self.view addSubview:commentsView];
                if (IS_IPHONE_6) {
                    commentsView.frame = CGRectMake(0, 0, 375, 667);
                    commentsTable.frame = CGRectMake(0,297,375,370);
                }
            }
        }
        else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
}

- (IBAction)CommentsBack:(id)sender {
    
    CommentsArray = nil;
    [commentsView removeFromSuperview];
}



- (IBAction)backBtn:(id)sender {
    _optionsView.hidden = YES;
    [_optionsView removeFromSuperview];
}

- (IBAction)showDrawer:(id)sender {
    
    [SVProgressHUD dismiss];
    //    CGSize size = self.view.frame.size;
    //
    //    if(self.isMenuVisible) {
    //        self.isMenuVisible = false;
    //        [overlayView removeFromSuperview];
    //        [UIView animateWithDuration:0.5 animations:^{
    //            self.view.frame = CGRectMake(0, 0, size.width, size.height);
    //        }];
    //    }
    //    else {
    //        [UIView animateWithDuration:0.5 animations:^{
    //            self.view.frame = CGRectMake(236, 0, size.width, size.height);
    //        }];
    //        self.isMenuVisible = true;
    //        CGRect screenRect = [[UIScreen mainScreen] bounds];
    //        overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, screenRect.size.width, screenRect.size.height)];
    //        overlayView.backgroundColor = [UIColor clearColor];
    //
    //        [self.view addSubview:overlayView];
    //
    //        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    //        [sgr setDirection:UISwipeGestureRecognizerDirectionLeft];
    //        [overlayView addGestureRecognizer:sgr];
    //   }
    
    [[DrawerVC getInstance] AddInView:self.view];
    [[DrawerVC getInstance] ShowInView];
}

- (void)leftSwipe:(UISwipeGestureRecognizer *)gesture
{
    if(self.isMenuVisible){
        [self showDrawer:nil];
    }
}
- (void)rightSwipe:(UISwipeGestureRecognizer *)gesture
{
    if(!self.isMenuVisible){
        [self showDrawer:nil];
    }
}

- (IBAction)showHidesearchbar:(id)sender {
    [SVProgressHUD dismiss];
    [[NavigationHandler getInstance] MoveToSearchFriends];
}


- (IBAction)editBtn:(id)sender {
}

//- (IBAction)DeleteBtn:(id)sender {
//    [_TableBeams deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationRight];
//}
@end
