//
//  VideoPlayer.m
//  HydePark
//
//  Created by Mr on 28/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "VideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ALMoviePlayerController.h"
#import "Constants.h"
#import "NavigationHandler.h"

@interface VideoPlayer () <ALMoviePlayerControllerDelegate>

@property (nonatomic, strong) ALMoviePlayerController *moviePlayer;
@property (nonatomic) CGRect defaultFrame;

@end

@implementation VideoPlayer
@synthesize videoObjs;
- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"ALMoviePlayerController", @"ALMoviePlayerController");
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Local File" style:UIBarButtonItemStyleBordered target:self action:@selector(localFile)];
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Remote File" style:UIBarButtonItemStyleBordered target:self action:@selector(remoteFile)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSMutableArray *videos = videoObjs;
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    videoLink = appDelegate.videotoPlay;
    user_name.text = appDelegate.videoUploader;
    video_title.text = appDelegate.videotitle;
    //    hashTags.text = appDelegate.videotags;
    
    //    NSURL *url = [NSURL URLWithString:appDelegate.profile_pic_url];
    //    NSData *data = [NSData dataWithContentsOfURL:url];
    //    UIImage *img = [[UIImage alloc] initWithData:data];
    //    CGSize size = img.size;
    //    user_image.image = img;
    //
    //    if (img == nil) {
    //        user_image.image = [UIImage imageNamed:@"loading.jpg"];
    //    }
    
    user_image.imageURL = [NSURL URLWithString:appDelegate.profile_pic_url];
    NSURL *url = [NSURL URLWithString:appDelegate.profile_pic_url];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    
    
    [self setuserProfileImage];
    //create a player
    self.moviePlayer = [[ALMoviePlayerController alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    // [self.moviePlayer setFullscreen:YES animated:YES];
    
    self.moviePlayer.view.alpha = 0.f;
    self.moviePlayer.delegate = self; //IMPORTANT!
    
    //create the controls
    ALMoviePlayerControls *movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:self.moviePlayer style:ALMoviePlayerControlsStyleFullscreen];
    //[movieControls setAdjustsFullscreenImage:NO];
    [movieControls setBarColor:[UIColor blackColor]];
    [movieControls setTimeRemainingDecrements:YES];
    //[movieControls setFadeDelay:2.0];
    //[movieControls setBarHeight:100.f];
    //[movieControls setSeekRate:2.f];
    
    //assign controls
    [self.moviePlayer setControls:movieControls];
    [self.view addSubview:self.moviePlayer.view];
    
    //THEN set contentURL
    
    if (videoLink == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@"mp4"];
        [self.moviePlayer setContentURL:[NSURL fileURLWithPath:path]];
    }else{
        [self.moviePlayer setContentURL:[NSURL URLWithString:videoLink]];
        [self.moviePlayer play];
        
        //        NSString *path = [[NSBundle mainBundle] pathForResource:videoLink ofType:@"mp4"];
        //        [self.moviePlayer setContentURL:[NSURL fileURLWithPath:path]];
        
    }
    
    
    //delay initial load so statusBarOrientation returns correct value
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self configureViewForOrientation:[UIApplication sharedApplication].statusBarOrientation];
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            self.moviePlayer.view.alpha = 1.f;
        } completion:^(BOOL finished) {
            self.navigationItem.leftBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }];
    });
    
    
}

- (void)setuserProfileImage{
    
    if (IS_IPAD) {
        user_image.frame = CGRectMake(6, 17, 148, 148);
    }
    
    user_image.layer.cornerRadius = user_image.frame.size.width / 2;
    for (UIView* subview in user_image.subviews)
        subview.layer.cornerRadius = user_image.frame.size.width / 2;
    
    user_image.layer.shadowColor = [UIColor blackColor].CGColor;
    user_image.layer.shadowOpacity = 0.7f;
    user_image.layer.shadowOffset = CGSizeMake(0, 5);
    user_image.layer.shadowRadius = 5.0f;
    user_image.layer.masksToBounds = NO;
    
    user_image.layer.cornerRadius = user_image.frame.size.width / 2;
    user_image.layer.masksToBounds = NO;
    user_image.clipsToBounds = YES;
    
    user_image.layer.backgroundColor = [UIColor clearColor].CGColor;
    user_image.layer.borderColor = [UIColor whiteColor].CGColor;
    user_image.layer.borderWidth = 3.0f;
    
}



- (void)configureViewForOrientation:(UIInterfaceOrientation)orientation {
    CGFloat videoWidth = 0;
    CGFloat videoHeight = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        videoWidth = 768.f;
        videoHeight = 545.f;
    } else {
        videoWidth = self.view.frame.size.width;
        videoHeight = 400.f;
    }
    
    //calulate the frame on every rotation, so when we're returning from fullscreen mode we'll know where to position the movie plauyer
    self.defaultFrame = CGRectMake(self.view.frame.size.width/2 - videoWidth/2, self.view.frame.size.height/2 - videoHeight/2, videoWidth, videoHeight);
    if (IS_IPHONE_4) {
        self.defaultFrame = CGRectMake(self.view.frame.size.width/2 - videoWidth/2, self.view.frame.size.height/2 - videoHeight/2 + 35, videoWidth, videoHeight);
    }
    
    
    
    //
    //only manage the movie player frame when it's not in fullscreen. when in fullscreen, the frame is automatically managed
    if (self.moviePlayer.isFullscreen)
        return;
    
    //you MUST use [ALMoviePlayerController setFrame:] to adjust frame, NOT [ALMoviePlayerController.view setFrame:]
    [self.moviePlayer setFrame:self.defaultFrame];
}
//these files are in the public domain and no longer have property rights
- (void)localFile {
    [self.moviePlayer stop];
    [self.moviePlayer setContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"popeye" ofType:@"mp4"]]];
    [self.moviePlayer play];
}

- (void)remoteFile {
    [self.moviePlayer stop];
    [self.moviePlayer setContentURL:[NSURL URLWithString:@"http://archive.org/download/WaltDisneyCartoons-MickeyMouseMinnieMouseDonaldDuckGoofyAndPluto/WaltDisneyCartoons-MickeyMouseMinnieMouseDonaldDuckGoofyAndPluto-HawaiianHoliday1937-Video.mp4"]];
    [self.moviePlayer play];
}
//IMPORTANT!
- (void)moviePlayerWillMoveFromWindow {
    //movie player must be readded to this view upon exiting fullscreen mode.
    if (![self.view.subviews containsObject:self.moviePlayer.view])
        [self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer setFrame:self.defaultFrame];
}

- (void)movieTimedOut {
    NSLog(@"MOVIE TIMED OUT");
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Time Out!"
                                                      message:@"Movie has been Timed out.Try Again"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self configureViewForOrientation:toInterfaceOrientation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    //[[NavigationHandler getInstance]NavigateToHomeScreen];
    [self.navigationController popViewControllerAnimated:false];
}
- (IBAction)playMovie:(id)sender {
    
}
@end
