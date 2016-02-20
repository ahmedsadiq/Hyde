//
//  HomeVC.m
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "HomeVC.h"
#import "Constants.h"
#import "HomeCell.h"
#import "ChannelCell.h"
#import "DrawerVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VideoPlayer.h"
#import "NavigationHandler.h"
#import "StatusCell.h"
#import "UIImageView+RoundImage.h"
#import "QuartzCore/CALayer.h"
#import "BeamRecorderViewController.h"
#import "GMDCircleLoader.h"
#import "Utils.h"
#import "ASIFormDataRequest.h"
#import "KxMenu.h"
#import "PBEmojiLabel.h"
#import <AudioToolbox/AudioServices.h>
#import "AdvertismentCell.h"
#import "SVProgressHUD.h"
#import "GetTrendingVideos.h"
#import "Followings.h"
#import "myChannelModel.h"
#import "AsyncImageView.h"
#import "SearchCell.h"
#import "UserChannelModel.h"
#import "CommentsModel.h"
#import "CommentsCell.h"
#import "AVFoundation/AVFoundation.h"

@interface HomeVC ()

@end

@implementation HomeVC

- (id)init
{
    if (IS_IPAD) {
        self = [super initWithNibName:@"HomeVC_iPad" bundle:Nil];
    }
    else{
        self = [super initWithNibName:@"HomeVC" bundle:Nil];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    //
    [super viewDidAppear:animated];
    //    if (trendArray.count == 0) {
    //        [self getTrendingVideos];
    //}
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupRefreshControl];
    [self setupRefreshControlHome];
    [self setupRefreshControlChannel];
    //self.navigationController.navigationBarHidden = YES;
    searchField.attributedPlaceholder =
    [[NSAttributedString alloc]
     initWithString:@"Find other Corners"
     attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    searchTable.dataSource = self;
    searchTable.delegate = self;
    [searchTable setBackgroundColor:BlueThemeColor(241,245,248)];
    [commentsTable setBackgroundColor:BlueThemeColor(241, 245, 248)];
    [_TableHome setBackgroundColor:BlueThemeColor(241,245,248)];
    [_TablemyChannel setBackgroundColor:BlueThemeColor(241,245,248)];
    [_forumTable setBackgroundColor:BlueThemeColor(241,245,248)];
    normalAttrdict = [NSDictionary dictionaryWithObject:BlueThemeColor(145,151,163) forKey:NSForegroundColorAttributeName];
    highlightAttrdict = [NSDictionary dictionaryWithObject:BlueThemeColor(54,78,141) forKey:NSForegroundColorAttributeName ];
    tagsString = @"";
    secondsLeft = 60;
    self.automaticallyAdjustsScrollViewInsets = NO;
    tabBarIsShown = true;
    IS_mute = @"NO";
    videotype = @"COLOUR";
    commentAllowed = @"-1";
    privacySelected = @"PUBLIC";
    TopicSelected = @"1";
    
    [_progressview setProgress:0.0 animated:YES];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
    _progressview.transform = transform;
    totalBytesUploaded = 0.0;
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    loadFollowings = false;
    self.editing = YES;
    _TableHome.delegate = self;
    _TablemyChannel.delegate = self;
    _forumTable.delegate = self;
    
    _TableHome.dataSource = self;
    _TablemyChannel.dataSource = self;
    _forumTable.dataSource = self;
    [self setUserCoverImage];
    [self setUserProfileImage];
    [self initWithDataArr];
    _statusText.delegate = self;
    
    count = 10;
    [self setContentResolutions];
    TabBarFrame = _BottomBar.frame;
    channelContainerHeight = channelContainerView.frame.size.height;
    channelContainerOriginalFrame = channelContainerView.frame;
    channelTableFrame = _TablemyChannel.frame;
    
    [btnHome setTitleColor:[UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0] forState:UIControlStateNormal];
    [btnChannel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnTrending setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    
    UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:sgr];
    
    [_uploadbeamScroller setContentSize:CGSizeMake(_uploadbeamScroller.frame.size.width,600)];
    mainScrollerFrame = _mainScroller.frame;
    originalChannelFrame = _TablemyChannel.frame;
    originalChannelInnerViewFrame = channgelInnerView.frame;
#pragma mark profileView
    
    profilePic.layer.cornerRadius = profilePic.frame.size.width / 2;
    profilePic.clipsToBounds = YES;
    
    profilePic.layer.borderWidth = 0.0f;
    profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = layerMiddle.frame;
    layerMiddle.alpha = 1;
    
    [blurEffectView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [layerMiddle addSubview:blurEffectView];
    currentState = 0;
    [self getHomeContent];
    [self getMyChannel];
    [self getTrendingVideos];
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    [self setAudioRecordSettings];
}
-(void)initWithDataArr{
    fromPullToRefresh = false;
    uploadBeamTag = true;
    uploadAnonymous = false;
    pageNum = 1;
    forumPageNumber = 1;
    myCornerPageNum= 1;
    //PostArray = [[NSMutableArray alloc]init];
    forumsVideo = [[NSMutableArray alloc] init];
    newsfeedsVideos = [[NSMutableArray alloc] init];
    getTrendingVideos  = [[GetTrendingVideos alloc]init];
    myChannelObj = [[myChannelModel alloc]init];
    userChannelObj = [[UserChannelModel alloc]init];
    UsersModel = [[PopularUsersModel alloc]init];
    CommentsModelObj = [[CommentsModel alloc]init];
    getFollowings = [[Followings alloc] init];
    FollowingsAM = [[NSMutableArray alloc]init];
    videomodel = [[VideoModel alloc]init];
}
-(void)setContentResolutions{
    if (IS_IPHONE_4) {
        [_mainScroller setContentSize:CGSizeMake(960, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        _BottomBar.autoresizingMask = UIViewAutoresizingNone;
        _BottomBar.frame = CGRectMake(0, 433, 320, 47);
    }else if (IS_IPAD){
        _BottomBar.frame = CGRectMake(0, 854, 768, 170);
        [_mainScroller setContentSize:CGSizeMake(2304, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        originalChannelFrame.size.width = 768;
        originalChannelFrame.size.height = 568;
        originalChannelFrame.origin.y = 390;
    }
    else if(IS_IPHONE_6){
        originalChannelFrame.size.width = 375;
        originalChannelFrame.size.height = 568;
        originalChannelFrame.origin.y = 390;
        _optionsView.frame = CGRectMake(0, 0, 375, 667);
        searchView.frame = CGRectMake(0, 0, 375, 667);
        commentsTable.frame = CGRectMake(0,297,375,370);
        [_mainScroller setContentSize:CGSizeMake(1125, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        profilePic.frame = CGRectMake(profilePic.frame.origin.x-10, profilePic.frame.origin.y+20, profilePic.frame.size.width+20, profilePic.frame.size.height+20);
    }
    else if(IS_IPHONE_6Plus)
    {
        _BottomBar.autoresizingMask = UIViewAutoresizingNone;
        _BottomBar.frame = CGRectMake(0, 626, 414, 110);
        _optionsView.frame = CGRectMake(0, 0, 414, 736);
        searchView.frame = CGRectMake(0, 0, 414, 736);
        originalChannelFrame.size.width = 414;
        originalChannelFrame.size.height = 650;
        originalChannelFrame.origin.y = 390;
        [_mainScroller setContentSize:CGSizeMake(1472, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        
    }else if(IS_IPHONE_5)
    {
        _BottomBar.autoresizingMask = UIViewAutoresizingNone;
        _BottomBar.frame = CGRectMake(0, 525, 320, 50);
        _optionsView.frame = CGRectMake(0, 0, 320, 568);
        searchView.frame = CGRectMake(0, 0, 320, 568);
        //camLabel.autoresizingMask = UIViewAutoresizingNone;
        camLabel.frame = CGRectMake(beamLabel.frame.origin.x + 160,beamLabel.frame.origin.y , beamLabel.frame.size.width, beamLabel.frame.size.height);
        cameraIcon.frame = CGRectMake(beamIcon.frame.origin.x + 160, beamIcon.frame.origin.y, beamIcon.frame.size.width + 5, beamIcon.frame.size.height);
        [_mainScroller setContentSize:CGSizeMake(960, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
    }
    
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (void)leftSwipe:(UISwipeGestureRecognizer *)gesture
{
    if(self.isMenuVisible){
        [self ShowDrawer:nil];
    }
}
- (void)rightSwipe:(UISwipeGestureRecognizer *)gesture
{
    if(!self.isMenuVisible){
        [self ShowDrawer:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Server Calls

- (void) getTrendingVideos{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSString *pageStr = [NSString stringWithFormat:@"%d",forumPageNumber];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_TRENDING_VIDEOS,@"method",
                              token,@"session_token",pageStr,@"page_no",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [_refreshControl endRefreshing];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1) {
                NSArray *tempArray = [result objectForKey:@"posts"];
                if(tempArray.count > 0)
                {
                    trendArray = [result objectForKey:@"posts"];
                    if(forumPageNumber == 1){
                        getTrendingVideos.trendingArray = [[NSMutableArray alloc] init];
                        getTrendingVideos.mainArray = [[NSMutableArray alloc]init];
                        getTrendingVideos.ImagesArray = [[NSMutableArray alloc]init];
                        getTrendingVideos.ThumbnailsArray = [[NSMutableArray alloc]init];
                    }
                    for(NSDictionary *tempDict in trendArray){
                        
                        GetTrendingVideos *_Videos = [[GetTrendingVideos alloc] init];
                        _Videos.title = [tempDict objectForKey:@"caption"];
                        _Videos.comments_count = [tempDict objectForKey:@"comment_count"];
                        _Videos.userName = [tempDict objectForKey:@"full_name"];
                        _Videos.topic_id = [tempDict objectForKey:@"topic_id"];
                        _Videos.user_id = [tempDict objectForKey:@"user_id"];
                        _Videos.profile_image = [tempDict objectForKey:@"profile_link"];
                        _Videos.like_count = [tempDict objectForKey:@"like_count"];
                        _Videos.like_by_me = [tempDict objectForKey:@"liked_by_me"];
                        _Videos.seen_count = [tempDict objectForKey:@"seen_count"];
                        _Videos.video_angle = [[tempDict objectForKey:@"video_angle"] intValue];
                        _Videos.video_link = [tempDict objectForKey:@"video_link"];
                        _Videos.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                        _Videos.VideoID = [tempDict objectForKey:@"id"];
                        _Videos.Tags = [tempDict objectForKey:@"tag_friends"];
                        _Videos.video_length = [tempDict objectForKey:@"video_length"];
                        _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                        [getTrendingVideos.ImagesArray addObject:_Videos.profile_image];
                        [getTrendingVideos.ThumbnailsArray addObject:_Videos.video_thumbnail_link];
                        [getTrendingVideos.mainArray addObject:_Videos.video_link];
                        [getTrendingVideos.trendingArray addObject:_Videos];
                        
                        trendArray = getTrendingVideos.trendingArray;
                        videosArray = getTrendingVideos.mainArray;
                        arrImage = getTrendingVideos.ImagesArray;
                        arrThumbnail = getTrendingVideos.ThumbnailsArray;
                        
                        [forumsVideo addObject:_Videos];
                        
                    }
                    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                    int startIndex = (forumPageNumber-1) *10;
                    for (int i = startIndex ; i < startIndex+10; i++) {
                        if(i<forumsVideo.count) {
                            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                        }
                    }
                    [_forumTable beginUpdates];
                    [_forumTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [_forumTable endUpdates];
                    //[_forumTable reloadData];
                }
            }else
                cannotScrollForum = true;
        }
        else{
            [_refreshControl endRefreshing];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}
-(void) getFollowing{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_FOLLOWING_AND_FOLLOWERS,@"method",
                              token,@"session_token",@"1",@"page_no",userId,@"user_id",@"1",@"following",nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            [SVProgressHUD dismiss];
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1){
                FollowingsArray = [result objectForKey:@"following"];
                
                for(NSDictionary *tempDict in FollowingsArray){
                    Followings *_responseData = [[Followings alloc] init];
                    
                    _responseData.f_id = [tempDict objectForKey:@"id"];
                    _responseData.fullName = [tempDict objectForKey:@"full_name"];
                    _responseData.is_celeb = [tempDict objectForKey:@"is_celeb"];
                    _responseData.profile_link = [tempDict objectForKey:@"profile_link"];
                    _responseData.status = [tempDict objectForKey:@"state"];
                    [FollowingsAM addObject:_responseData];
                }
                [searchTable reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }
    }];
}
-(void) getFollowers{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_FOLLOWING_AND_FOLLOWERS,@"method",
                              token,@"session_token",@"1",@"page_no",userId,@"user_id",@"1",@"followers",nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            [SVProgressHUD dismiss];
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1){
                FollowingsArray = [result objectForKey:@"followers"];
                
                for(NSDictionary *tempDict in FollowingsArray){
                    Followings *_responseData = [[Followings alloc] init];
                    
                    _responseData.f_id = [tempDict objectForKey:@"id"];
                    _responseData.fullName = [tempDict objectForKey:@"full_name"];
                    _responseData.is_celeb = [tempDict objectForKey:@"is_celeb"];
                    _responseData.profile_link = [tempDict objectForKey:@"profile_link"];
                    _responseData.status = [tempDict objectForKey:@"state"];
                    [FollowingsAM addObject:_responseData];
                }
                [searchTable reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }
    }];
}

- (void) getHomeContent{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    secondsConsumed  = 0;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *pageStr = [NSString stringWithFormat:@"%d",pageNum];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_HOME_CONTENTS,@"method",
                              token,@"session_token",pageStr,@"page_no",nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        
        [_refreshControlHome endRefreshing];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            
            if(success == 1) {
                NSArray *tempArray = [result objectForKey:@"posts"];
                
                if(tempArray.count> 0) {
                    newsfeedPostArray = [result objectForKey:@"posts"];
                    if(pageNum == 1){
                        getTrendingVideos.homieArray = [[NSMutableArray alloc] init];
                        getTrendingVideos.mainhomeArray = [[NSMutableArray alloc]init];
                        getTrendingVideos.homeImagesArray = [[NSMutableArray alloc]init];
                        getTrendingVideos.homeThumbnailsArray = [[NSMutableArray alloc]init];
                    }
                    for(NSDictionary *tempDict in newsfeedPostArray){
                        
                        GetTrendingVideos *_Videos = [[GetTrendingVideos alloc] init];
                        
                        _Videos.title = [tempDict objectForKey:@"caption"];
                        _Videos.comments_count = [tempDict objectForKey:@"comment_count"];
                        _Videos.userName = [tempDict objectForKey:@"full_name"];
                        _Videos.topic_id = [tempDict objectForKey:@"topic_id"];
                        _Videos.user_id = [tempDict objectForKey:@"user_id"];
                        _Videos.profile_image = [tempDict objectForKey:@"profile_link"];
                        _Videos.like_count = [tempDict objectForKey:@"like_count"];
                        _Videos.seen_count = [tempDict objectForKey:@"seen_count"];
                        _Videos.like_by_me = [tempDict objectForKey:@"liked_by_me"];
                        _Videos.video_angle = [tempDict objectForKey:@"video_angle"];
                        _Videos.video_link = [tempDict objectForKey:@"video_link"];
                        _Videos.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                        _Videos.VideoID = [tempDict objectForKey:@"id"];
                        _Videos.video_length = [tempDict objectForKey:@"video_length"];
                        _Videos.image_link = [tempDict objectForKey:@"image_link"];
                        _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                        [getTrendingVideos.homeImagesArray addObject:_Videos.profile_image];
                        [getTrendingVideos.homeThumbnailsArray addObject:_Videos.video_thumbnail_link];
                        [getTrendingVideos.mainhomeArray addObject:_Videos.video_link];
                        [getTrendingVideos.homieArray addObject:_Videos];
                        
                        newsfeedPostArray = getTrendingVideos.homieArray;
                        newsfeedVideosArray = getTrendingVideos.mainhomeArray;
                        newsfeedArrImage = getTrendingVideos.homeImagesArray;
                        newsfeedArrThumbnail = getTrendingVideos.homeThumbnailsArray;
                        
                        [newsfeedsVideos addObject:_Videos];
                        
                    }
                    if ([newsfeedsVideos count] == 0) {
                        [noBeamsView setHidden:NO];
                    }else{
                        noBeamsView.hidden = YES;
                    }
                    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                    int startIndex = (pageNum-1) *10;
                    for (int i = startIndex ; i < startIndex+10; i++) {
                        if(i<newsfeedsVideos.count) {
                            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                        }
                    }
                    [_TableHome beginUpdates];
                    [_TableHome insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [_TableHome endUpdates];
                    //[_TableHome reloadData];
                }
            }
            else
                cannotScroll = true;
        }
        else{
            
            [_refreshControlHome endRefreshing];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}


- (void) getMyChannel{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *pageStr = [NSString stringWithFormat:@"%d",myCornerPageNum];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_MY_CHENNAL,@"method",
                              token,@"session_token",pageStr,@"page_no",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [_refreshControlChannel endRefreshing];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *posts = [result objectForKey:@"profile"];
            
            if(success == 1) {
                NSArray *tempArray = [result objectForKey:@"posts"];
                myChannelModel *_profile = [[myChannelModel alloc] init];
                _profile.beams_count = [posts objectForKey:@"beams_count"];
                _profile.friends_count = [posts objectForKey:@"following_count"];
                _profile.full_name = [posts objectForKey:@"full_name"];
                // _profile.cover_link = [posts objectForKey:@"cover_link"];
                _profile.user_id = [posts objectForKey:@"id"];
                _profile.profile_image = [posts objectForKey:@"profile_link"];
                _profile.likes_count = [posts objectForKey:@"followers_count"];
                _profile.gender = [posts objectForKey:@"gender"];
                _profile.email = [posts objectForKey:@"email"];
                _profile.is_celeb = [posts objectForKey:@"is_celeb"];
                _profile.cover_image = [posts objectForKey:@"cover_link"];
                
                User_pic.imageURL = [NSURL URLWithString:_profile.profile_image];
                NSURL *url = [NSURL URLWithString:_profile.profile_image];
                [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
                appDelegate.IS_celeb = [_profile.is_celeb boolValue];
                
                
                channelCover.imageURL = [NSURL URLWithString:_profile.cover_image];
                NSURL *url1 = [NSURL URLWithString:_profile.cover_image];
                [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
                
                
                userName.text = _profile.full_name;
                userBeams.text = [[NSString alloc]initWithFormat:@"%@ Beams",_profile.beams_count ];
                userFriends.text = [[NSString alloc]initWithFormat:@"%@ Following",_profile.friends_count];
                userLikes.text = [[NSString alloc]initWithFormat:@"%@ Followers",_profile.likes_count];
                if(tempArray.count > 0)
                {
                    chPostArray = [result objectForKey:@"posts"];
                    if(myCornerPageNum == 1){
                        myChannelObj.trendingArray= [[NSMutableArray alloc] init];
                        myChannelObj.mainArray = [[NSMutableArray alloc]init];
                        myChannelObj.ImagesArray = [[NSMutableArray alloc]init];
                        myChannelObj.ThumbnailsArray = [[NSMutableArray alloc]init];
                    }
                    channelVideos = [[NSMutableArray alloc] init];
                    
                    for(NSDictionary *tempDict in chPostArray){
                        
                        myChannelModel *_Videos = [[myChannelModel alloc] init];
                        
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
                        _Videos.like_by_me = [tempDict objectForKey:@"liked_by_me"];
                        _Videos.image_link = [tempDict objectForKey:@"image_link"];
                        [myChannelObj.ImagesArray addObject:_Videos.profile_image];
                        [myChannelObj.ThumbnailsArray  addObject:_Videos.video_thumbnail_link];
                        [myChannelObj.mainArray addObject:_Videos.video_link];
                        [myChannelObj.trendingArray addObject:_Videos];
                        
                        chPostArray  = myChannelObj.trendingArray;
                        chVideosArray = myChannelObj.mainArray;
                        chArrImage = myChannelObj.ImagesArray;
                        chArrThumbnail = myChannelObj.ThumbnailsArray;
                        [channelVideos addObject:_Videos];
                    }
                    //                    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                    //                    int startIndex = (myCornerPageNum-1) *10;
                    //                    for (int i = startIndex ; i < startIndex+10; i++) {
                    //                        if(i<channelVideos.count) {
                    //                            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    //                        }
                    //                    }
                    //                    [_TablemyChannel beginUpdates];
                    //                    [_TablemyChannel insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    //                    [_TablemyChannel endUpdates];
                    [_TablemyChannel reloadData];
                }
                else
                    cannotScrollMyCorner = true;
            }
            else{
                [_refreshControlChannel endRefreshing];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }];
}


#pragma mark - PulltoRefresh
- (void)setupRefreshControl
{
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = _forumTable;
    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

- (void)refresh:(id)sender
{
    [self getTrendingVideos];
    
}
- (void)setupRefreshControlHome
{
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = _TableHome;
    self.refreshControlHome = [[UIRefreshControl alloc] init];
    _refreshControlHome.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [self.refreshControlHome addTarget:self action:@selector(refreshHome:) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControlHome;
}

- (void)refreshHome:(id)sender
{
    fromPullToRefresh = true;
    [newsfeedsVideos removeAllObjects];
    [self getHomeContent];
    
}
- (void)setupRefreshControlChannel
{
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = _TablemyChannel;
    self.refreshControlChannel = [[UIRefreshControl alloc] init];
    _refreshControlChannel.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [self.refreshControlChannel addTarget:self action:@selector(refreshChannel:) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControlChannel;
}

- (void)refreshChannel:(id)sender
{
    if(tabBarIsShown)
        [self getMyChannel];
    
}

#pragma mark - Like Post
- (void) LikePost:(NSUInteger )indexToLike{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSString *message = [result objectForKey:@"message"];
            if(success == 1){
                if ([message isEqualToString:@"Post is Successfully liked."]) {
                    liked = YES;
                }else if ([message isEqualToString:@"Post is Successfully unliked by this user."])
                    liked = NO;
            }
            if(currentState == 2){
                [self getTrendingVideos];
            }
            else if (currentState == 0)
            {
                //                GetTrendingVideos *_Videos = [[GetTrendingVideos alloc] init];
                //                _Videos = [newsfeedsVideos objectAtIndex:indexToLike];
                //                _Videos.like_count = [[newsfeedsVideos  objectAtIndex:indexToLike]valueForKey:@"like_count"];
                //                NSInteger likeCount = [_Videos.like_count intValue];
                //                likeCount++;
                //                _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                //                _Videos.like_by_me = @"1";
                //                [newsfeedsVideos replaceObjectAtIndex:indexToLike withObject:_Videos];
                //                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike inSection:0];
                //                NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                //                [_TableHome reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                [self getHomeContent];
            }
            else if (currentState == 3)
                [self getMyChannel];
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


-(void) setUserProfileImage {
    
    profilePic.layer.cornerRadius = profilePic.frame.size.width / 2;
    
    for (UIView* subview in profilePic.subviews)
        subview.layer.cornerRadius = profilePic.frame.size.width / 2;
    
    profilePic.layer.shadowColor = [UIColor blackColor].CGColor;
    profilePic.layer.shadowOpacity = 0.7f;
    profilePic.layer.shadowOffset = CGSizeMake(0, 5);
    profilePic.layer.shadowRadius = 5.0f;
    profilePic.layer.masksToBounds = NO;
    
    profilePic.layer.cornerRadius = profilePic.frame.size.width / 2;
    profilePic.layer.masksToBounds = NO;
    profilePic.clipsToBounds = YES;
    
    profilePic.layer.backgroundColor = [UIColor clearColor].CGColor;
    profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    profilePic.layer.borderWidth = 0.0f;
    
    User_pic.layer.cornerRadius = User_pic.frame.size.width / 2;
    for (UIView* subview in User_pic.subviews)
        subview.layer.cornerRadius = User_pic.frame.size.width / 2;
    
    User_pic.layer.shadowColor = [UIColor blackColor].CGColor;
    User_pic.layer.shadowOpacity = 0.7f;
    User_pic.layer.shadowOffset = CGSizeMake(0, 5);
    User_pic.layer.shadowRadius = 5.0f;
    User_pic.layer.masksToBounds = NO;
    
    User_pic.layer.cornerRadius = User_pic.frame.size.width / 2;
    User_pic.layer.masksToBounds = NO;
    User_pic.clipsToBounds = YES;
    
    User_pic.layer.backgroundColor = [UIColor clearColor].CGColor;
    User_pic.layer.borderColor = [UIColor whiteColor].CGColor;
    User_pic.layer.borderWidth = 0.0f;
    
    friendsImage.layer.cornerRadius = friendsImage.frame.size.width / 2;
    for (UIView* subview in friendsImage.subviews)
        subview.layer.cornerRadius = friendsImage.frame.size.width / 2;
    
    friendsImage.layer.shadowColor = [UIColor blackColor].CGColor;
    friendsImage.layer.shadowOpacity = 0.7f;
    friendsImage.layer.shadowOffset = CGSizeMake(0, 5);
    friendsImage.layer.shadowRadius = 5.0f;
    friendsImage.layer.masksToBounds = NO;
    
    friendsImage.layer.cornerRadius = friendsImage.frame.size.width / 2;
    friendsImage.layer.masksToBounds = NO;
    friendsImage.clipsToBounds = YES;
    
    friendsImage.layer.backgroundColor = [UIColor clearColor].CGColor;
    friendsImage.layer.borderColor = [UIColor whiteColor].CGColor;
    friendsImage.layer.borderWidth = 0.0f;
    
    userImage.layer.cornerRadius = userImage.frame.size.width / 2;
    for (UIView* subview in userImage.subviews)
        subview.layer.cornerRadius = userImage.frame.size.width / 2;
    
    userImage.layer.shadowColor = [UIColor blackColor].CGColor;
    userImage.layer.shadowOpacity = 0.7f;
    userImage.layer.shadowOffset = CGSizeMake(0, 5);
    userImage.layer.shadowRadius = 5.0f;
    userImage.layer.masksToBounds = NO;
    
    userImage.layer.cornerRadius = userImage.frame.size.width / 2;
    userImage.layer.masksToBounds = NO;
    userImage.clipsToBounds = YES;
    
    userImage.layer.backgroundColor = [UIColor clearColor].CGColor;
    userImage.layer.borderColor = [UIColor whiteColor].CGColor;
    userImage.layer.borderWidth = 0.0f;
}




#pragma mark - TableView Data Source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if(tableView.tag == 3) {
    //        if(indexPath.row == trendArray.count-1 && !self.isLoading){
    //            forumPageNumber++;
    //            [self getTrendingVideos];
    //        }
    //    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.tag == 2) {
        if(appDelegate.IS_celeb && indexPath.row == 0) {
            if (IS_IPAD)
                returnValue = 200.0f;
            else
                returnValue = 112;
        }
        else {
            if (IS_IPAD)
                returnValue = 362.0f;
            else
                returnValue = 250.0f;
        }
        
    }
    else {
        if (IsStatus== YES) {
            if (IS_IPAD)
                returnValue = 350.0f;
            else
                returnValue = 150.0f;
        }
        else {
            if (IS_IPAD)
                returnValue = 362.0f;
            else
                returnValue = 250.0f;
        }
    }
    if(tableView.tag == 10) {
        
        if (IS_IPAD)
            returnValue = 362.0f;
        else
            returnValue = 250.0f;
    }
    
    if(tableView.tag == 3) {
        
        if (IS_IPAD)
            returnValue = 362.0f;
        else
            returnValue = 250.0f;
    }
    if(tableView.tag == 20) {
        
        if (IS_IPAD)
            returnValue = 93.0f;
        else
            returnValue = 83.0f;
    }
    if(tableView.tag == 30) {
        
        if (IS_IPAD)
            returnValue = 362.0f;
        else
            returnValue = 250.0f;
    }
    if(tableView.tag == 25) {
        
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
    
    
    if (tableView.tag == 10) {
        value = [newsfeedPostArray count];
        
    }else if (tableView.tag == 3 && trendArray != nil){
        value = [trendArray count] ;
        
    }else if (tableView.tag == 2){
        
        value = chPostArray.count;
        if(appDelegate.IS_celeb) {
            value = value+1;
        }
        value = value ;
    }else if (tableView.tag == 20){
        if(loadFollowings == true)
            value = FollowingsAM.count;
        else
            value = usersArray.count;
    }else if (tableView.tag == 25){
        
        value = chPostArray.count;
    }else if (tableView.tag == 30){
        
        value = CommentsArray.count;
    }
    return value;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 10) {
        ChannelCell *cell;
        IsStatus = NO;
        if (IS_IPAD) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChannelCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChannelCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        _TableHome.contentSize = CGSizeMake(_TableHome.frame.size.width,newsfeedPostArray.count * returnValue + _BottomBar.frame.size.height + 50);
        
        GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
        tempVideos  = [newsfeedPostArray objectAtIndex:indexPath.row];
        cell.CH_userName.text = tempVideos.userName;
        
        appDelegate.videotitle = tempVideos.title;
        appDelegate.videotags = tempVideos.Tags;
        appDelegate.profile_pic_url = tempVideos.profile_image;
        
        cell.Ch_videoLength.text = tempVideos.video_length;
        cell.CH_VideoTitle.text = tempVideos.title;
        cell.CH_CommentscountLbl.text = tempVideos.comments_count;
        cell.CH_heartCountlbl.text = tempVideos.like_count;
        cell.CH_seen.text = tempVideos.seen_count;
        tempVideos.video_link = [newsfeedVideosArray objectAtIndex:indexPath.row];
        if([tempVideos.is_anonymous  isEqualToString: @"0"]){
            cell.CH_profileImage.imageURL = [NSURL URLWithString:[newsfeedArrImage objectAtIndex:indexPath.row]];
            NSURL *url = [NSURL URLWithString:[newsfeedArrImage objectAtIndex:indexPath.row]];
            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
            
            //        if([tempVideos.video_thumbnail_link isEqualToString:@""] )
            //        {
            //            cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.image_link];
            //            url1 = [NSURL URLWithString:tempVideos.image_link];
            //            cell.CH_playVideo.hidden = YES;
            //        }
            
        }
        else{
            cell.CH_profileImage.image = [UIImage imageNamed:@"anonymousDp.png"];
            cell.CH_userName.text = @"Anonymous";
            cell.userProfileView.enabled = false;
        }
        cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:[newsfeedArrThumbnail objectAtIndex:indexPath.row]];
        NSURL *url1 = [NSURL URLWithString:[newsfeedArrThumbnail objectAtIndex:indexPath.row]];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:sgr];
        [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        appDelegate.videotoPlay = [getTrendingVideos.mainhomeArray objectAtIndex:indexPath.row];
        [cell.userProfileView addTarget:self action:@selector(MovetoUserProfile:) forControlEvents:UIControlEventTouchUpInside];
        cell.userProfileView.tag = indexPath.row;
        [cell.CH_heart setTag:indexPath.row];
        [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        
        [cell.CH_flag addTarget:self action:@selector(Flag:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_playVideo setTag:indexPath.row];
        
        [cell.CH_flag setTag:indexPath.row];
        [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_commentsBtn setTag:indexPath.row];
        [cell setBackgroundColor:BlueThemeColor(241, 245, 248)];
        
        cell.CH_Video_Thumbnail.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        cell.CH_Video_Thumbnail.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        cell.CH_Video_Thumbnail.layer.shadowOpacity = 1;
        cell.CH_Video_Thumbnail.layer.shadowRadius = 3.0;
        
        [cell.CH_profileImage roundImageCorner];
        
        cell.imgContainer.backgroundColor = [UIColor clearColor];
        cell.imgContainer.layer.shadowColor = [UIColor blackColor].CGColor;
        cell.imgContainer.layer.shadowOffset = CGSizeMake(2,2);
        cell.imgContainer.layer.shadowOpacity = 0.5;
        cell.imgContainer.layer.shadowRadius = 0.5;
        cell.imgContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.imgContainer.bounds cornerRadius:90.0].CGPath;
        
        return cell;
        
    }else if(tableView.tag == 3){
        
        ChannelCell *cell;
        IsStatus = NO;
        //currentState = 2;
        if (IS_IPAD) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChannelCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChannelCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        _forumTable.contentSize = CGSizeMake(_forumTable.frame.size.width,trendArray.count * returnValue + _BottomBar.frame.size.height + 50);
        
        GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
        tempVideos  = [trendArray objectAtIndex:indexPath.row];
        cell.CH_userName.text = tempVideos.userName;
        
        appDelegate.videotitle = tempVideos.title;
        appDelegate.videotags = tempVideos.Tags;
        appDelegate.profile_pic_url = tempVideos.profile_image;
        
        cell.Ch_videoLength.text = tempVideos.video_length;
        cell.CH_VideoTitle.text = tempVideos.title;
        cell.CH_CommentscountLbl.text = tempVideos.comments_count;
        cell.CH_heartCountlbl.text = tempVideos.like_count;
        cell.CH_seen.text = tempVideos.seen_count;
        tempVideos.video_link = [videosArray objectAtIndex:indexPath.row];
        if([tempVideos.is_anonymous  isEqualToString: @"0"]){
            cell.CH_profileImage.imageURL = [NSURL URLWithString:[arrImage objectAtIndex:indexPath.row]];
            NSURL *url = [NSURL URLWithString:[arrImage objectAtIndex:indexPath.row]];
            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        }
        else{
            cell.CH_profileImage.image =[UIImage imageNamed:@"anonymousDp.png"];
            cell.CH_userName.text = @"Anonymous";
            cell.userProfileView.enabled = false;
        }
        cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:[arrThumbnail objectAtIndex:indexPath.row]];
        NSURL *url1 = [NSURL URLWithString:[arrThumbnail objectAtIndex:indexPath.row]];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
        [cell.userProfileView addTarget:self action:@selector(MovetoUserProfile:) forControlEvents:UIControlEventTouchUpInside];
        cell.userProfileView.tag = indexPath.row;
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
        
        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:sgr];
        
        
        [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        appDelegate.videotoPlay = [getTrendingVideos.mainArray objectAtIndex:indexPath.row];
        
        [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        
        //  cell.CH_seen.hidden = NO;
        //  cell.CH_seen.frame = CGRectMake(cell.CH_flag.frame.size.width + cell.CH_flag.frame.origin.x +15, cell.CH_seen.frame.origin.y,  cell.CH_seen.frame.size.width,  cell.CH_seen.frame.size.height);
        
        //[cell.CH_flag setBackgroundImage:[UIImage imageNamed:@"Eye_256.png"] forState:UIControlStateNormal];
        [cell.CH_flag addTarget:self action:@selector(Flag:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_playVideo setTag:indexPath.row];
        [cell.CH_heart setTag:indexPath.row];
        [cell.CH_flag setTag:indexPath.row];
        [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_commentsBtn setTag:indexPath.row];
        [cell setBackgroundColor:BlueThemeColor(241, 245, 248)];
        return cell;
        
    }
    if (tableView.tag == 2 ) {
        
        if(indexPath.row == 0 && appDelegate.IS_celeb) {
            AdvertismentCell *cell;
            IsStatus = NO;
            if (IS_IPAD) {
                
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AdvertismentCell_iPad" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            else{
                
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AdvertismentCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [cell setBackgroundColor:BlueThemeColor(241, 245, 248)];
            return cell;
        }
        else {
            ChannelCell *cell;
            IsStatus = NO;
            if (IS_IPAD) {
                
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChannelCell_iPad" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            else{
                
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChannelCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            _TablemyChannel.contentSize = CGSizeMake(_TablemyChannel.frame.size.width,chPostArray.count * returnValue + _BottomBar.frame.size.height + 120);
            myChannelModel *tempVideos = [[myChannelModel alloc]init];
            if(appDelegate.IS_celeb) {
                tempVideos  = [chPostArray objectAtIndex:indexPath.row-1];
            }
            else {
                tempVideos  = [chPostArray objectAtIndex:indexPath.row];
            }
            
            cell.CH_userName.text = tempVideos.userName;
            cell.CH_VideoTitle.text = tempVideos.title;
            cell.CH_CommentscountLbl.text = tempVideos.comments_count;
            cell.CH_heartCountlbl.text = tempVideos.like_count;
            cell.CH_seen.text = tempVideos.seen_count;
            cell.Ch_videoLength.text = tempVideos.video_length;
            
            
            
            cell.CH_profileImage.imageURL = [NSURL URLWithString:tempVideos.profile_image];
            NSURL *url = [NSURL URLWithString:tempVideos.profile_image];
            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
            
            NSURL *url1;
            if(appDelegate.IS_celeb) {
                cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:[chArrThumbnail objectAtIndex:indexPath.row-1]];
                url1 = [NSURL URLWithString:[chArrThumbnail objectAtIndex:indexPath.row-1]];
            }
            else {
                cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:[chArrThumbnail objectAtIndex:indexPath.row]];
                url1 = [NSURL URLWithString:[chArrThumbnail objectAtIndex:indexPath.row]];
            }
            
            if([tempVideos.video_thumbnail_link isEqualToString:@""] )
            {
                cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.image_link];
                url1 = [NSURL URLWithString:tempVideos.image_link];
                cell.CH_playVideo.hidden = YES;
            }
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
            
            UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
            [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
            [cell addGestureRecognizer:sgr];
            
            
            [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.CH_flag addTarget:self action:@selector(editPost:) forControlEvents:UIControlEventTouchUpInside];
            [cell.CH_playVideo setTag:indexPath.row-1];
            [cell.CH_heart setTag:indexPath.row-1];
            [cell.CH_flag setTag:indexPath.row-1];
            [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.CH_commentsBtn setTag:indexPath.row-1];
            
            if ([tempVideos.like_by_me isEqualToString:@"1"]) {
                [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
            }else{
                [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
            }
            [cell setBackgroundColor:BlueThemeColor(241, 245, 248)];
            return cell;
        }
    }
    if (tableView.tag == 20) {
        SearchCell *cell;
        if (IS_IPAD) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        if(loadFollowings == false){
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
            // cell.profilePic.layer.shadowRadius = 5.0f;
            cell.profilePic.layer.masksToBounds = NO;
            
            cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2;
            cell.profilePic.layer.masksToBounds = NO;
            cell.profilePic.clipsToBounds = YES;
            
            cell.profilePic.layer.backgroundColor = [UIColor clearColor].CGColor;
            cell.profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.profilePic.layer.borderWidth = 0.0f;
            
            [cell.statusImage addTarget:self action:@selector(statusPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.statusImage setTag:indexPath.row];
            
            if ([tempUsers.status isEqualToString:@"ADD_FRIEND"]) {
                
                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
            }else if ([tempUsers.status isEqualToString:@"PENDING"]){
                
                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"requestsent.png"] forState:UIControlStateNormal];
            }else if ([tempUsers.status isEqualToString:@"FRIEND"]) {
                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"friends.png"] forState:UIControlStateNormal];
            }else if ([tempUsers.status isEqualToString:@"ACCEPT_REQUEST"]){
                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"requestaccept.png"] forState:UIControlStateNormal];
                [self sendDeleteFriend];
                
            }
            
            [cell.friendsChannelBtn addTarget:self action:@selector(OpenFriendsChannelPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.friendsChannelBtn setTag:indexPath.row];
            
            if (SearchforTag == YES) {
                cell.tagbtn.hidden = NO;
                cell.statusImage.hidden = YES;
                
            }else{
                cell.tagbtn.hidden = YES;
                cell.statusImage.hidden = NO;
            }
            [cell.tagbtn addTarget:self action:@selector(TagFriend:) forControlEvents:UIControlEventTouchUpInside];
            [cell.tagbtn setTag:indexPath.row];
            return cell;
        }
        else{
            Followings *tempUsers = [[Followings alloc]init];
            tempUsers = [FollowingsAM objectAtIndex:indexPath.row];
            cell.friendsName.text = tempUsers.fullName;
            
            cell.profilePic.imageURL = [NSURL URLWithString:tempUsers.profile_link];
            NSURL *url = [NSURL URLWithString:tempUsers.profile_link];
            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
            [cell.profilePic roundImageCorner];
            
            [cell.statusImage addTarget:self action:@selector(statusPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.statusImage setTag:indexPath.row];
            
            if ([tempUsers.status isEqualToString:@"ADD_FRIEND"]) {
                
                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
            }else if ([tempUsers.status isEqualToString:@"PENDING"]){
                
                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"requestsent.png"] forState:UIControlStateNormal];
            }else if ([tempUsers.status isEqualToString:@"FRIEND"]) {
                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"friends.png"] forState:UIControlStateNormal];
            }else if ([tempUsers.status isEqualToString:@"ACCEPT_REQUEST"]){
                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"requestaccept.png"] forState:UIControlStateNormal];
                [self sendDeleteFriend];
            }
            [cell.friendsChannelBtn addTarget:self action:@selector(OpenFriendsChannelPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.friendsChannelBtn setTag:indexPath.row];
            cell.statusImage.hidden = NO;
            return cell;
        }
    }
    
    if (tableView.tag == 25) {
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
        
        tempVideos  = [chPostArray objectAtIndex:indexPath.row];
        cell.CH_userName.text = tempVideos.userName;
        
        cell.CH_VideoTitle.text = tempVideos.title;
        cell.CH_CommentscountLbl.text = tempVideos.comments_count;
        cell.CH_heartCountlbl.text = tempVideos.like_count;
        cell.CH_seen.text = tempVideos.seen_count;
        
        appDelegate.videotitle = tempVideos.title;
        appDelegate.videotags = tempVideos.Tags;
        appDelegate.profile_pic_url = tempVideos.profile_image;
        cell.Ch_videoLength.text = tempVideos.video_length;
        tempVideos.video_link = [chVideosArray objectAtIndex:indexPath.row];
        
        cell.CH_profileImage.imageURL = [NSURL URLWithString:[chArrImage objectAtIndex:indexPath.row]];
        NSURL *url = [NSURL URLWithString:[chArrImage objectAtIndex:indexPath.row]];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        
        cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:[chArrThumbnail objectAtIndex:indexPath.row]];
        NSURL *url1 = [NSURL URLWithString:[chArrThumbnail objectAtIndex:indexPath.row]];
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
        
        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:sgr];
        
        
        [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        appDelegate.videotoPlay = [userChannelObj.mainArray objectAtIndex:indexPath.row];
        [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_flag addTarget:self action:@selector(editPost:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_playVideo setTag:indexPath.row];
        [cell.CH_heart setTag:indexPath.row];
        [cell.CH_flag setTag:indexPath.row];
        
        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        
        
        [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_commentsBtn setTag:indexPath.row];
        
        
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
        commentsTable.contentSize = CGSizeMake(_forumTable.frame.size.width,CommentsArray.count * returnValue + _BottomBar.frame.size.height + 30);
        CommentsModel *tempVideos = [[CommentsModel alloc]init];
        tempVideos  = [CommentsArray objectAtIndex:indexPath.row];
        cell.userName.text = tempVideos.userName;
        cell.VideoTitle.text = tempVideos.title;
        
        cell.CommentscountLbl.text = tempVideos.comments_count;
        cell.heartCountlbl.text = tempVideos.like_count;
        cell.seenLbl.text = tempVideos.seen_count;
        cell.userName.text = tempVideos.userName;
        
        appDelegate.videotitle = tempVideos.title;
        appDelegate.profile_pic_url = tempVideos.profile_link;
        
        tempVideos.video_link = [CommentsModelObj.mainArray objectAtIndex:indexPath.row];
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
        
        appDelegate.videotoPlay = [CommentsModelObj.mainArray objectAtIndex:indexPath.row];
        
        [cell.heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        
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
            cell.contentView.frame = CGRectMake(0, 0, 345, 220);
        }
        
        return cell;
    }
    
    
    return nil;
}

-(void)cellSwiped:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        UITableViewCell *cell = (UITableViewCell *)gestureRecognizer.view;
        index = [self.TableHome indexPathForCell:cell];
        
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.tag == 5){
        int page = scrollView.contentOffset.x / scrollView.frame.size.width;
        if(page == 0){
            [self ShowBottomBar];
            [btnHome setTitleColor:[UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0] forState:UIControlStateNormal];
            [btnChannel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btnTrending setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            currentState = 0;
        }
        else if (page == 1) {
            [self ShowBottomBar];
            [btnChannel setTitleColor:[UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0] forState:UIControlStateNormal];
            [btnHome setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btnTrending setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            currentState = 3;
        }
        else {
            currentState = 2;
            [btnTrending setTitleColor:[UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0] forState:UIControlStateNormal];
            [btnChannel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btnHome setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
    }
    else if(scrollView.tag == 10) {
        
        //        CGRect frame = topHeader.frame;
        //        CGFloat size = frame.size.height - 21;
        //        CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
        //        CGFloat scrollOffset = scrollView.contentOffset.y;
        //        CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
        //        CGFloat scrollHeight = scrollView.frame.size.height;
        //        CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
        //
        //
        //                if (scrollOffset <= -scrollView.contentInset.top) {
        //                    frame.origin.y = 0;
        //
        //                    [UIView animateWithDuration:0.2 animations:^{
        //
        //                        CGRect screenRect = [[UIScreen mainScreen] bounds];
        //                        mainScrollerFrame.size.height = screenRect.size.height;
        //                        mainScrollerFrame.size.width = screenRect.size.width;
        //                        _mainScroller.frame = mainScrollerFrame;
        //                        [_mainScroller setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        //                    }];
        //
        //               }
        //                else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        //                   frame.origin.y = -size;
        //              }
        //                    else {
        //                    frame.origin.y = MIN(0, MAX(-size, frame.origin.y - scrollDiff));
        //
        //                    CGRect scrollFrame = _mainScroller.frame;
        //                    [UIView animateWithDuration:0.2 animations:^{
        //
        //                        _mainScroller.frame = CGRectMake(scrollFrame.origin.x, scrollFrame.origin.y-scrollDiff, scrollFrame.size.width, scrollFrame.size.height+scrollDiff);
        //                        [_mainScroller setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        //                    }];
        //                }
        //
        
        //        if(frame.origin.y <= -70) {
        //            frame.origin.y = -118;
        //        }
        //        if(IS_IPHONE_6) {
        //            frame.size.width = 375;
        //        }
        //        else if(IS_IPAD) {
        //            frame.size.width = 768;
        //        }
        //        else if(IS_IPHONE_6Plus)
        //        {
        //            frame.size.width = 414;
        //        }
        //        else if(IS_IPHONE_5 || IS_IPHONE_4)
        //        {
        //            frame.size.width = 320;
        //        }
        CGPoint currentOffset = scrollView.contentOffset;
        if (currentOffset.y > _lastContentPoint.y && currentOffset.y >=10)
        {
            // Downward
            //[self.view sendSubviewToBack:_BottomBar];
            [self HideBottomBar];
        }
        else
        {
            // Upward
            //[self.view bringSubviewToFront:_BottomBar];
            [self ShowBottomBar];
        }
        self.lastContentPoint = currentOffset;
        //[topHeader setFrame:frame];
        
        //[self updateBarButtonItems:(1 - framePercentageHidden)];
        //self.previousScrollViewYOffset = scrollOffset;
    }
    else if (scrollView.tag == 2) {
        if (_lastContentOffset < (int)scrollView.contentOffset.y) {
            // moved up
            CGRect changedFrame = CGRectMake(0, 86, originalChannelFrame.size.width, 568);
            
            if (IS_IPAD) {
                changedFrame = CGRectMake(0, 100, originalChannelFrame.size.width, 1024);
            }
            
            CGRect changedFrameForInner = CGRectMake(0, 0, originalChannelFrame.size.width, 0);
            
            [UIView animateWithDuration:0.5 animations:^{
                
                channelContainerView.frame = changedFrameForInner;
            }];
            
            [UIView animateWithDuration:0.5 animations:^{
                
                _TablemyChannel.frame = changedFrame;
            }];
            tabBarIsShown = false;
            [self HideBottomBar];
            
        }
        else if (_lastContentOffset > (int)scrollView.contentOffset.y) {
            // moved down
            
            [UIView animateWithDuration:0.5 animations:^{
                
                channelContainerView.frame = originalChannelInnerViewFrame;
                //[channelContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            }];
            
            [UIView animateWithDuration:0.5 animations:^{
                
                _TablemyChannel.frame = originalChannelFrame;
                
            }];
            tabBarIsShown = true;
            [self ShowBottomBar];
        }
    }
    else if (scrollView.tag == 3)
    {
        CGPoint currentOffset = scrollView.contentOffset;
        if (currentOffset.y > _lastContentPoint.y && currentOffset.y >=10)
        {
            [self HideBottomBar];
        }
        else
        {
            [self ShowBottomBar];
        }
        //        self.lastContentPoint = currentOffset;
        //        if(self.forumTable.contentOffset.y >= (self.forumTable.contentSize.height - self.forumTable.bounds.size.height)) {
        //            //            if(self.isLoading == NO)
        //            //            {
        //            //                self.isLoading  = YES;
        //            //                forumPageNumber++;
        //            //                [self getTrendingVideos];
        //            //            }
        //        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //    if(scrollView.tag == 2) {
    //        _lastContentOffset = scrollView.contentOffset.x;
    //    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(!fromPullToRefresh){
        if (scrollView.tag == 10){
            NSArray *visibleRows = [_TableHome visibleCells];
            UITableViewCell *lastVisibleCell = [visibleRows lastObject];
            NSIndexPath *path = [_TableHome indexPathForCell:lastVisibleCell];
            if(path.section == 0 && path.row == newsfeedPostArray.count-1)
            {
                if(!cannotScroll) {
                    if(goSearch) {
                        searchPageNum++;
                    }
                    else {
                        pageNum++;
                        [self getHomeContent];
                    }
                }
                
            }
        }
        else if(scrollView.tag == 3)
        {
            NSArray *visibleRows = [_forumTable visibleCells];
            UITableViewCell *lastVisibleCell = [visibleRows lastObject];
            NSIndexPath *path = [_forumTable indexPathForCell:lastVisibleCell];
            if(path.section == 0 && path.row == trendArray.count-1)
            {
                if(!cannotScrollForum) {
                    if(goSearch) {
                        searchPageNum++;
                    }
                    else {
                        forumPageNumber++;
                        [self getTrendingVideos];
                    }
                }
                
            }
        }
        else if(scrollView.tag == 2){
            NSArray *visibleRows = [_TablemyChannel visibleCells];
            UITableViewCell *lastVisibleCell = [visibleRows lastObject];
            NSIndexPath *path = [_TablemyChannel indexPathForCell:lastVisibleCell];
            if(path.section == 0 && path.row == chPostArray.count)
            {
                if(!cannotScrollMyCorner) {
                    if(goSearch) {
                        searchPageNum++;
                    }
                    else {
                        myCornerPageNum++;
                        [self getMyChannel];
                    }
                }
                
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if(scrollView.tag ==10) {
        if (!decelerate) {
            [self stoppedScrolling];
        }
    }
    
}
- (void)stoppedScrolling
{
    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y < 20) {
        [self animateNavBarTo:-(frame.size.height - 21)];
        
    }
    //[self getHomeContent];
}

- (void)updateBarButtonItems:(CGFloat)alpha
{
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    self.navigationItem.titleView.alpha = alpha;
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
}

- (void)animateNavBarTo:(CGFloat)y
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.navigationController.navigationBar.frame;
        if(IS_IPHONE_6) {
            frame.size.width = 375;
            frame.origin.y = 0;
        }
        if(IS_IPAD) {
            frame.size.width = 768;
            frame.origin.y = 0;
        }
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarButtonItems:alpha];
        
    }];
    
}
-(void)HideBottomBar{
    [UIView animateWithDuration:0.5 animations:^{
        _BottomBar.frame =  CGRectMake(0, 700, 375, 100);
        _BottomBar.center = CGPointMake(0, 1060);
    }];
}
-(void)ShowBottomBar{
    
    [UIView animateWithDuration:0.5 animations:^{
        // _BottomBar.frame =  CGRectMake(0, 567, 375, 100);
        _BottomBar.frame = TabBarFrame;
    }];
}
#pragma mark - TableView Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //  GetTrendingVideos *model = [forumsVideo objectAtIndex:indexPath.row];
    
}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return YES if you want the specified item to be editable.
//    return YES;
//}
//
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //add code here for when you hit delete
//    }
//}
-(void)playVideoComments:(UIButton*)sender{
    UIButton *playBtn = (UIButton *)sender;
    currentSelectedIndex = playBtn.tag;
    CommentsModel *tempVideos = [CommentsArray objectAtIndex:currentSelectedIndex];
    appDelegate.videotoPlay = tempVideos.video_link;
    appDelegate.videoUploader = tempVideos.userName;
    appDelegate.videotitle = tempVideos.title;
    //appDelegate.videotags = tempVideos.Tags;
    appDelegate.profile_pic_url = tempVideos.profile_link;
    //appDelegate.currentScreen = screen;
    postID = tempVideos.VideoID;
    
    [self SeenPost];
    [[NavigationHandler getInstance]MoveToPlayer];
}
-(void)playVideo:(UIButton*)sender{
    
    UIButton *playBtn = (UIButton *)sender;
    currentSelectedIndex = playBtn.tag;
    NSString *screen = [NSString stringWithFormat:@"%d", currentState];
    if(currentState == 3) {
        myChannelModel *model = [channelVideos objectAtIndex:currentSelectedIndex];
        appDelegate.videotoPlay = model.video_link;
        appDelegate.videoUploader = model.userName;
        appDelegate.videotitle = model.title;
        appDelegate.videotags = model.Tags;
        appDelegate.profile_pic_url = model.profile_image;
        appDelegate.currentScreen = screen;
        postID = model.VideoID;
        
        [self SeenPost];
        [[NavigationHandler getInstance]MoveToPlayer];
        
    }
    else if (currentState == 2) {
        GetTrendingVideos *model = [forumsVideo objectAtIndex:currentSelectedIndex];
        appDelegate.videotoPlay = model.video_link;
        appDelegate.videoUploader = model.userName;
        appDelegate.videotitle = model.title;
        appDelegate.videotags = model.Tags;
        appDelegate.profile_pic_url = model.profile_image;
        appDelegate.currentScreen = screen;
        postID = model.VideoID;
        
        [self SeenPost];
        [[NavigationHandler getInstance]MoveToPlayer];
    }
    else{
        
        GetTrendingVideos *model = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
        appDelegate.videotoPlay = model.video_link;
        appDelegate.videoUploader = model.userName;
        appDelegate.videotitle = model.title;
        appDelegate.videotags = model.Tags;
        appDelegate.profile_pic_url = model.profile_image;
        appDelegate.currentScreen = screen;
        postID = model.VideoID;
        [self SeenPost];
        [[NavigationHandler getInstance]MoveToPlayer];
    }
    
}
-(void)MovetoUserProfile:(UIButton*)sender{
    appDelegate.loaduserProfiel = TRUE;
    UIButton *Senderid = (UIButton *)sender;
    currentSelectedIndex = Senderid.tag;
    GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
    tempVideos =  [newsfeedsVideos  objectAtIndex:currentSelectedIndex];
    appDelegate.userToView = [tempVideos.user_id intValue];
    [[NavigationHandler getInstance]MoveToProfile];
}
- (void)LikeHearts:(UIButton*)sender{
    //liked = nil;
    UIButton *LikeBtn = (UIButton *)sender;
    currentSelectedIndex = LikeBtn.tag;
    GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
    myChannelModel *_profile = [[myChannelModel alloc]init];
    if(currentState == 2){
        tempVideos  = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
        postID = tempVideos.VideoID;
    }
    else if(currentState == 0)
    {
        tempVideos =  [getTrendingVideos.homieArray  objectAtIndex:currentSelectedIndex];
        postID = tempVideos.VideoID;
    }
    else if(currentState == 3)
    {
        _profile = [myChannelObj.trendingArray objectAtIndex:currentSelectedIndex];
        postID = _profile.VideoID;
    }
    
    [self LikePost:currentSelectedIndex];
    
    if (liked == YES) {
        [LikeBtn setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
    }else if (liked == NO){
        [LikeBtn setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
    }
    
}

#pragma mark Get Comments

-(void) ShowCommentspressed:(UIButton *)sender{
    CommentsArray = nil;
    // [Cm_VideoPlay addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    commentsTable.hidden = NO;
    Cm_VideoPlay.hidden = NO;
    UIButton *CommentsBtn = (UIButton *)sender;
    currentSelectedIndex = CommentsBtn.tag;
    [Cm_VideoPlay addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    [Cm_VideoPlay setTag:currentSelectedIndex];
    GetTrendingVideos *tempVideos;
    myChannelModel *chantempVideos;
    if(currentState == 2){
        tempVideos = [[GetTrendingVideos alloc]init];
        tempVideos  = [getTrendingVideos.trendingArray objectAtIndex:currentSelectedIndex];
        
    }else if(currentState == 0){
        //tempVideos = [[GetTrendingVideos alloc]init];
        tempVideos  = [getTrendingVideos.homieArray objectAtIndex:currentSelectedIndex];
 
    }
    else if(currentState == 3){
        chantempVideos = [[myChannelModel alloc]init];
        chantempVideos  = [myChannelObj.trendingArray objectAtIndex:currentSelectedIndex];
        
    }
    NSString *Comments;
    if(currentState == 2 || currentState == 0)
    {
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
        Comments = tempVideos.comments_count;
        commentsCountCommnetview.text = Comments;
        usernameCommnet.text = tempVideos.userName;
        videoTitleComments.text = tempVideos.title;
        videoLengthComments.text = tempVideos.video_length;
        likeCountsComment.text = tempVideos.like_count;
        seencountcomment.text = tempVideos.seen_count;
        postID = tempVideos.VideoID;
        userImage.imageURL = [NSURL URLWithString:tempVideos.profile_image];
        coverimgComments.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        NSURL *url = [NSURL URLWithString:tempVideos.profile_image];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        
        if([tempVideos.video_thumbnail_link isEqualToString:@""] )
        {
            coverimgComments.imageURL = [NSURL URLWithString:tempVideos.image_link];
            url1 = [NSURL URLWithString:tempVideos.image_link];
            Cm_VideoPlay.hidden = YES;
        }
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
    }
    else if(currentState == 3)
    {
        videomodel.videoID = chantempVideos.VideoID;
        videomodel.video_thumbnail_link = chantempVideos.video_thumbnail_link;
        videomodel.video_link = chantempVideos.video_link;
        videomodel.profile_image =  chantempVideos.profile_image;
        videomodel.userName = chantempVideos.userName;
        videomodel.is_anonymous = chantempVideos.is_anonymous;
        videomodel.title = chantempVideos.title;
        videomodel.like_count = chantempVideos.like_count;
        videomodel.like_by_me = chantempVideos.like_by_me;
        videomodel.seen_count = chantempVideos.seen_count;
         videomodel.title = chantempVideos.title;
        Comments = chantempVideos.comments_count;
        commentsCountCommnetview.text = Comments;
        usernameCommnet.text = chantempVideos.userName;
        videoTitleComments.text = chantempVideos.title;
        videoLengthComments.text = chantempVideos.video_length;
        likeCountsComment.text = chantempVideos.like_count;
        seencountcomment.text = chantempVideos.seen_count;
        
        postID = chantempVideos.VideoID;
        userImage.imageURL = [NSURL URLWithString:chantempVideos.profile_image];
        coverimgComments.imageURL = [NSURL URLWithString:chantempVideos.video_thumbnail_link];
        NSURL *url = [NSURL URLWithString:chantempVideos.profile_image];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        NSURL *url1 = [NSURL URLWithString:chantempVideos.video_thumbnail_link];
        if([chantempVideos.video_thumbnail_link isEqualToString:@""] )
        {
            coverimgComments.imageURL = [NSURL URLWithString:chantempVideos.image_link];
            url1 = [NSURL URLWithString:chantempVideos.image_link];
            Cm_VideoPlay.hidden = YES;
        }
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
    }
    
    
    ParentCommentID = @"-1";
    [self GetCommnetsOnPost];
    //[self.view addSubview:commentsView];
}

-(void) ReplyCommentpressed:(UIButton *)sender{
    
    UIButton *CommentsBtn = (UIButton *)sender;
    currentSelectedIndex = CommentsBtn.tag;
    
    CommentsModel *tempVideos = [[CommentsModel alloc]init];
    tempVideos  = [CommentsArray objectAtIndex:currentSelectedIndex];
    NSString *Comments = tempVideos.comments_count;
    commentsCountCommnetview.text = Comments;
    usernameCommnet.text = tempVideos.userName;
    videoTitleComments.text = tempVideos.title;
    videoLengthComments.text = tempVideos.video_length;
    likeCountsComment.text = tempVideos.like_count;
    
    //postID = tempVideos.VideoID;
    
    userImage.imageURL = [NSURL URLWithString:tempVideos.profile_link];
    NSURL *url = [NSURL URLWithString:tempVideos.profile_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    
    coverimgComments.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    if([tempVideos.video_thumbnail_link isEqualToString:@""] )
    {
        coverimgComments.imageURL = [NSURL URLWithString:tempVideos.image_link];
        url1 = [NSURL URLWithString:tempVideos.image_link];
        
    }
    Cm_VideoPlay.hidden = YES;
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
    
    ParentCommentID = tempVideos.VideoID;
    [self GetCommnetsOnPost];
    [self.view addSubview:commentsView];
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
            NSDictionary *users = [result objectForKey:@"comments"];
              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
                    
                    CommentsArray = CommentsModelObj.CommentsArray;
                    chVideosArray = CommentsModelObj.mainArray;
                    chArrImage = CommentsModelObj.ImagesArray;
                    chArrThumbnail = CommentsModelObj.ThumbnailsArray;
                   
                }
                CommentsVC *commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
                commentController.commentsObj = CommentsModelObj;
                commentController.postArray = videomodel;
                [[self navigationController] pushViewController:commentController animated:YES];
                //[[NavigationHandler getInstance]MoveToComments];
                //[commentsTable reloadData];
                //[self.view addSubview:commentsView];
                if (IS_IPHONE_6) {
                    commentsView.frame = CGRectMake(0, 0, 375, 667);
                    commentsTable.frame = CGRectMake(0,297,375,370);
                }
                else if(IS_IPHONE_6Plus)
                {
                    commentsView.frame = CGRectMake(0, 0, 414, 736);
                }
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (IBAction)CommentsBack:(id)sender {
    
    //CommentsArray = nil;
    [commentsView removeFromSuperview];
}



- (void)Flag:(UIButton*)sender{
    
    UIButton *seenBtn = (UIButton *)sender;
    currentSelectedIndex = seenBtn.tag;
    
    GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
    tempVideos  = [getTrendingVideos.trendingArray objectAtIndex:currentSelectedIndex];
    
    postID = tempVideos.VideoID;
    [self SeenPost];
    
    if (seenPost == YES) {
        
        
    }else if (seenPost == NO){
        
    }
    
}

- (void)editPost:(UIButton*)sender{
    
    _optionsView.hidden = NO;
    [self.view addSubview:self.optionsView];
    
}


- (CGRect)offScreenFrame
{
    return CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

#pragma mark Open Friend's Channel Methods

-(void) OpenFriendsChannelPressed:(UIButton *)sender{
    
    UIButton *statusBtn = (UIButton *)sender;
    currentSelectedIndex = statusBtn.tag;
    
    PopularUsersModel *PopUser = [[PopularUsersModel alloc]init];
    PopUser  = [UsersModel.PopUsersArray objectAtIndex:currentSelectedIndex];
    friendId = PopUser.friendID;
    UserRelation = PopUser.status;
    if(loadFollowings)
    {
        Followings *tempUsers = [[Followings alloc]init];
        tempUsers = [FollowingsAM objectAtIndex:currentSelectedIndex];
        friendId = tempUsers.f_id;
        UserRelation = tempUsers.status;
    }
    if ([UserRelation isEqualToString:@"ADD_FRIEND"]) {
        
        [friendsStatusbtn setTitle:@"Add Friend" forState:UIControlStateNormal];
    }else if ([UserRelation isEqualToString:@"PENDING"]){
        
        [friendsStatusbtn setTitle:@"Pending" forState:UIControlStateNormal];
    }else if ([UserRelation isEqualToString:@"FRIEND"]) {
        
        [friendsStatusbtn setTitle:@"Friend" forState:UIControlStateNormal];
    }else if ([UserRelation isEqualToString:@"ACCEPT_REQUEST"]){
        
        [friendsStatusbtn setTitle:@"Accept Request" forState:UIControlStateNormal];
    }
    
    [self GetUsersChannel];
    
    
}

- (IBAction)showFollowings:(id)sender {
    loadFollowings = true;
    FollowingsAM  = nil;
    FollowingsAM = [[NSMutableArray alloc]init];
    [self getFollowing];
    [self.view addSubview:searchView];
    
}

- (IBAction)showFollowers:(id)sender {
    loadFollowings = true;
    FollowingsAM  = nil;
    FollowingsAM = [[NSMutableArray alloc]init];
    [self getFollowers];
    [self.view addSubview:searchView];
}

- (IBAction)userChannelBackbtn:(id)sender {
    [friendsChannelView removeFromSuperview];
    [SVProgressHUD dismiss];
}

- (IBAction)UserStatusbtnPressed:(id)sender {
    
    if ([friendsStatusbtn.titleLabel.text isEqualToString:@"Add Friend"]) {
        
        [friendsStatusbtn setTitle:@"Request Sent" forState:UIControlStateNormal];
        [self sendFriendRequest];
    }else if ([friendsStatusbtn.titleLabel.text isEqualToString:@"Pending"]){
        
        [friendsStatusbtn setTitle:@"Add Friend" forState:UIControlStateNormal];
        [self sendCancelRequest];
    }else if ([friendsStatusbtn.titleLabel.text isEqualToString:@"Friend"]) {
        
        [friendsStatusbtn setTitle:@"Add Friend" forState:UIControlStateNormal];
        [self sendDeleteFriend];
    }
}



-(void) GetUsersChannel{
    [SVProgressHUD showWithStatus:@"Loading..."];
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
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"profile"];
            
            if(success == 1) {
                //////Profile Response //////
                
                UserChannelModel *_profile = [[UserChannelModel alloc] init];
                ///Saving Data
                _profile.beams_count = [users objectForKey:@"beams_count"];
                _profile.friends_count = [users objectForKey:@"following_count"];
                _profile.full_name = [users objectForKey:@"full_name"];
                _profile.cover_link = [users objectForKey:@"cover_link"];
                _profile.user_id = [users objectForKey:@"id"];
                _profile.profile_image = [users objectForKey:@"profile_link"];
                _profile.likes_count = [users objectForKey:@"followers_count"];
                _profile.gender = [users objectForKey:@"gender"];
                _profile.email = [users objectForKey:@"email"];
                _profile.is_celeb = [users objectForKey:@"is_celeb"];
                
                
                /// Populating Data
                
                friendsImage.imageURL = [NSURL URLWithString:_profile.profile_image];
                NSURL *url = [NSURL URLWithString:_profile.profile_image];
                [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
                appDelegate.IS_celeb = _profile.is_celeb;
                [self setUserProfileImage];
                
                friendsCover.imageURL = [NSURL URLWithString:_profile.profile_image];
                NSURL *url1 = [NSURL URLWithString:_profile.profile_image];
                [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
                
                
                friendsNamelbl.text = _profile.full_name;
                friendsBeamcount.text = [[NSString alloc]initWithFormat:@"%@ Beams",_profile.beams_count ];
                friendsFollowings.text = [[NSString alloc]initWithFormat:@"%@ Following",_profile.friends_count];
                friendsFollowers.text = [[NSString alloc]initWithFormat:@"%@ Followers",_profile.likes_count];
                
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
                
                [friendsChannelTable reloadData];
                [self.view addSubview:friendsChannelView];
                if(IS_IPHONE_6){
                    friendsChannelView.frame = CGRectMake(0, 0, 375, 667);
                }
                else if(IS_IPHONE_6Plus)
                {
                    friendsChannelView.frame = CGRectMake(0, 0, 414, 736);
                }
                [SVProgressHUD dismiss];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
    
}


#pragma mark Search Methods

- (IBAction)hideShowsearchbar:(id)sender {
    
    [searchField resignFirstResponder];
    [searchField2 resignFirstResponder];
    loadFollowings = false;
    FollowingsAM = nil;
    [searchTable reloadData];
    [self SearchCorners];
    [self.view addSubview:searchView];
    SearchforTag = NO;
}

- (IBAction)searchBack:(id)sender {
    [searchView removeFromSuperview];
    loadFollowings = false;
    [tagFriendsView removeFromSuperview];
    [SVProgressHUD dismiss];
}

-(void) SearchCorners{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    searchKeyword = searchField.text;
    if ([searchKeyword isEqualToString:@""]) {
        searchKeyword = searchField2.text;
    }
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_SEARCH_FRIEND,@"method",
                              token,@"Session_token",@"1",@"page_no",searchKeyword,@"keyword", nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [SVProgressHUD dismiss];
            
            int success = [[result objectForKey:@"success"] intValue];
            NSString *users = [result objectForKey:@"users_found"];
            
            if(success == 1) {
                searchField.text = nil;
                searchField2.text = nil;
                
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
                
                [searchTable reloadData];
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
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
        [self sendFriendRequest];
        
    }else if ([PopUser.status isEqualToString:@"PENDING"]){
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"requestsent.png"] forState:UIControlStateNormal];
        [self sendCancelRequest];
        
    }else if ([PopUser.status isEqualToString:@"FRIEND"]){
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"friends.png"] forState:UIControlStateNormal];
        [self sendDeleteFriend];
        
    }else if ([PopUser.status isEqualToString:@"ACCEPT_REQUEST"]){
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"requestaccept.png"] forState:UIControlStateNormal];
        [self sendDeleteFriend];
        
    }
}

- (void) getUsers{
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_SEARCH_FRIEND,@"method",
                              token,@"session_token",@"1",@"page_no",searchKeyword,@"keyword",nil];
    
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
            NSDictionary *users = [result objectForKey:@"users_found"];
            
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
                [searchTable reloadData];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
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
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                
                [self getUsers];
                [searchTable reloadData];
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
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                
                [self getUsers];
                [searchTable reloadData];
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
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                [self getUsers];
                [searchTable reloadData];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
#pragma mark - Top Bar Contorls

- (IBAction)ShowDrawer:(id)sender {
    
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
    //    }
    
    [[DrawerVC getInstance] AddInView:self.view];
    [[DrawerVC getInstance] ShowInView];
    
}

- (IBAction)showProfile:(id)sender {
    
    [[NavigationHandler getInstance]MoveToProfile];
}


- (IBAction)ChannelPressed:(id)sender {
    currentState = 3;
    CGRect frame = _mainScroller.frame;
    frame.origin.x = frame.size.width * 1;
    frame.origin.y = 0;
    [_mainScroller scrollRectToVisible:frame animated:YES];
    
}

- (IBAction)TrendingPressed:(id)sender {
    currentState = 2;
    CGRect frame = _mainScroller.frame;
    frame.origin.x = frame.size.width * 2;
    frame.origin.y = 0;
    [_mainScroller scrollRectToVisible:frame animated:YES];
    
}

- (IBAction)HomePressed:(id)sender {
    CGRect frame = _mainScroller.frame;
    frame.origin.x = frame.size.width * 0;
    frame.origin.y = 0;
    currentState = 0;
    
    [_mainScroller scrollRectToVisible:frame animated:YES];
}

- (IBAction)backBtn:(id)sender {
    _optionsView.hidden = YES;
    [_optionsView removeFromSuperview];
}

- (IBAction)editBtn:(id)sender {
}

- (IBAction)deleteBtn:(id)sender {
    
}

- (IBAction)findFriends:(id)sender {
    
    [self.view addSubview:searchView];
}
#pragma mark - EditCover
- (IBAction)EditCoverImg:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:CurrentImageCategoryCover forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SVProgressHUD dismiss];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    [self setUserCoverImage];
    
    //[self.view addSubview:uploadimageView];
    
}

- (IBAction)PhotoOnComments:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setInteger:CurrentImageCategoryCommentPhoto forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.view addSubview:uploadimageView];
    
}

- (IBAction)VideoOnCommentsPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:VideoOnCommentsGallery forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.view addSubview:BeamTypeView];
}

- (IBAction)PrivacyEveryOne:(id)sender {
    [_CPEveryone setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    [_CPOnlyMe setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_CPFriends setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    everyOnelbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    onlyMelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    Friendslbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    privacySelected = @"PUBLIC";
    
}

- (IBAction)PrivacyOnlyMe:(id)sender {
    [_CPEveryone setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_CPOnlyMe setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    [_CPFriends setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    onlyMelbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    everyOnelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    Friendslbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    privacySelected = @"PRIVATE";
}

- (IBAction)PrivacyFriends:(id)sender {
    [_CPEveryone setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_CPOnlyMe setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_CPFriends setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    Friendslbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    onlyMelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    everyOnelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    privacySelected = @"FRIENDS";
}

- (IBAction)upto60Pressed:(id)sender {
    [_upto60Comments setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    [_NoRepliesbtn setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_unlimitedRepliesbtn setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    
    upto60.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    Unlimited.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    noreplies.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    
    commentAllowed = @"60";
    
}

- (IBAction)noRepliesPressed:(id)sender {
    [_upto60Comments setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_NoRepliesbtn setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    [_unlimitedRepliesbtn setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    noreplies.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    Unlimited.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    upto60.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    commentAllowed = @"0";
}

- (IBAction)UnlimitedPressed:(id)sender {
    [_upto60Comments setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_NoRepliesbtn setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_unlimitedRepliesbtn setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    Unlimited.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    upto60.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    noreplies.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    commentAllowed = @"-1";
}
- (void) setUserCoverImage{
    NSURL *url1 = [NSURL URLWithString:ProfileObj.cover_image];
    NSData *data1 = [NSData dataWithContentsOfURL:url1];
    UIImage *img1 = [[UIImage alloc] initWithData:data1];
    channelCover.image = img1;
    
}

- (void) updateCover{
    [SVProgressHUD showWithStatus:@"Updating Cover...."];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    
    requestc = [ASIFormDataRequest requestWithURL:url];
    [requestc addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [requestc setPostValue:token forKey:@"session_token"];
    
    NSData *profileDatas = UIImagePNGRepresentation(channelCover.image);
    [requestc setData:profileDatas withFileName:[NSString stringWithFormat:@"%@.png",@"thumbnail"] andContentType:@"image/png" forKey:@"cover_link"];
    
    [requestc setPostValue:METHOD_UPDATE_PROFILE forKey:@"method"];
    
    [requestc setRequestMethod:@"POST"];
    [requestc setTimeOutSeconds:300];
    [requestc setDelegate:self];
    [requestc startAsynchronous];
}
-(void) uploadImageComments{
    //[SVProgressHUD showWithStatus:@"uploading Comment"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo Comment" message:@"Uploading Started, you will be notified when the process completes." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    
    requestc = [ASIFormDataRequest requestWithURL:url];
    [requestc addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [requestc setPostValue:token forKey:@"session_token"];
    
    
    [requestc setData:commentImageData withFileName:[NSString stringWithFormat:@"%@.png",@"image"] andContentType:@"image/png" forKey:@"image_link"];
    [requestc setPostValue:postID forKey:@"post_id"];
    [requestc setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    [requestc setPostValue:@"-1" forKey:@"reply_count"];
    [requestc setPostValue:@"0" forKey:@"is_anonymous"];
    [requestc setPostValue:METHOD_COMMENTS_POST forKey:@"method"];
    
    [requestc setRequestMethod:@"POST"];
    [requestc setTimeOutSeconds:300];
    [requestc setDelegate:self];
    [requestc startAsynchronous];
    //[self imagepickerCross:self];
}
-(void) uploadBeamComments:(NSData*)file{
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [request setData:file withFileName:[NSString stringWithFormat:@"%@.mp4",@"video"] andContentType:@"recording/video" forKey:@"video_link"];
    NSData *profileDatas = UIImagePNGRepresentation(_thumbnailImg1.image);
    [request setData:profileDatas withFileName:[NSString stringWithFormat:@"%@.png",@"thumbnail"] andContentType:@"image/png" forKey:@"video_thumbnail_link"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    
    
    [request setPostValue:@"90" forKey:@"video_angle"];
    [request setPostValue:userSession forKey:@"session_token"];
    [request setPostValue:privacySelected forKey:@"privacy"];
    [request setPostValue:TopicSelected forKey:@"topic_id"];
    [request setPostValue:commentAllowed forKey:@"reply_count"];
    [request setPostValue:videotype forKey:@"filter"];
    [request setPostValue:IS_mute forKey:@"mute"];
    [request setPostValue:video_duration forKey:@"video_length"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    
    [request setPostValue:METHOD_COMMENTS_POST forKey:@"method"];
    
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request startAsynchronous];
}
- (IBAction)PhotoPressed:(id)sender {
    [SVProgressHUD dismiss];
    [[NSUserDefaults standardUserDefaults] setInteger:CurrentImageCategoryUpload forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.view addSubview:uploadimageView];
}

- (IBAction)fromCamera:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)fromGallery:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


- (IBAction)imagepickerCross:(id)sender {
    [uploadimageView removeFromSuperview];
    
}

- (IBAction)RecorderPressed:(id)sender {
    [self.view addSubview:_uploadAudioView];
    
}

#pragma mark - Beam Pressed

- (IBAction)beamPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:uploadBeamFromGallery forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if([sender tag] == 100){
        uploadAnonymous = true;
        uploadBeamTag = false;
    }
    else if([sender tag ] == 101)
    {
        uploadAnonymous = false;
        uploadBeamTag = true;
    }
    
    //    [[NSUserDefaults standardUserDefaults] setInteger:CurrentImageCategoryBeam forKey:@"currentImageCategory"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.allowsEditing = NO;
        
        NSArray *mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
        
        picker.mediaTypes = mediaTypes;
        picker.videoMaximumDuration = 10;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"I'm afraid there's no camera on this device!" delegate:nil cancelButtonTitle:@"Dang!" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

- (IBAction)NormalBeantypePressed:(id)sender {
    [self.view addSubview:selctBeamSourceView];
}

- (IBAction)AnonymoueBeamPressed:(id)sender {
    [self.view addSubview:selctBeamSourceView];
}

- (IBAction)BeamTypeCross:(id)sender {
    
    [BeamTypeView removeFromSuperview];
}

- (IBAction)recordBeamfromCamera:(id)sender {
    
    [BeamTypeView removeFromSuperview];
    //    [[NSUserDefaults standardUserDefaults] setInteger:CurrentImageCategoryBeam forKey:@"currentImageCategory"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.allowsEditing = NO;
        
        NSArray *mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
        
        picker.mediaTypes = mediaTypes;
        picker.videoMaximumDuration = 60;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"I'm afraid there's no camera on this device!" delegate:nil cancelButtonTitle:@"Dang!" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

- (IBAction)uploadfromGallery:(id)sender {
    
    [BeamTypeView removeFromSuperview];
    
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    imagePicker.videoMaximumDuration = 60; // duration in seconds
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (IBAction)uploadSourceCross:(id)sender {
    [BeamTypeView removeFromSuperview];
    [selctBeamSourceView removeFromSuperview];
}

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mute:(id)sender {
    IS_mute = @"YES";
    if (_muteBtn.tag == 0) {
        [_muteBtn setBackgroundImage:[UIImage imageNamed:@"unmute.png"] forState:UIControlStateNormal];
        IS_mute = @"YES";
        _muteBtn.tag = 1;
    }else if (_muteBtn.tag == 1) {
        [_muteBtn setBackgroundImage:[UIImage imageNamed:@"mute.png"] forState:UIControlStateNormal];
        IS_mute = @"NO";
        _muteBtn.tag = 0;
    }
    
}



#pragma mark - Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // user hit cancel
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == CurrentImageCategoryCover)
    {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        channelCover.image = chosenImage;
        [picker dismissViewControllerAnimated:YES completion:NULL];
        [self updateCover];
    }
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] ==CurrentImageCategoryCommentPhoto)
    {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        commentImageData = UIImagePNGRepresentation(chosenImage);
        [picker dismissViewControllerAnimated:YES completion:NULL];
        [self uploadImageComments];
        
    }
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == CurrentImageCategoryBeam  || [[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == uploadBeamFromGallery   || [[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == VideoOnCommentsGallery ){
        // grab our movie URL
        NSURL *chosenMovie = [info objectForKey:UIImagePickerControllerMediaURL];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:chosenMovie options:nil];
        
        NSTimeInterval durationInSeconds = 0.00;
        if (asset)
            durationInSeconds = CMTimeGetSeconds(asset.duration);
        
        NSUInteger dTotalSeconds = durationInSeconds;
        
        NSUInteger dSeconds =(dTotalSeconds  % 60);
        NSUInteger dMinutes = (dTotalSeconds / 60 ) % 60;
        
        video_duration = [[NSString alloc]initWithFormat:@"%02lu:%02lu",(unsigned long)dMinutes,(unsigned long)dSeconds];
        // save it to the documents directory (option 1)
        //NSURL *fileURL = [self grabFileURL:@"video.mov"];
        
        movieData = [NSData dataWithContentsOfURL:chosenMovie];
        //[movieData writeToURL:fileURL atomically:YES];
        
        // save it to the Camera Roll (option 2)
        //UISaveVideoAtPathToSavedPhotosAlbum([chosenMovie path], nil, nil, nil);
        
        // and dismiss the picker
        [self dismissViewControllerAnimated:YES completion:nil];
        [self PrivacyEveryOne:self];
        [self UnlimitedPressed:self];
        
        [self.view addSubview:_uploadBeamView];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        CMTime time = [asset duration];
        time.value = 0;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        _thumbnailImageView.image = thumbnail;
        profileData = UIImagePNGRepresentation(thumbnail);
        
        // int i = 0;
        //        if(i == 0) {
        //            //AVAsset *asset = [AVAsset assetWithURL:chosenMovie];
        //            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        //            CMTime time = [asset duration];
        //            time.value = 0;
        //            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        //            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        //            CGImageRelease(imageRef);
        //
        //            thumbnail_Color_1 = thumbnail;
        //            _thumbnailImg1.image = thumbnail;
        //
        //            [self convertImageToGrayScale:thumbnail];
        //            thumbnail_BnW_1 = filteredImage;
        //
        //            i++;
        //        }
        //        if(i == 1) {
        //            AVAsset *asset = [AVAsset assetWithURL:chosenMovie];
        //            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        //            CMTime time = [asset duration];
        //            time.value = 1000;
        //            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        //            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        //            CGImageRelease(imageRef);
        //
        //            thumbnail_Color_2 = thumbnail;
        //            _thumbnailImg2.image = thumbnail;
        //            [self convertImageToGrayScale:thumbnail];
        //            thumbnail_BnW_2 = filteredImage;
        //
        //            i++;
        //        }
        //        if(i == 2) {
        //            AVAsset *asset = [AVAsset assetWithURL:chosenMovie];
        //            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        //            CMTime time = [asset duration];
        //            time.value = 2000;
        //            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        //            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        //            CGImageRelease(imageRef);
        //
        //            thumbnail_Color_3 = thumbnail;
        //            _thumbnailImg3.image = thumbnail;
        //            [self convertImageToGrayScale:thumbnail];
        //            thumbnail_BnW_3 = filteredImage;
        //            i++;
        //        }
        
        
        [[_thumbnail1 layer] setBorderWidth:2.0f];
        [[_thumbnail1 layer] setBorderColor:[UIColor greenColor].CGColor];
        
        emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
        emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        emojiKeyboardView.delegate = self;
        
    }
}

-(void) uploadBeam :(NSData*)file {
    totalBytestoUpload = file.length;
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    NSString *isAnonymous = @"";
    if(uploadAnonymous)
        isAnonymous = @"1";
    else if(uploadBeamTag)
        isAnonymous = @"0";
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [request setData:file withFileName:[NSString stringWithFormat:@"%@.mp4",@"video"] andContentType:@"recording/video" forKey:@"video_link"];
    [request setData:profileData withFileName:[NSString stringWithFormat:@"%@.png",@"thumbnail"] andContentType:@"image/png" forKey:@"video_thumbnail_link"];
    
    [request setPostValue:@"90" forKey:@"video_angle"];
    [request setPostValue:userSession forKey:@"session_token"];
    [request setPostValue:privacySelected forKey:@"privacy"];
    //[request setPostValue:TopicSelected forKey:@"topic_id"];
    [request setPostValue:commentAllowed forKey:@"reply_count"];
    [request setPostValue:_statusText.text forKey:@"caption"];
    //[request setPostValue:videotype forKey:@"filter"];
    [request setPostValue:IS_mute forKey:@"mute"];
    [request setPostValue:tagsString forKey:@"topic_name"];
    [request setPostValue:video_duration forKey:@"video_length"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    [request setPostValue:isAnonymous forKey:@"is_anonymous"];
    [request setPostValue:METHOD_UPLOAD_STATUS forKey:@"method"];
    //[request setShowAccurateProgress:YES];
    [request setUploadProgressDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request startAsynchronous];
    
}
- (void)setProgress:(float)progress
{
    if(progress > 1.0)
        [_progressview setProgress:0.0];
    else if(_progressview.progress < 0.8)
        [_progressview setProgress:progress animated:YES];
    
}
- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength {
    NSLog(@"data length: %lld", newLength);
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
    NSLog(@"This is respone ::: %@",result);
    [_progressview setProgress:1.0];
    if(currentState == 0)
        [self getHomeContent];
    
    AudioServicesPlaySystemSound(1003);
}

- (void)requestFailed:(ASIHTTPRequest *)theRequest {
    
    NSString *response = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"This is respone ::: %@",response);
    
    
}

- (IBAction)thumbnail2Pressed:(id)sender {
    
    [[_thumbnail1 layer] setBorderWidth:2.0f];
    [[_thumbnail1 layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[_thumbnail2 layer] setBorderWidth:2.0f];
    [[_thumbnail2 layer] setBorderColor:[UIColor greenColor].CGColor];
    
    [[_thumbnail3 layer] setBorderWidth:2.0f];
    [[_thumbnail3 layer] setBorderColor:[UIColor clearColor].CGColor];
    profileData = UIImagePNGRepresentation(_thumbnailImg2.image);
}

- (IBAction)thumbnail3Pressed:(id)sender {
    
    [[_thumbnail1 layer] setBorderWidth:2.0f];
    [[_thumbnail1 layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[_thumbnail2 layer] setBorderWidth:2.0f];
    [[_thumbnail2 layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[_thumbnail3 layer] setBorderWidth:2.0f];
    [[_thumbnail3 layer] setBorderColor:[UIColor greenColor].CGColor];
    profileData = UIImagePNGRepresentation(_thumbnailImg3.image);
}

- (IBAction)uploadBeamBackPressed:(id)sender {
    [_uploadAudioView removeFromSuperview];
    [_uploadBeamView removeFromSuperview];
}



- (IBAction)emoticonPressed:(id)sender {
    
    UIButton *senderBtn = (UIButton*)sender;
    _statusText.inputView = emojiKeyboardView;
    [_statusText becomeFirstResponder];
    //    if(senderBtn.tag == 1) {
    //        senderBtn.tag = 2;
    //        _statusText.inputView = emojiKeyboardView;
    //        [_statusText becomeFirstResponder];
    //    }
    //    else {
    //        senderBtn.tag = 1;
    //        _statusText.inputView = UIKeyboardTypeDefault;
    //
    //        [_statusText resignFirstResponder];
    //    }
}

- (IBAction)privacyPressed:(id)sender {
    UIButton *senderBtn = (UIButton*) sender;
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Select Privacy"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"Public"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Private"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Friends"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(pushMenuItem:)],
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:senderBtn.frame
                 menuItems:menuItems];
}

- (void) pushMenuItem:(id)sender
{
    KxMenuItem *selected = (KxMenuItem*)sender;
    if ( [selected.title isEqualToString:@"Private"] ){
        privacySelected = @"PRIVATE";
    }else if ([selected.title isEqualToString:@"Public"]){
        privacySelected = @"PUBLIC";
    }else if ([selected.title isEqualToString:@"Friends"]){
        privacySelected = @"FRIENDS";
        
    }else if ([selected.title isEqualToString:@"General"]){
        TopicSelected = @"1";
    }else if ([selected.title isEqualToString:@"Entertainment"]){
        TopicSelected = @"2";
    }else if ([selected.title isEqualToString:@"Sports"]){
        TopicSelected = @"3";
    }else if ([selected.title isEqualToString:@"Lifestyle"]){
        TopicSelected = @"4";
    }else if ([selected.title isEqualToString:@"Politics"]){
        TopicSelected = @"5";
        
    }else if ([selected.title isEqualToString:@"No Comment"]){
        commentAllowed = @"0";
    }else if ([selected.title isEqualToString:@"50 Comment"]){
        commentAllowed = @"50";
    }else if ([selected.title isEqualToString:@"Unlimited Comments"]){
        commentAllowed = @"-1";
    }
    
    
}

- (IBAction)selectTopicPressed:(id)sender {
    UIButton *senderBtn = (UIButton*) sender;
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Select Topic"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"General"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Entertainment"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Sports"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Lifestyle"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Politics"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(pushMenuItem:)],
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:senderBtn.frame
                 menuItems:menuItems];
}

- (IBAction)thumbnail1Pressed:(id)sender {
    
    [[_thumbnail1 layer] setBorderWidth:2.0f];
    [[_thumbnail1 layer] setBorderColor:[UIColor greenColor].CGColor];
    
    [[_thumbnail2 layer] setBorderWidth:2.0f];
    [[_thumbnail2 layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[_thumbnail3 layer] setBorderWidth:2.0f];
    [[_thumbnail3 layer] setBorderColor:[UIColor clearColor].CGColor];
    profileData = UIImagePNGRepresentation(_thumbnailImg1.image);
}

- (IBAction)uploadBeamPressed:(id)sender {
    
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Beam Upload" message:@"Uploading Started, you will be notified when the process completes." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    //    [alert show];
    [_uploadAudioView removeFromSuperview];
    [self.uploadBeamView removeFromSuperview];
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == VideoOnCommentsGallery)
    {
        [self uploadBeamComments:movieData];
    }
    else if ( [[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == uploadBeamFromGallery){
        [self uploadBeam:movieData];
    }
    else {
        [self uploadAduio:audioData];
    }
    [selctBeamSourceView removeFromSuperview];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    isFirstTimeClicked = false;
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == VideoOnCommentsGallery || [[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == uploadBeamFromGallery   || [[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == VideoOnCommentsGallery)
    {
        [self.uploadBeamView removeFromSuperview];
    }
}

- (IBAction)rotateThumbnails:(id)sender {
    self.thumbnailImg1.image = [self rotateImage:self.thumbnailImg1.image onDegrees:30];
    self.thumbnailImg2.image = [self rotateImage:self.thumbnailImg2.image onDegrees:30];
    self.thumbnailImg3.image = [self rotateImage:self.thumbnailImg3.image onDegrees:30];
    
    btnBnW.layer.borderWidth =2.0f;
    btnBnW.layer.borderColor =[UIColor clearColor].CGColor;
    
    btnColour.layer.borderWidth =2.0f;
    btnColour.layer.borderColor =[UIColor clearColor].CGColor;
    
    btnRotate.layer.borderWidth =2.0f;
    btnRotate.layer.borderColor = [UIColor greenColor].CGColor;
    
}

- (IBAction)colouredPressed:(id)sender {
    videotype = @"COLOUR";
    
    _thumbnailImg1.image = thumbnail_Color_1;
    _thumbnailImg2.image = thumbnail_Color_2;
    _thumbnailImg3.image = thumbnail_Color_3;
    
    [[btnBnW layer] setBorderWidth:2.0f];
    [[btnBnW layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[btnColour layer] setBorderWidth:2.0f];
    [[btnColour layer] setBorderColor:[UIColor greenColor].CGColor];
    
    [[btnRotate layer] setBorderWidth:2.0f];
    [[btnRotate layer] setBorderColor:[UIColor clearColor].CGColor];
    
}

- (IBAction)blacknWhitepressed:(id)sender {
    videotype = @"BLACK_AND_WHITE";
    
    _thumbnailImg1.image = thumbnail_BnW_1;
    _thumbnailImg2.image = thumbnail_BnW_2;
    _thumbnailImg3.image = thumbnail_BnW_3;
    
    [[btnBnW layer] setBorderWidth:2.0f];
    [[btnBnW layer] setBorderColor:[UIColor greenColor].CGColor];
    
    [[btnColour layer] setBorderWidth:2.0f];
    [[btnColour layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[btnRotate layer] setBorderWidth:2.0f];
    [[btnRotate layer] setBorderColor:[UIColor clearColor].CGColor];
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    filteredImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    return filteredImage;
}


- (IBAction)CommentsCountpressed:(id)sender {
    
    UIButton *senderBtn = (UIButton*) sender;
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Select Option"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"No Comment"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"50 Comments"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Unlimited Comments"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:senderBtn.frame
                 menuItems:menuItems];
    
}



- (IBAction)tagFriendsPressed:(id)sender {
    
    [self.view addSubview:tagFriendsView];
    
    
}


#pragma mark AUDIO RECORDING AND UPLOADING

-(void)setAudioRecordSettings
{
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.caf"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    
    _audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:soundFileURL
                      settings:recordSettings
                      error:&error];
    _audioRecorder.delegate = self;
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
        [_audioRecorder prepareToRecord];
    }
}

- (IBAction)recorderTapped:(id)sender {
    if(!_audioRecorder.recording){
        [self animateImages];
        timerToupdateLbl = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
        audioTimeOut = [NSTimer scheduledTimerWithTimeInterval: 60.0 target: self
                                                      selector: @selector(callAfterSixtySecond:) userInfo: nil repeats: NO];
        [_audioRecorder record];
    }
    else{
        
        [_audioRecorder stop];
        [audioBtnImage stopAnimating];
        
    }
}
-(void) callAfterSixtySecond:(NSTimer*) t
{
    [_audioRecorder stop];
    [timerToupdateLbl invalidate];
    [audioTimeOut invalidate];
    
}
-(void) updateCountdown {
    int minutes, seconds;
    secondsLeft--;
    minutes = (secondsLeft % 3600) / 60;
    seconds = (secondsLeft %3600) % 60;
    countDownlabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    secondsConsumed = [NSString stringWithFormat:@"%02d:%02d", 00, 60 - secondsLeft];
}
-(void)animateImages{
    NSArray *loaderImages = @[@"state1.png", @"state2.png", @"state3.png"];
    NSMutableArray *loaderImagesArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < loaderImages.count; i++) {
        [loaderImagesArr addObject:[UIImage imageNamed:[loaderImages objectAtIndex:i]]];
    }
    audioBtnImage.animationImages = loaderImagesArr;
    audioBtnImage.animationDuration = 0.5f;
    [audioBtnImage startAnimating];
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    countDownlabel.text = @"00:00";
    secondsLeft = 60;
    audioData = [NSData dataWithContentsOfURL:_audioRecorder.url];
    [self.view addSubview:_uploadBeamView];
}
-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder
                                  error:(NSError *)error
{
    
    countDownlabel.text = @"00:00";
    secondsLeft = 60;
    secondsConsumed = 0;
    NSLog(@"Encode Error occurred");
}

-(void)uploadAduio:(NSData*)file{
    
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [request setData:file withFileName:[NSString stringWithFormat:@"%@.caf",@"sound"] andContentType:@"audio/caf" forKey:@"audio_link"];
    
    [request setPostValue:userSession forKey:@"session_token"];
    [request setPostValue:privacySelected forKey:@"privacy"];
    //[request setPostValue:TopicSelected forKey:@"topic_id"];
    [request setPostValue:commentAllowed forKey:@"reply_count"];
    [request setPostValue:_statusText.text forKey:@"caption"];
    //[request setPostValue:videotype forKey:@"filter"];
    [request setPostValue:@"0" forKey:@"is_anonymous"];
    [request setPostValue:@"0" forKey:@"mute"];
    [request setPostValue:tagsString forKey:@"topic_name"];
    [request setPostValue:secondsConsumed forKey:@"video_length"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    [request setPostValue:METHOD_UPLOAD_STATUS forKey:@"method"];
    //[request setShowAccurateProgress:YES];
    [request setUploadProgressDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request startAsynchronous];
}
#pragma mark -----------
- (IBAction)commentRadio:(RadioButton*)sender{
    
}

- (UIImage *)rotateImage:(UIImage *)image onDegrees:(float)degrees
{
    CGFloat rads = M_PI * degrees / 180;
    float newSide = MAX([image size].width, [image size].height);
    CGSize size =  CGSizeMake(newSide, newSide);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, newSide/2, newSide/2);
    CGContextRotateCTM(ctx, rads);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(-[image size].width/2,-[image size].height/2,size.width, size.height),image.CGImage);
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}
#pragma mark - TextView Delegates
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if(!isFirstTimeClicked) {
        _statusText.text = @"";
        isFirstTimeClicked = true;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        changeColorForTag = false;
        [textView resignFirstResponder];
        return NO;
    }
    else if ([text isEqualToString:@"#"]) {
        textView.typingAttributes = highlightAttrdict;
    }
    else{
        textView.typingAttributes = normalAttrdict;
    }
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(_statusText.text.length == 0){
        [_statusText resignFirstResponder];
    }
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    [self extractTags];
    
    [textView resignFirstResponder];
    
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}
-(void) extractTags{
    tagsString = @"";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:_statusText.text options:0 range:NSMakeRange(0,_statusText.text.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [_statusText.text substringWithRange:wordRange];
        tagsString = [tagsString stringByAppendingString:word];
        tagsString = [tagsString stringByAppendingString:@","];
    }
    if ([tagsString length] > 0)
        tagsString = [tagsString substringToIndex:[tagsString length] - 1];
}
#pragma  mark - custom keyboard

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    self.statusText.text = [self.statusText.text stringByAppendingString:emoji];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    
}

- (UIColor *)randomColor {
    return [UIColor colorWithRed:drand48()
                           green:drand48()
                            blue:drand48()
                           alpha:drand48()];
}

- (UIImage *)randomImage {
    CGSize size = CGSizeMake(30, 10);
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    
    fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGFloat xxx = 3;
    rect = CGRectMake(xxx, xxx, size.width - 2 * xxx, size.height - 2 * xxx);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [self randomImage];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

@end
