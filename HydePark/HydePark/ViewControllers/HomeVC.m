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
#import "UserChannel.h"
#import "CommentsVC.h"
#import "NewHomeCells.h"
#import "VideoPlayerVC.h"
#import "BeamUploadVC.h"
@interface HomeVC ()

@end

@implementation HomeVC

- (id)init
{
    if (IS_IPAD) {
        self = [super initWithNibName:@"HomeVC_iPad" bundle:Nil];
    }
    else if(IS_IPHONE_5){
        self = [super initWithNibName:@"HomeVC_iPhone5" bundle:Nil];
    }
    else{
        self = [super initWithNibName:@"HomeVC" bundle:Nil];
    }
    

    return self;
}
- (void) updateNotication:(NSNotification *) notification
{
    pageNum = 1;
    isDownwards = FALSE;
    if(![newsfeedsVideos count] == 0){
        [newsfeedsVideos removeAllObjects];
        [_TableHome reloadData];
    }
    [self getHomeContent];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isRecording = false;
    if(currentState == 0){
        if(!fromImagePicker){
            [self getMyChannel];
        }
        if(appDelegate.timeToupdateHome)
        {
            appDelegate.timeToupdateHome = FALSE;
            pageNum = 1;
            isDownwards = FALSE;
            [newsfeedsVideos removeAllObjects];
            [self getHomeContent];
        }
        else{
            [_TableHome reloadData];
        }
    }
    else if(currentState == 2){
        if(appDelegate.timeToupdateHome){
            appDelegate.timeToupdateHome = FALSE;
            forumPageNumber = 1;
            [forumsVideo removeAllObjects];
            [self getTrendingVideos];
        }
        else{
            [_forumTable reloadData];
        }
        if(!fromImagePicker){
            [self getMyChannel];
        }
    }
    else if(currentState == 3 && !fromImagePicker){
        [self getMyChannel];
    }
    isDownwards = false;
    fetchingContent = false;
    fetchingFroum = false;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.navigationController.navigationBarHidden = YES;
    searchField.attributedPlaceholder =
    [[NSAttributedString alloc]
     initWithString:@"Find other Corners"
     attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    searchField2.attributedPlaceholder =
    [[NSAttributedString alloc]
     initWithString:@"Find other Corners"
     attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    _searchTable.dataSource = self;
    _searchTable.delegate = self;
    fromImagePicker = FALSE;
    [_searchTable setBackgroundColor:BlueThemeColor(241,245,248)];
    [commentsTable setBackgroundColor:BlueThemeColor(241, 245, 248)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNotication:)
                                                 name:@"TestNotification"
                                               object:nil];
    //[_TableHome setBackgroundColor:BlueThemeColor(241,245,248)];
    //[_TablemyChannel setBackgroundColor:BlueThemeColor(241,245,248)];
    //[_forumTable setBackgroundColor:BlueThemeColor(241,245,248)];
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
    adsViewb = TRUE;
    [_progressview setProgress:0.0 animated:YES];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
    _progressview.transform = transform;
    totalBytesUploaded = 0.0;
    drawerBtn.contentEdgeInsets = UIEdgeInsetsMake(12, 12, 9 , 9);
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
    [_uploadbeamScroller setContentSize:CGSizeMake(_uploadbeamScroller.frame.size.width,600)];
    count = 10;

    [self setContentResolutions];
    TabBarFrame = _BottomBar.frame;
    channelContainerHeight = channelContainerView.frame.size.height;
    channelContainerOriginalFrame = channelContainerView.frame;
    channelTableFrame = _TablemyChannel.frame;
    
    [btnHome setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnChannel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnTrending setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    
    UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:sgr];
    
   
    mainScrollerFrame = _mainScroller.frame;
   // originalChannelFrame = _TablemyChannel.frame;
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
    [self setcontentForCeleb];

}
-(void) setcontentForCeleb{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"is_celeb"]){
        _adsBar.hidden = YES;
        btnBBC.enabled = NO;
        btnRedBull.enabled = NO;
        btnEmirates.enabled = NO;
        adsViewb = FALSE;
        _TablemyChannel.frame = CGRectMake(_TablemyChannel.frame.origin.x, _TablemyChannel.frame.origin.y - 50, _TablemyChannel.frame.size.width, _TablemyChannel.frame.size.height);
        originalChannelFrame = _TablemyChannel.frame;
        if(IS_IPHONE_6Plus)
        {
            _TablemyChannel.frame = CGRectMake(_TablemyChannel.frame.origin.x, _TablemyChannel.frame.origin.y - 10, _TablemyChannel.frame.size.width, _TablemyChannel.frame.size.height);
            originalChannelFrame = _TablemyChannel.frame;
            originalChannelFrame.origin.y += 40;
        }
    }
}
-(void)initWithDataArr{
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
    videoObj = [[NSMutableArray alloc] init];
    _forumTable.backgroundColor = [UIColor clearColor];
    _forumTable.opaque = NO;
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    [tempImageView setFrame:_forumTable.frame];
    _forumTable.backgroundView = tempImageView;
    _TableHome.backgroundColor = [UIColor clearColor];
    _TableHome.opaque = NO;
     UIImageView *tempImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    [tempImageView1 setFrame:_TableHome.frame];
    _TableHome.backgroundView = tempImageView1;
    _TablemyChannel.opaque = NO;
    _TablemyChannel.backgroundColor = [UIColor clearColor];
    countDownlabel.textAlignment = NSTextAlignmentCenter;
    _searchTable.opaque = NO;
    _searchTable.backgroundColor = [UIColor clearColor];

}
-(void)setContentResolutions{
    if (IS_IPHONE_4) {
        [_mainScroller setContentSize:CGSizeMake(960, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        _BottomBar.autoresizingMask = UIViewAutoresizingNone;
        _BottomBar.frame = CGRectMake(0, 433, 320, 47);
    }else if (IS_IPAD){
        _BottomBar.frame = CGRectMake(0, 870, 768, 154);
        _BottomBar.autoresizingMask = UIViewAutoresizingNone;
        [_mainScroller setContentSize:CGSizeMake(2304, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        originalChannelFrame.size.width = 768;
        originalChannelFrame.size.height = 568;
        originalChannelFrame.origin.y += 640;
        originalChannelInnerViewFrame = channgelInnerView.frame;
        originalChannelInnerViewFrame.origin.y -= 22.0f;
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
        countDownlabel.frame = CGRectMake(120,200,countDownlabel.frame.size.width,countDownlabel.frame.size.height);
        audioBtnImage.frame = CGRectMake(140, 250, audioBtnImage.frame.size.width, audioBtnImage.frame.size.height);
        _audioRecordBtn.frame = CGRectMake(140, 250, _audioRecordBtn.frame.size.width, _audioRecordBtn.frame.size.height);
        closeBtnAudio.frame = CGRectMake(330, 30, closeBtnAudio.frame.size.width, closeBtnAudio.frame.size.height);
        originalChannelInnerViewFrame = channgelInnerView.frame;
        originalChannelInnerViewFrame.origin.y -= 28.0f;
        
    }
    else if(IS_IPHONE_6Plus)
    {
        _BottomBar.autoresizingMask = UIViewAutoresizingNone;
        _BottomBar.frame = CGRectMake(0, 626, 414, 110);
        _optionsView.frame = CGRectMake(0, 0, 414, 736);
        [_forumTable setContentSize:CGSizeMake(414, _forumTable.frame.size.height)];
        searchView.frame = CGRectMake(0, 0, 414, 736);
        [_mainScroller setContentSize:CGSizeMake(1242, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        _uploadBeamView.frame = CGRectMake(0,0,414,736);
        channgelInnerView.frame = CGRectMake(channgelInnerView.frame.origin.x, channgelInnerView.frame.origin.y - 20, 414, channgelInnerView.frame.size.height);
        originalChannelInnerViewFrame = channgelInnerView.frame;
        originalChannelInnerViewFrame.origin.y -= 10.0f;
        _TablemyChannel.frame = CGRectMake(0, 360, 414, _TablemyChannel.frame.size.height);
        originalChannelFrame = _TablemyChannel.frame;
        originalChannelFrame.origin.y += 40.0f;
        channelContainerView.frame = CGRectMake(channelContainerView.frame.origin.x, channelContainerView.frame.origin.y , channelContainerView.frame.size.width, channelContainerView.frame.size.height );
        channelContainerOriginalFrame = channelContainerView.frame;
    }else if(IS_IPHONE_5)
    {
        _BottomBar.autoresizingMask = UIViewAutoresizingNone;
        _BottomBar.frame = CGRectMake(0, 468, 320, 100);
        [_mainScroller setContentSize:CGSizeMake(960, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        originalChannelInnerViewFrame = channgelInnerView.frame;
        originalChannelInnerViewFrame.origin.y -= 22.0f;
        originalChannelFrame.size.width = 320;
        originalChannelFrame.size.height = 568;
        originalChannelFrame.origin.y = 345;
        
    }
    adsFrame = _adsView.frame;
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
    fetchingFroum = true;
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
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            _ForumRefreshBtn.hidden = YES;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            fetchingFroum = false;
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
                         _Videos.Post_ID = [tempDict objectForKey:@"id"];
                        _Videos.Tags = [tempDict objectForKey:@"tag_friends"];
                        _Videos.video_length = [tempDict objectForKey:@"video_length"];
                        _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                        _Videos.reply_count = [tempDict objectForKey:@"reply_count"];
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
                            [indexPaths addObject:[NSIndexPath indexPathForRow:i/2 inSection:0]];
                        }
                    }
                    if(isDownwards) {
                        NSLog(@"numberOfRowsInSection: %ld", [_forumTable numberOfRowsInSection:0]);
                        [_forumTable beginUpdates];
                        [_forumTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_forumTable endUpdates];
                    }else{
                        [_forumTable reloadData];
                    }
                }
            }else
                cannotScrollForum = true;
        }
        else{
            fetchingFroum = false;
            _ForumRefreshBtn.hidden = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}
-(void) getFollowing{
    [FollowingsAM removeAllObjects];
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
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
                [_searchTable reloadData];
            }
        }
    }];
}
-(void) getFollowers{
    [FollowingsAM removeAllObjects];
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
                [_searchTable reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }
    }];
}

- (void) getHomeContent{
    fetchingContent = true;
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
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            _homeRefreshBtn.hidden = YES;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            fetchingContent = false;
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
                        _Videos.Post_ID = [tempDict objectForKey:@"id"];
                        _Videos.video_length = [tempDict objectForKey:@"video_length"];
                        _Videos.image_link = [tempDict objectForKey:@"image_link"];
                        _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                        _Videos.reply_count = [tempDict objectForKey:@"reply_count"];
                        
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
                    
                    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                    int startIndex = (pageNum-1) *10;
                    for (int i = startIndex ; i < startIndex+10; i++) {
                        if(i<newsfeedsVideos.count) {
                            [indexPaths addObject:[NSIndexPath indexPathForRow:i/2 inSection:0]];
                        }
                    }
                    if(isDownwards) {
                        [_TableHome beginUpdates];
                        [_TableHome insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_TableHome endUpdates];
                    }
                    else {
                        [_TableHome reloadData];
                    }
                }
            }
            else
            {
                cannotScroll = true;
            }
            if ([newsfeedsVideos count] == 0) {
                [noBeamsView setHidden:NO];
            }else{
                noBeamsView.hidden = YES;
            }
        }
        else{
            fetchingContent = false;
            _homeRefreshBtn.hidden = NO;
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
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            _ChannelRefreshBtn.hidden = YES;
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
                        _Videos.Post_ID = [tempDict objectForKey:@"id"];
                        _Videos.Tags = [tempDict objectForKey:@"tag_friends"];
                        _Videos.video_length = [tempDict objectForKey:@"video_length"];
                        _Videos.like_by_me = [tempDict objectForKey:@"liked_by_me"];
                        _Videos.image_link = [tempDict objectForKey:@"image_link"];
                        _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                        _Videos.reply_count = [tempDict objectForKey:@"reply_count"];
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
                _ChannelRefreshBtn.hidden = NO;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }];
}


#pragma mark - PulltoRefresh
- (IBAction)homeRefreshBtnPressed:(id)sender {
    pageNum = 1;
    [self getHomeContent];
    myCornerPageNum = 1;
    [self getMyChannel];
}

- (IBAction)ForumRefreshBtnPressed:(id)sender {
    forumPageNumber = 1;
    [self getTrendingVideos];
}
- (IBAction)ChannelRefreshBtnPressed:(id)sender {
    myCornerPageNum = 1;
    [self getMyChannel];
}
//- (void)setupRefreshControl
//{
//    
//    UITableViewController *tableViewController = [[UITableViewController alloc] init];
//    tableViewController.tableView = _forumTable;
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
//    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
//    tableViewController.refreshControl = self.refreshControl;
//}
//
//- (void)refresh:(id)sender
//{   forumPageNumber = 1;
//    [self getTrendingVideos];
//    
//}
//- (void)setupRefreshControlHome
//{
//    
//    UITableViewController *tableViewController = [[UITableViewController alloc] init];
//    tableViewController.tableView = _TableHome;
//    self.refreshControlHome = [[UIRefreshControl alloc] init];
//    _refreshControlHome.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
//    [self.refreshControlHome addTarget:self action:@selector(refreshHome:) forControlEvents:UIControlEventValueChanged];
//    tableViewController.refreshControl = self.refreshControlHome;
//}
//
//- (void)refreshHome:(id)sender
//{
//    //[newsfeedsVideos removeAllObjects];
//    [_TableHome reloadData];
//    pageNum = 1;
//    [self getHomeContent];
//    
//}
//- (void)setupRefreshControlChannel
//{
//    
//    UITableViewController *tableViewController = [[UITableViewController alloc] init];
//    tableViewController.tableView = _TablemyChannel;
//    self.refreshControlChannel = [[UIRefreshControl alloc] init];
//    _refreshControlChannel.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
//    [self.refreshControlChannel addTarget:self action:@selector(refreshChannel:) forControlEvents:UIControlEventValueChanged];
//    tableViewController.refreshControl = self.refreshControlChannel;
//}
//
//- (void)refreshChannel:(id)sender
//{
//    if(tabBarIsShown)
//        [self getMyChannel];
//    
//}

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
                    if(currentState == 2){
                        GetTrendingVideos *_Videos = [[GetTrendingVideos alloc] init];
                        _Videos = [forumsVideo  objectAtIndex:indexToLike];
                        _Videos.like_count = [[forumsVideo objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        likeCount++;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"1";
                        [forumsVideo replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [_forumTable beginUpdates];
                        [_forumTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_forumTable endUpdates];
                    }
                    else if (currentState == 0)
                    {
                        GetTrendingVideos *_Videos = [[GetTrendingVideos alloc] init];
                        _Videos = [newsfeedsVideos objectAtIndex:indexToLike];
                        _Videos.like_count = [[newsfeedsVideos  objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        likeCount++;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"1";
                        [newsfeedsVideos replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [_TableHome beginUpdates];
                        [_TableHome reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_TableHome endUpdates];
                    }
                    else if (currentState == 3)
                    {
                        myChannelModel *_Videos = [[myChannelModel alloc]init];
                        _Videos = [channelVideos  objectAtIndex:indexToLike];
                        _Videos.like_count = [[channelVideos objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        likeCount++;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"1";
                        [channelVideos replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [_TablemyChannel beginUpdates];
                        [_TablemyChannel reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_TablemyChannel endUpdates];
                    }
                }else if ([message isEqualToString:@"Post is Successfully unliked by this user."])
                {
                    liked = NO;
                    if(currentState == 2){
                        GetTrendingVideos *_Videos = [[GetTrendingVideos alloc] init];
                        _Videos = [forumsVideo  objectAtIndex:indexToLike];
                        _Videos.like_count = [[forumsVideo objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        if(likeCount > 0)
                            likeCount--;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"0";
                        [forumsVideo replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [_forumTable beginUpdates];
                        [_forumTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_forumTable endUpdates];
                    }
                    else if (currentState == 0)
                    {
                        GetTrendingVideos *_Videos = [[GetTrendingVideos alloc] init];
                        _Videos = [newsfeedsVideos objectAtIndex:indexToLike];
                        _Videos.like_count = [[newsfeedsVideos  objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        if(likeCount > 0)
                            likeCount--;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"0";
                        [newsfeedsVideos replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [_TableHome beginUpdates];
                        [_TableHome reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_TableHome endUpdates];
                    }
                    else if (currentState == 3)
                    {
                        myChannelModel *_Videos = [[myChannelModel alloc]init];
                        _Videos = [channelVideos  objectAtIndex:indexToLike];
                        _Videos.like_count = [[channelVideos objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        if(likeCount > 0)
                            likeCount--;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"0";
                        [channelVideos replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [_TablemyChannel beginUpdates];
                        [_TablemyChannel reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_TablemyChannel endUpdates];
                    }
                }
            }
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
    NSLog(@"%@",postID);
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
        //        if(appDelegate.IS_celeb && indexPath.row == 0) {
        //            if (IS_IPAD)
        //                returnValue = 200.0f;
        //            else
        //                returnValue = 112;
        //        }
        //        else {
        if (IS_IPAD)
            returnValue = 362.0f;
        else if(IS_IPHONE_5)
            returnValue = 150.0f;
        else
            returnValue = 180.0f;
        //}
        
    }
    else {
        if (IsStatus== YES) {
            if (IS_IPAD)
                returnValue = 350.0f;
            else
                returnValue = 180.0f;
        }
        else {
            if (IS_IPAD)
                returnValue = 362.0f;
            else
                returnValue = 180.0f;
        }
    }
    if(tableView.tag == 10) {
        
        if (IS_IPAD)
            returnValue = 362.0f;
        else if(IS_IPHONE_5)
            returnValue = 150.0f;
        else
            returnValue = 180.0f;
    }
    
    if(tableView.tag == 3) {
        
        if (IS_IPAD)
            returnValue = 362.0f;
        else if(IS_IPHONE_5)
            returnValue = 150.0f;
        else
            returnValue = 180.0f;
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
        int rows = (int)([newsfeedsVideos count]/2);
        if([newsfeedsVideos count] %2 == 1) {
            rows++;
        }
        return rows;
        
    }else if (tableView.tag == 3 && forumsVideo != nil){
        int rows = (int)([forumsVideo count]/2);
        if([forumsVideo count] %2 == 1) {
            rows++;
        }
        return rows;
    }else if (tableView.tag == 2){
        int rows = (int)([channelVideos count]/2);
        if([channelVideos count] %2 == 1) {
            rows++;
        }
        return rows;
//        if(appDelegate.IS_celeb) {
//            value = value+1;
//        }
        //value = value ;
    }else if (tableView.tag == 20){
            value = FollowingsAM.count;
    }else if (tableView.tag == 25){
        
        value = chPostArray.count;
    }else if (tableView.tag == 30){
        
        value = CommentsArray.count;
    }
    return value;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 10) {
        //ChannelCell *cell;
        NewHomeCells *cell;
        IsStatus = NO;
        currentIndexHome = (indexPath.row * 2);
        if (IS_IPAD) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewHomeCells_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else if(IS_IPHONE_5){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewHome_iPhone5" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewHomeCells" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        if(IS_IPHONE_6Plus){
            cell.leftreplImg.frame = CGRectMake(cell.leftreplImg.frame.origin.x + 15, cell.leftreplImg.frame.origin.y, cell.leftreplImg.frame.size.width, cell.leftreplImg.frame.size.width);
            cell.CH_CommentscountLbl.frame = CGRectMake(cell.CH_CommentscountLbl.frame.origin.x + 15, cell.CH_CommentscountLbl.frame.origin.y, cell.CH_CommentscountLbl.frame.size.width , cell.CH_CommentscountLbl.frame.size.height);
        }
        NSInteger valueToInc = 50;
        if(pageNum > 1)
             valueToInc = pageNum * 100;
        _TableHome.contentSize = CGSizeMake(_TableHome.frame.size.width,newsfeedsVideos.count/2 * returnValue +_BottomBar.frame.size.height );
        
        GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
        tempVideos  = [newsfeedsVideos objectAtIndex:currentIndexHome];
        cell.CH_userName.text = tempVideos.userName; 
        cell.Ch_videoLength.text = tempVideos.video_length;
        cell.CH_VideoTitle.text = tempVideos.title;
        if([tempVideos.comments_count isEqualToString:@"0"])
        {
            cell.CH_CommentscountLbl.hidden = YES;
            cell.leftreplImg.hidden = YES;
        }
        else{
            cell.CH_CommentscountLbl.text = tempVideos.comments_count;
        }
        cell.CH_heartCountlbl.text = tempVideos.like_count;
        cell.CH_seen.text = tempVideos.seen_count;
        //tempVideos.video_link = [newsfeedVideosArray objectAtIndex:indexPath.row];
        cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
        if([tempVideos.is_anonymous  isEqualToString: @"0"]){
  
        }
        else{
            //cell.CH_Video_Thumbnail.image = [UIImage imageNamed:@"anonymousDp.png"];
            cell.CH_userName.text = @"Anonymous";
            cell.userProfileView.enabled = false;
        }
        cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
        if(IS_IPAD)
            cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /7.4f;
        cell.imgContainer.layer.masksToBounds = YES;
        [cell.CH_Video_Thumbnail roundCorners];
 
        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:sgr];
        [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        //appDelegate.videotoPlay = [getTrendingVideos.mainhomeArray objectAtIndex:indexPath.row];
        [cell.userProfileView addTarget:self action:@selector(MovetoUserProfile:) forControlEvents:UIControlEventTouchUpInside];
        cell.userProfileView.tag = currentIndexHome;
        [cell.CH_heart setTag:currentIndexHome];
        [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        
        [cell.CH_flag addTarget:self action:@selector(Flag:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_playVideo setTag:currentIndexHome];
        
        [cell.CH_flag setTag:currentIndexHome];
        cell.CH_commentsBtn.enabled = YES;
         cell.CH_RcommentsBtn.enabled = YES;
        [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_commentsBtn setTag:currentIndexHome];

        currentIndexHome++;
        if(currentIndexHome < newsfeedsVideos.count)
        {
            GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
            tempVideos  = [newsfeedsVideos objectAtIndex:currentIndexHome];
            [cell.CH_RcommentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.CH_RcommentsBtn setTag:currentIndexHome];
            [cell.CH_RplayVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            [cell.CH_RplayVideo setTag:currentIndexHome];
            [cell.CH_Rheart setTag:currentIndexHome];
            [cell.CH_Rheart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
            cell.CH_RVideoTitle.text = tempVideos.title;
            cell.CH_Rseen.text = tempVideos.seen_count;
            cell.RimgContainer.layer.cornerRadius  = cell.RimgContainer.frame.size.width /6.2f;
            if(IS_IPAD)
                cell.RimgContainer.layer.cornerRadius  = cell.RimgContainer.frame.size.width /7.4f;
            cell.RimgContainer.layer.masksToBounds = YES;
            [cell.CH_RVideo_Thumbnail roundCorners];
            cell.CH_RheartCountlbl.text             = tempVideos.like_count;
            if([tempVideos.comments_count isEqualToString:@"0"])
            {
                cell.CH_RCommentscountLbl.hidden = YES;
                cell.rightreplImg.hidden = YES;
            }
            else{
                 cell.CH_RCommentscountLbl.text = tempVideos.comments_count;
            }
            cell.CH_RuserName.text = tempVideos.userName;
            cell.CH_RVideo_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
            NSURL *url = [NSURL URLWithString:tempVideos.video_thumbnail_link];
            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
            if([tempVideos.is_anonymous  isEqualToString: @"0"]){
           
            }
            else{
                //cell.CH_RVideo_Thumbnail.image =[UIImage imageNamed:@"anonymousDp.png"];
                cell.CH_RuserName.text = @"Anonymous";
            }
            if ([tempVideos.like_by_me isEqualToString:@"1"]) {
                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
            }else{
                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
            }
            currentIndexHome++;
        }
        else{
            cell.CH_RprofileImage.hidden = YES;
            cell.CH_Rseen.hidden = YES;
            cell.CH_RcommentsBtn.hidden = YES;
            cell.CH_RuserName.hidden = YES;
            cell.CH_Rheart.hidden = YES;
            cell.RimgContainer.hidden = YES;
            cell.CH_RplayVideo.hidden = YES;
            cell.Rtransthumb.hidden = YES;
            cell.CH_RVideoTitle.hidden = YES;
            cell.rightreplImg.hidden = YES;
            cell.CH_RCommentscountLbl.hidden = YES;
            cell.playImage.hidden = YES;
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if(tableView.tag == 3){
        
        //ChannelCell *cell;
        NewHomeCells *cell;
        IsStatus = NO;
        currentIndex = (indexPath.row * 2);
        if (IS_IPAD) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewHomeCells_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else if(IS_IPHONE_5){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewHome_iPhone5" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewHomeCells" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        if(IS_IPHONE_6Plus){
            cell.leftreplImg.frame = CGRectMake(cell.leftreplImg.frame.origin.x + 15, cell.leftreplImg.frame.origin.y, cell.leftreplImg.frame.size.width, cell.leftreplImg.frame.size.width);
            cell.CH_CommentscountLbl.frame = CGRectMake(cell.CH_CommentscountLbl.frame.origin.x + 15, cell.CH_CommentscountLbl.frame.origin.y, cell.CH_CommentscountLbl.frame.size.width , cell.CH_CommentscountLbl.frame.size.height);
        }
        NSInteger valueToInc = 50;
        if(forumPageNumber > 1)
            valueToInc = forumPageNumber * 100;
        _forumTable.contentSize = CGSizeMake(_forumTable.frame.size.width,forumsVideo.count/2 * returnValue + _BottomBar.frame.size.height );
        
        GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
        tempVideos  = [forumsVideo objectAtIndex:currentIndex];
        cell.CH_userName.text = tempVideos.userName;
        cell.Ch_videoLength.text = tempVideos.video_length;
        cell.CH_VideoTitle.text = tempVideos.title;
        if([tempVideos.comments_count isEqualToString:@"0"])
        {
            cell.CH_CommentscountLbl.hidden = YES;
            cell.leftreplImg.hidden = YES;
        }
        else{
            cell.CH_CommentscountLbl.text = tempVideos.comments_count;
        }
        cell.CH_heartCountlbl.text = tempVideos.like_count;
        cell.CH_seen.text = tempVideos.seen_count;
        //tempVideos.video_link = [videosArray objectAtIndex:indexPath.row];
        cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
        if([tempVideos.is_anonymous  isEqualToString: @"0"]){
         
        }
        else{
           // cell.CH_Video_Thumbnail.image =[UIImage imageNamed:@"anonymousDp.png"];
            cell.CH_userName.text = @"Anonymous";
            cell.userProfileView.enabled = false;
        }
     
        [cell.userProfileView addTarget:self action:@selector(MovetoUserProfile:) forControlEvents:UIControlEventTouchUpInside];
        cell.userProfileView.tag = indexPath.row;
        cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
        if(IS_IPAD)
            cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /7.4f;
        cell.imgContainer.layer.masksToBounds = YES;
        [cell.CH_Video_Thumbnail roundCorners];
        cell.CH_commentsBtn.enabled = YES;
        cell.CH_RcommentsBtn.enabled = YES;
        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:sgr];
        [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_heart setTag:currentIndex];
        [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        
      
        [cell.CH_flag addTarget:self action:@selector(Flag:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_playVideo setTag:currentIndex];
        
        [cell.CH_flag setTag:currentIndex];
        [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_commentsBtn setTag:currentIndex];
        currentIndex++;
        if(currentIndex < forumsVideo.count)
        {
            GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
            tempVideos  = [forumsVideo objectAtIndex:currentIndex];
            [cell.CH_RcommentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.CH_RcommentsBtn setTag:currentIndex];
            [cell.CH_RplayVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            [cell.CH_RplayVideo setTag:currentIndex];
            [cell.CH_Rheart setTag:currentIndex];
            [cell.CH_Rheart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
            cell.CH_RVideoTitle.text = tempVideos.title;
            cell.CH_Rseen.text = tempVideos.seen_count;
            cell.RimgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
            if(IS_IPAD)
                cell.RimgContainer.layer.cornerRadius  = cell.RimgContainer.frame.size.width /7.4f;
            cell.RimgContainer.layer.masksToBounds = YES;
            [cell.CH_RVideo_Thumbnail roundCorners];;

            cell.CH_RheartCountlbl.text             = tempVideos.like_count;
            if([tempVideos.comments_count isEqualToString:@"0"])
            {
                cell.CH_RCommentscountLbl.hidden = YES;
                cell.rightreplImg.hidden = YES;
            }
            else{
                cell.CH_RCommentscountLbl.text = tempVideos.comments_count;
            }
            cell.CH_RuserName.text = tempVideos.userName;
            cell.CH_RVideo_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
            NSURL *url = [NSURL URLWithString:tempVideos.video_thumbnail_link];
            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
            if([tempVideos.is_anonymous  isEqualToString: @"0"]){

            }
            else{
                //cell.CH_RVideo_Thumbnail.image =[UIImage imageNamed:@"anonymousDp.png"];
                cell.CH_RuserName.text = @"Anonymous";
            }
            if ([tempVideos.like_by_me isEqualToString:@"1"]) {
                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
            }else{
                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
            }
            currentIndex++;
        }
        else{
            cell.CH_RprofileImage.hidden = YES;
            cell.CH_Rseen.hidden = YES;
            cell.CH_RcommentsBtn.hidden = YES;
            cell.CH_RuserName.hidden = YES;
            cell.CH_Rheart.hidden = YES;
            cell.RimgContainer.hidden = YES;
            cell.CH_RplayVideo.hidden = YES;
            cell.Rtransthumb.hidden = YES;
            cell.CH_RVideoTitle.hidden = YES;
            cell.rightreplImg.hidden = YES;
            cell.CH_RCommentscountLbl.hidden = YES;
            cell.playImage.hidden = YES;
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    if (tableView.tag == 2 ) {
        
//        if(indexPath.row == 0 && appDelegate.IS_celeb) {
//            AdvertismentCell *cell;
//            IsStatus = NO;
//            if (IS_IPAD) {
//                
//                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AdvertismentCell_iPad" owner:self options:nil];
//                cell = [nib objectAtIndex:0];
//            }
//            else{
//                
//                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AdvertismentCell" owner:self options:nil];
//                cell = [nib objectAtIndex:0];
//            }
//            [cell setBackgroundColor:BlueThemeColor(241, 245, 248)];
//            cell.selectionStyle = UITableViewCellSeparatorStyleNone;
//            return cell;
//        }
//        else {
        NewHomeCells *cell;
        IsStatus = NO;
        currentChanelIndex = (indexPath.row * 2);
        if (IS_IPAD) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewHomeCells_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else if(IS_IPHONE_5){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewHome_iPhone5" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewHomeCells" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        if(IS_IPHONE_6Plus){
            cell.leftreplImg.frame = CGRectMake(cell.leftreplImg.frame.origin.x + 15, cell.leftreplImg.frame.origin.y, cell.leftreplImg.frame.size.width, cell.leftreplImg.frame.size.width);
            cell.CH_CommentscountLbl.frame = CGRectMake(cell.CH_CommentscountLbl.frame.origin.x + 15, cell.CH_CommentscountLbl.frame.origin.y, cell.CH_CommentscountLbl.frame.size.width , cell.CH_CommentscountLbl.frame.size.height);
        }
        _TablemyChannel.contentSize = CGSizeMake(_TablemyChannel.frame.size.width,chPostArray.count/2 * returnValue + _BottomBar.frame.size.height + 150);
        myChannelModel *tempVideos = [[myChannelModel alloc]init];
        //            if(appDelegate.IS_celeb) {
        //                tempVideos  = [channelVideos objectAtIndex:indexPath.row-1];
        //            }
        //            else {
        tempVideos  = [channelVideos objectAtIndex:currentChanelIndex];
        //}
        
        cell.CH_userName.text = tempVideos.userName;
        cell.CH_VideoTitle.text = tempVideos.title;
        if([tempVideos.comments_count isEqualToString:@"0"])
        {
            cell.CH_CommentscountLbl.hidden = YES;
            cell.leftreplImg.hidden = YES;
        }
        else{
            cell.CH_CommentscountLbl.text = tempVideos.comments_count;
        }
        cell.CH_heartCountlbl.text = tempVideos.like_count;
        cell.CH_seen.text = tempVideos.seen_count;
        cell.Ch_videoLength.text = tempVideos.video_length;
        
        NSURL *url1;
        cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
        cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
        if(IS_IPAD)
            cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /7.4f;
        cell.imgContainer.layer.masksToBounds = YES;
        [cell.CH_Video_Thumbnail roundCorners];
        cell.CH_commentsBtn.enabled = YES;
        cell.CH_RcommentsBtn.enabled = YES;
        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:sgr];
        
        [cell.CH_heart setTag:currentChanelIndex];
        [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.CH_flag addTarget:self action:@selector(editPost:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_playVideo setTag:currentChanelIndex];
        
        [cell.CH_flag setTag:currentChanelIndex];
        [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_commentsBtn setTag:currentChanelIndex];
        
        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        currentChanelIndex++;
        if(currentChanelIndex < channelVideos.count)
        {
            myChannelModel *tempVideos = [[myChannelModel alloc]init];
            tempVideos  = [channelVideos objectAtIndex:currentChanelIndex];
            [cell.CH_RcommentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.CH_RcommentsBtn setTag:currentChanelIndex];
            [cell.CH_RplayVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            [cell.CH_RplayVideo setTag:currentChanelIndex];
            [cell.CH_Rheart setTag:currentChanelIndex];
            [cell.CH_Rheart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
            cell.CH_RVideoTitle.text = tempVideos.title;
            cell.CH_Rseen.text = tempVideos.seen_count;
            cell.RimgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
            if(IS_IPAD)
                cell.RimgContainer.layer.cornerRadius  = cell.RimgContainer.frame.size.width /7.4f;
            cell.RimgContainer.layer.masksToBounds = YES;
            
            
            cell.CH_RheartCountlbl.text             = tempVideos.like_count;
            if([tempVideos.comments_count isEqualToString:@"0"])
            {
                cell.CH_RCommentscountLbl.hidden = YES;
                cell.rightreplImg.hidden = YES;
            }
            else{
                cell.CH_RCommentscountLbl.text = tempVideos.comments_count;
            }
            cell.CH_RuserName.text = tempVideos.userName;
            cell.CH_RVideo_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
            NSURL *url = [NSURL URLWithString:tempVideos.video_thumbnail_link];
            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
            [cell.CH_RVideo_Thumbnail roundCorners];
            if ([tempVideos.like_by_me isEqualToString:@"1"]) {
                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
            }else{
                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
            }
            currentChanelIndex++;
        }else{
            cell.CH_RprofileImage.hidden = YES;
            cell.CH_Rseen.hidden = YES;
            cell.CH_RcommentsBtn.hidden = YES;
            cell.CH_RuserName.hidden = YES;
            cell.CH_Rheart.hidden = YES;
            cell.RimgContainer.hidden = YES;
            cell.CH_RplayVideo.hidden = YES;
            cell.Rtransthumb.hidden = YES;
            cell.CH_RVideoTitle.hidden = YES;
            cell.rightreplImg.hidden = YES;
            cell.CH_RCommentscountLbl.hidden = YES;
            cell.playImage.hidden = YES;
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        // }
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
//        if(!searchcorners){
            Followings *tempUsers = [[Followings alloc]init];
            tempUsers = [FollowingsAM objectAtIndex:indexPath.row];
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
            
            [cell.statusImage addTarget:self action:@selector(statusPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.statusImage setTag:indexPath.row];
            cell.statusImage.hidden = false;
            cell.activityInd.hidden = true;
            [cell.activityInd stopAnimating];
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
            [cell.friendsChannelBtn addTarget:self action:@selector(OpenFriendsChannelPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.friendsChannelBtn setTag:indexPath.row];
            
//            if (SearchforTag == YES) {
//                cell.tagbtn.hidden = NO;
//                cell.statusImage.hidden = YES;
//                
//            }else{
//                cell.tagbtn.hidden = YES;
//                cell.statusImage.hidden = NO;
//            }
            [cell.tagbtn addTarget:self action:@selector(TagFriend:) forControlEvents:UIControlEventTouchUpInside];
            [cell.tagbtn setTag:indexPath.row];
            [cell setBackgroundColor:[UIColor clearColor]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        //}
//        else {
//            PopularUsersModel *tempUsers = [[PopularUsersModel alloc] init];
//            tempUsers =  [UsersModel.PopUsersArray objectAtIndex:indexPath.row];
//            cell.friendsName.text = tempUsers.full_name;
//            
//            cell.profilePic.imageURL = [NSURL URLWithString:tempUsers.profile_link];
//            NSURL *url = [NSURL URLWithString:tempUsers.profile_link];
//            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
//            [cell.profilePic roundImageCorner];
//            
//            [cell.statusImage addTarget:self action:@selector(statusPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.statusImage setTag:indexPath.row];
//            cell.statusImage.hidden = false;
//            cell.activityInd.hidden = true;
//            [cell.activityInd stopAnimating];
//            if ([tempUsers.status isEqualToString:@"ADD_FRIEND"]) {
//                
//                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
//            }else if ([tempUsers.status isEqualToString:@"FRIEND"]){
//                
//                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
//            }
//            
//            if ([tempUsers.status isEqualToString:@"PENDING"]) {
//                cell.statusImage.hidden = true;
//                cell.activityInd.hidden = false;
//                [cell.activityInd startAnimating];
//            }
//            [cell.friendsChannelBtn addTarget:self action:@selector(OpenFriendsChannelPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.friendsChannelBtn setTag:indexPath.row];
//            [cell setBackgroundColor:[UIColor clearColor]];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//            
//        }
//        else{
//            
//            Followings *tempUsers = [[Followings alloc]init];
//            tempUsers = [FollowingsAM objectAtIndex:indexPath.row];
//            cell.friendsName.text = tempUsers.fullName;
//            
//            cell.profilePic.imageURL = [NSURL URLWithString:tempUsers.profile_link];
//            NSURL *url = [NSURL URLWithString:tempUsers.profile_link];
//            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
//            [cell.profilePic roundImageCorner];
//            
//            [cell.statusImage addTarget:self action:@selector(statusPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.statusImage setTag:indexPath.row];
//            cell.statusImage.hidden = false;
//            cell.activityInd.hidden = true;
//            [cell.activityInd stopAnimating];
//            if ([tempUsers.status isEqualToString:@"ADD_FRIEND"]) {
//                
//                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
//            }else if ([tempUsers.status isEqualToString:@"FRIEND"]){
//                
//                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
//            }
//            
//            if ([tempUsers.status isEqualToString:@"PENDING"]) {
//                cell.statusImage.hidden = true;
//                cell.activityInd.hidden = false;
//                [cell.activityInd startAnimating];
//            }
//            [cell.friendsChannelBtn addTarget:self action:@selector(OpenFriendsChannelPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.friendsChannelBtn setTag:indexPath.row];
//            [cell setBackgroundColor:[UIColor clearColor]];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//        }
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
            [btnHome setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnChannel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btnTrending setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            currentState = 0;
            tabLineHome.hidden      = false;
            tabLineChannel.hidden   = true;
            tabLineTrending.hidden  = true;
        }
        else if (page == 1) {
            [self ShowBottomBar];
            [btnChannel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnHome setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btnTrending setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            currentState = 3;
            tabLineHome.hidden      = true;
            tabLineChannel.hidden   = false;
            tabLineTrending.hidden  = true;
        }
        else {
            currentState = 2;
            [btnTrending setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnChannel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btnHome setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            tabLineHome.hidden      = true;
            tabLineChannel.hidden   = true;
            tabLineTrending.hidden  = false;
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
            CGRect changedFrame = CGRectMake(0, 86, originalChannelFrame.size.width, 600);
            
            if (IS_IPAD) {
                changedFrame = CGRectMake(0, 100, originalChannelFrame.size.width, 1024);
            }
            else if(IS_IPHONE_6Plus)
                changedFrame = CGRectMake(0, 100, 414, 700);
            CGRect changedFrameForInner = CGRectMake(0,-40, originalChannelFrame.size.width, 0);
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
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGPoint targetPoint = *targetContentOffset;
    CGPoint currentPoint = scrollView.contentOffset;
    
    if (targetPoint.y > currentPoint.y) {
        isDownwards = false;
    }
    else {
        isDownwards = true;
        return;
    }
    isDownwards = false;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if(isDownwards) {
        if (scrollView.tag == 10){
            NSArray *visibleRows = [_TableHome visibleCells];
            UITableViewCell *lastVisibleCell = [visibleRows lastObject];
            NSIndexPath *path = [_TableHome indexPathForCell:lastVisibleCell];
            if(path.section == 0 && path.row == newsfeedsVideos.count/2 - 1)
            {
                if(!cannotScroll && !fetchingContent) {
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
            if(path.section == 0 && path.row == forumsVideo.count/2 - 1)
            {
                if(!cannotScrollForum && !fetchingFroum) {
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
        _BottomBar.center = CGPointMake(0, 1500);
    }];
}
-(void)ShowBottomBar{
    
    [UIView animateWithDuration:0.5 animations:^{
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
    
    if(currentState == 3) {
        [videoObj removeAllObjects];
         myChannelModel *modelss = [channelVideos objectAtIndex:currentSelectedIndex];
         postID = modelss.Post_ID;
        for(int i = 0; i < channelVideos.count ; i++){
            myChannelModel *models = [channelVideos objectAtIndex:i];
            VideoModel *temp = [[VideoModel alloc] init];
            temp.is_anonymous           = models.is_anonymous;
            temp.title                  = models.title;
            temp.comments_count         = models.comments_count;
            temp.userName               = models.userName;
            temp.topic_id               = models.topic_id;
            temp.user_id                = models.user_id;
            temp.profile_image          = models.profile_image;
            temp.video_link             = models.video_link;
            temp.video_thumbnail_link   = models.video_thumbnail_link;
            temp.image_link             = models.image_link;
            temp.videoID                = models.VideoID;
            temp.video_length           = models.video_length;
            temp.like_count             = models.like_count;
            temp.like_by_me             = models.like_by_me;
            temp.seen_count             = models.seen_count;
            temp.reply_count            = models.reply_count;
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
    else if (currentState == 2) {
        [videoObj removeAllObjects];
         GetTrendingVideos *modelss = [forumsVideo objectAtIndex:currentSelectedIndex];
        postID = modelss.Post_ID;
        for(int i = 0; i < forumsVideo.count ; i++){
            GetTrendingVideos *model = [forumsVideo objectAtIndex:i];
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
            temp.image_link             = model.image_link;
            temp.videoID                = model.VideoID;
            temp.video_length           = model.video_length;
            temp.like_count             = model.like_count;
            temp.like_by_me             = model.like_by_me;
            temp.seen_count             = model.seen_count;
            temp.reply_count            = model.reply_count;
            [videoObj addObject:temp];
        }
        VideoPlayerVC *videoPlayer;
        if(IS_IPAD)
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPad" bundle:nil];
        else if(IS_IPHONE_6Plus)
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPhonePlus" bundle:nil];
        else
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
        videoPlayer.videoObjs = videoObj;
        videoPlayer.indexToDisplay = currentSelectedIndex;
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
    else if(currentState == 0){
        [videoObj removeAllObjects];
        GetTrendingVideos *modelss = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
        postID = modelss.Post_ID;
        for(int i = 0; i < newsfeedsVideos.count ; i++){
            GetTrendingVideos *model = [newsfeedsVideos objectAtIndex:i];
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
            temp.image_link             = model.image_link;
            temp.videoID                = model.VideoID;
            temp.video_length           = model.video_length;
            temp.like_count             = model.like_count;
            temp.like_by_me             = model.like_by_me;
            temp.seen_count             = model.seen_count;
            temp.reply_count            = model.reply_count;
            [videoObj addObject:temp];
        }
        
        VideoPlayerVC *videoPlayer;
        if(IS_IPAD)
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPad" bundle:nil];
        else if(IS_IPHONE_6Plus)
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPhonePlus" bundle:nil];
        else
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
        videoPlayer.videoObjs = videoObj;
        videoPlayer.indexToDisplay = currentSelectedIndex;
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
    if(currentState == 0){
        tempVideos  = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
        postID = tempVideos.VideoID;
    }
    else if(currentState == 2)
    {
        tempVideos =  [forumsVideo objectAtIndex:currentSelectedIndex];
        postID = tempVideos.VideoID;
    }
    else if(currentState == 3)
    {
        _profile = [channelVideos objectAtIndex:currentSelectedIndex];
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
    UIButton *senderBtn = sender;
    senderBtn.enabled = false;
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
        chantempVideos  = [channelVideos objectAtIndex:currentSelectedIndex];
        
    }
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
        videomodel.comments_count = tempVideos.comments_count;
        postID = tempVideos.VideoID;
        videomodel.reply_count  = tempVideos.reply_count;
        videomodel.user_id      = tempVideos.user_id;
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
        postID = chantempVideos.VideoID;
        videomodel.comments_count = chantempVideos.comments_count;
        videomodel.reply_count    = chantempVideos.reply_count;
        videomodel.user_id      =   chantempVideos.user_id;
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
-(void)getCommentsToPlay{
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
               
                
                for(NSDictionary *tempDict in CommentsArray){
                    VideoModel *_comment = [[VideoModel alloc] init];
                    _comment.title = [tempDict objectForKey:@"caption"];
                    _comment.comments_count = [tempDict objectForKey:@"comment_count"];
                    _comment.userName = [tempDict objectForKey:@"full_name"];
                    _comment.topic_id = [tempDict objectForKey:@"topic_id"];
                    _comment.user_id = [tempDict objectForKey:@"user_id"];
                    _comment.profile_image = [tempDict objectForKey:@"profile_link"];
                    _comment.video_link = [tempDict objectForKey:@"video_link"];
                    _comment.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                    _comment.image_link = [tempDict objectForKey:@"image_link"];
                    _comment.videoID = [tempDict objectForKey:@"id"];
                    _comment.video_length = [tempDict objectForKey:@"video_length"];
                    _comment.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                    [videoObj addObject:_comment];
                }
                VideoPlayerVC *videoPlayer;
                if(IS_IPAD)
                    videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPad" bundle:nil];
                else if(IS_IPHONE_6Plus)
                    videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPhonePlus" bundle:nil];
                else
                    videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
                videoPlayer.videoObjs = videoObj;
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

//                VideoPlayerVC *videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
//                videoPlayer.videoObjs = videoObj;
//                [[self navigationController] pushViewController:videoPlayer animated:YES];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
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
                    _comment.seen_count = [tempDict objectForKey:@"seen_count"];
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
                    _comment.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                    _comment.reply_count  = [tempDict objectForKey:@"reply_count"];
                    [CommentsModelObj.ImagesArray addObject:_comment.profile_link];
                    [CommentsModelObj.ThumbnailsArray addObject:_comment.video_thumbnail_link];
                    [CommentsModelObj.mainArray addObject:_comment.video_link];
                    [CommentsModelObj.CommentsArray addObject:_comment];
                    
                    CommentsArray = CommentsModelObj.CommentsArray;
                    chVideosArray = CommentsModelObj.mainArray;
                    chArrImage = CommentsModelObj.ImagesArray;
                    chArrThumbnail = CommentsModelObj.ThumbnailsArray;
                    
                }
                CommentsVC *commentController ;
                if(IS_IPAD)
                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC_iPad" bundle:nil];
                else
                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
                
                commentController.commentsObj   = CommentsModelObj;
                commentController.postArray     = videomodel;
                commentController.cPostId       = postID;
                commentController.isFirstComment = TRUE;
                commentController.isComment     = FALSE;
                [[self navigationController] pushViewController:commentController animated:YES];
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
    Followings *_responseData = [[Followings alloc] init];
    _responseData  = [FollowingsAM objectAtIndex:currentSelectedIndex];
    friendId = _responseData.f_id;
    UserRelation = _responseData.status;
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
-(IBAction)openBBC:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bbc.com"]];
}
-(IBAction)openEmirates:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.emirates.com"]];
}
-(IBAction)openREDBull:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.redbull.com/en"]];
}
-(IBAction)MoveToSearchView:(id)sender{
    [FollowingsAM removeAllObjects];
    [_searchTable reloadData];
    [searchField2 becomeFirstResponder];
    [self.view addSubview:searchView];
}
- (IBAction)showFollowings:(id)sender {
    loadFollowings = true;
    searchcorners = false;
    [FollowingsAM removeAllObjects];
    [_searchTable reloadData];
    [self getFollowing];
    nousersFound.hidden = YES;
    [self.view addSubview:searchView];
    
}

- (IBAction)showFollowers:(id)sender {
    loadFollowings = false;
    searchcorners = false;
    [FollowingsAM removeAllObjects];
    [_searchTable reloadData];
    [self getFollowers];
    nousersFound.hidden = YES;
    [self.view addSubview:searchView];
}
-(void) GetFollowersCall{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:@"User_Id"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"getFollowersFollowing",@"method",
                              token,@"session_token",@"1",@"page_no",userId,@"user_id",@"1",@"following",nil];
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
            if(success == 1){
                FollowingsArray = [result objectForKey:@"following"];
                userFriends.text = [[NSString alloc]initWithFormat:@"%lu Following",(unsigned long)FollowingsArray.count];
            }
        }
    }];
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
                
                //[friendsChannelTable reloadData];
                //[self.view addSubview:friendsChannelView];
                if(IS_IPHONE_6){
                    friendsChannelView.frame = CGRectMake(0, 0, 375, 667);
                }
                else if(IS_IPHONE_6Plus)
                {
                    friendsChannelView.frame = CGRectMake(0, 0, 414, 736);
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


#pragma mark Search Methods

- (IBAction)hideShowsearchbar:(id)sender {
    
    [searchField resignFirstResponder];
    [searchField2 resignFirstResponder];
    loadFollowings = false;
    [FollowingsAM removeAllObjects];
    searchcorners = true;
    [_searchTable reloadData];
    [self SearchCorners];
    nousersFound.hidden = YES;
    [self.view addSubview:searchView];
    SearchforTag = NO;
}

- (IBAction)searchBack:(id)sender {
    [searchView removeFromSuperview];
    loadFollowings = false;
    [tagFriendsView removeFromSuperview];
    [self GetFollowersCall];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TestNotification"
     object:self];
    [SVProgressHUD dismiss];
}

-(void) SearchCorners{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1) {
               
                searchField.text = nil;
                searchField2.text = nil;
//
//                usersArray = [result objectForKey:@"users_found"];
//                UsersModel.PopUsersArray = [[NSMutableArray alloc] init];
//                UsersModel.imagesArray = [[NSMutableArray alloc] init];
//                
//                for(NSDictionary *tempDict in usersArray){
//                    
//                    PopularUsersModel *_Popusers = [[PopularUsersModel alloc] init];
//                    _Popusers.full_name = [tempDict objectForKey:@"full_name"];
//                    _Popusers.friendID = [tempDict objectForKey:@"id"];
//                    _Popusers.profile_link = [tempDict objectForKey:@"profile_link"];
//                    _Popusers.profile_type = [tempDict objectForKey:@"profile_type"];
//                    _Popusers.status = [tempDict objectForKey:@"state"];
//                    
//                    [UsersModel.imagesArray addObject:_Popusers.profile_link];
//                    [UsersModel.PopUsersArray addObject:_Popusers];
//                    usersArray = UsersModel.PopUsersArray;
//                    arrImages = UsersModel.imagesArray;
//                }
                FollowingsArray = [result objectForKey:@"users_found"];
                
                for(NSDictionary *tempDict in FollowingsArray){
                    Followings *_responseData = [[Followings alloc] init];
                    
                    _responseData.f_id = [tempDict objectForKey:@"id"];
                    _responseData.fullName = [tempDict objectForKey:@"full_name"];
                    _responseData.is_celeb = [tempDict objectForKey:@"is_celeb"];
                    _responseData.profile_link = [tempDict objectForKey:@"profile_link"];
                    _responseData.status = [tempDict objectForKey:@"state"];
                    [FollowingsAM addObject:_responseData];
                }
                [_searchTable reloadData];

            }
            else if(success == 0)
            {
                searchField.text = nil;
                searchField2.text = nil;
                [searchField2 becomeFirstResponder];
                nousersFound.hidden = NO;
            }
        }
        else{
            searchField.text = nil;
            searchField2.text = nil;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
    
}
- (void)statusPressed:(UIButton *)sender{
    
    UIButton *statusBtn = (UIButton *)sender;
    currentSelectedIndex = statusBtn.tag;
    
    Followings *_responseData = [[Followings alloc] init];
    _responseData  = [FollowingsAM objectAtIndex:currentSelectedIndex];
    friendId = _responseData.f_id;
    
    [statusBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    
    if ([_responseData.status isEqualToString:@"ADD_FRIEND"]) {
        _responseData.status = @"PENDING";
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        [self sendFriendRequest];
        
    }else if ([_responseData.status isEqualToString:@"PENDING"] || [_responseData.status isEqualToString:@"FRIEND"]){
        _responseData.status = @"PENDING";
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
        [self sendDeleteFriend];
    }
}

- (void) getUsers{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
                [_searchTable reloadData];
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
    _responseData  = [FollowingsAM objectAtIndex:currentSelectedIndex];
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
                if(loadFollowings){
                    // [self getFollowing];
                    _responseData.status = @"ADD_FRIEND";
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                }
                else{
                    //[self getFollowers];
                    _responseData.status = @"ADD_FRIEND";
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                }
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
                [_searchTable reloadData];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}

- (void) sendFriendRequest{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    Followings *_responseData = [[Followings alloc] init];
    _responseData  = [FollowingsAM objectAtIndex:currentSelectedIndex];
//     [FollowingsAM removeAllObjects];
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                if(loadFollowings){
                       // [self getFollowing];
                    _responseData.status = @"FRIEND";
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                }
                else{
                        //[self getFollowers];
                    _responseData.status = @"FRIEND";
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
     nousersFound.hidden = YES;
    [searchField2 becomeFirstResponder];
    [FollowingsAM removeAllObjects];
    [_searchTable reloadData];
    [self.view addSubview:searchView];
}
#pragma mark - EditCover
- (IBAction)EditCoverImg:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:CurrentImageCategoryCover forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    fromImagePicker = TRUE;
    coverimagetocache =  channelCover.image;
    [SVProgressHUD dismiss];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    //[self setUserCoverImage];
    
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
- (IBAction)uploadProfilePic:(id)sender{
    [[NSUserDefaults standardUserDefaults] setInteger:ProfilePIC forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    fromImagePicker = TRUE;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}
- (void) updateCover{
    
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
-(void) UpdateProfilePic{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    
    requestc = [ASIFormDataRequest requestWithURL:url];
    [requestc addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [requestc setPostValue:token forKey:@"session_token"];
    
    NSData *profileDatas = UIImagePNGRepresentation(User_pic.image);
    [requestc setData:profileDatas withFileName:[NSString stringWithFormat:@"%@.png",@"thumbnail"] andContentType:@"image/png" forKey:@"profile_link"];
    
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
        picker.videoMaximumDuration = 60;
        
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
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == ProfilePIC)
    {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        User_pic.image = chosenImage;
        [picker dismissViewControllerAnimated:YES completion:NULL];
        [self UpdateProfilePic];
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
        [self PrivacyEveryOne:nil];
        [self UnlimitedPressed:nil];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        CMTime time = [asset duration];
        time.value = 0;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        thumbnail = [UIImage imageWithCGImage:imageRef];
        
        CGImageRelease(imageRef);
        _thumbnailImageView.image = thumbnail;
        profileData = UIImagePNGRepresentation(thumbnail);
        [self movetoUploadBeamController];
        
        //[self.view addSubview:_uploadBeamView];
      
        
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
-(void) movetoUploadBeamController{
    BeamUploadVC *uploadController = [[BeamUploadVC alloc] initWithNibName:@"BeamUploadVC" bundle:nil];
    uploadController.dataToUpload = movieData;
    uploadController.video_duration = video_duration;
    uploadController.ParentCommentID = @"-1";
    uploadController.postID = @"-1";
    uploadController.isAudio = false;
    uploadController.profileData = profileData;
    uploadController.thumbnailImage = thumbnail;
    if(uploadAnonymous)
        uploadController.isAnonymous = true;
    else
        uploadController.isAnonymous = false;
    [[self navigationController] pushViewController:uploadController animated:YES];
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
    fromImagePicker = FALSE;
    [_progressview setProgress:1.0];
    //if(currentState == 0)
        //[self getHomeContent];
    
    AudioServicesPlaySystemSound(1003);
}

- (void)requestFailed:(ASIHTTPRequest *)theRequest {
    fromImagePicker = FALSE;
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
                                   //[NSNumber numberWithInt:kAudioFormatMPEGLayer3], AVFormatIDKey,
                                    [NSNumber numberWithInt:AVAudioQualityHigh],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];

    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
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
    closeBtnAudio.hidden = true;
    
    if(!isRecording){
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
    isRecording = true;
}
- (IBAction)AudioClosePressed:(id)sender {
    
    [_uploadAudioView removeFromSuperview];
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
    [timerToupdateLbl invalidate];
    [audioTimeOut invalidate];
    closeBtnAudio.hidden = false;
    isRecording = false;
    countDownlabel.text = @"01:00";
    secondsLeft = 60;
    audioData = [NSData dataWithContentsOfURL:_audioRecorder.url];
    [_uploadAudioView removeFromSuperview];
    BeamUploadVC *uploadController = [[BeamUploadVC alloc] initWithNibName:@"BeamUploadVC" bundle:nil];
    uploadController.dataToUpload = audioData;
    uploadController.video_duration = secondsConsumed;
    uploadController.ParentCommentID = @"-1";
    uploadController.postID = @"-1";
    uploadController.isAudio = true;
    [[self navigationController] pushViewController:uploadController animated:YES];
 
    //[self.view addSubview:_uploadBeamView];
}
-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder
                                  error:(NSError *)error
{  isRecording = false;
    closeBtnAudio.hidden = false;
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == searchField || searchField2){
        [textField resignFirstResponder]; // Dismiss the keyboard.
        [self hideShowsearchbar:self];
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
