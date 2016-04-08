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
#import "NewHomeCells.h"
#import "VideoPlayerVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "QuartzCore/CALayer.h"
#import <AudioToolbox/AudioServices.h>
#import "AVFoundation/AVFoundation.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "BeamUploadVC.h"
@interface CommentsVC ()

@end

@implementation CommentsVC
@synthesize commentsObj,postArray,isComment,cPostId,isFirstComment;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    CommentsModelObj = [[CommentsModel alloc]init];
    videoModel = [[VideoModel alloc]init];
    videoObj = [[NSMutableArray alloc] init];
    secondsLeft = 60;
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    if(IS_IPHONE_5){
        bottomBarView.autoresizingMask = UIViewAutoresizingNone;
        bottomBarView.frame = CGRectMake(0, 468, 320, 100);
    }
    else if (IS_IPHONE_6)
    {
        audioBtnImage.frame = CGRectMake(140, 250, audioBtnImage.frame.size.width, audioBtnImage.frame.size.height);
        _audioRecordBtn.frame = CGRectMake(140, 250, _audioRecordBtn.frame.size.width, _audioRecordBtn.frame.size.height);
        closeBtnAudio.frame = CGRectMake(330, 30, closeBtnAudio.frame.size.width, closeBtnAudio.frame.size.height);
        countDownlabel.frame = CGRectMake(120,200,countDownlabel.frame.size.width,countDownlabel.frame.size.height);
    }
    [self initMainView];
    [self setAudioRecordSettings];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isRecording = false;
    if(appDelegate.hasBeenUpdated)
    {
        [commentsObj.CommentsArray addObject:appDelegate.commentObj];
        appDelegate.hasBeenUpdated = false;
        appDelegate.commentObj = nil;
        replies.text = [NSString stringWithFormat:@"%li",  commentsObj.CommentsArray.count];
    }
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"User_Id"] == postArray.user_id){
        editButto.hidden = YES;
        editImage.hidden = YES;
    }
    else{
        editButto.hidden = NO;
        editImage.hidden = NO;
    }
    [commentsTable reloadData];
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [editView setHidden:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initMainView{
    commentsTable.backgroundColor = [UIColor clearColor];
    commentsTable.opaque = NO;
    coverimgComments.layer.cornerRadius  = coverimgComments.frame.size.width /14.0f;
    coverimgComments.layer.masksToBounds = YES;
    likes.text      = postArray.like_count;
    replies.text    = postArray.comments_count;
    views.text      = postArray.seen_count;
    coverimgComments.imageURL = [NSURL URLWithString:postArray.video_thumbnail_link];
    NSURL *url1 = [NSURL URLWithString:postArray.video_thumbnail_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
    postID = postArray.videoID;
    
    videoLengthComments.text = postArray.video_length;
    titleComments.text = postArray.title;
    if([postArray.like_by_me isEqualToString:@"1"]){
        [likeBtn setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
    }
    if([postArray.is_anonymous isEqualToString:@"1"]){
        UserImg.image = [UIImage imageNamed:@"anonymousDp.png"];
        Postusername.text = @"Anonymous";
    }
    else{
        Postusername.text = postArray.userName;
        UserImg.imageURL = [NSURL URLWithString:postArray.profile_image];
        NSURL *url = [NSURL URLWithString:postArray.profile_image];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    }
    [UserImg roundImageCorner];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //CommentsCell *cell;
    NewHomeCells *cell;
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
   commentsTable.contentSize = CGSizeMake(commentsTable.frame.size.width,(commentsObj.CommentsArray.count/2 *tableHeight) +  bottomBarView.frame.size.height + 100);
    CommentsModel *tempVideos = [[CommentsModel alloc]init];
    tempVideos  = [commentsObj.CommentsArray objectAtIndex:currentIndex];
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
    cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    NSURL *url = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
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
    cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
//    UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
//    [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
//    [cell addGestureRecognizer:sgr];
    [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    //appDelegate.videotoPlay = [getTrendingVideos.mainhomeArray objectAtIndex:indexPath.row];
   // [cell.userProfileView addTarget:self action:@selector(MovetoUserProfile:) forControlEvents:UIControlEventTouchUpInside];
    cell.userProfileView.tag = currentIndex;
    [cell.CH_heart setTag:currentIndex];
    [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
    if ([tempVideos.liked_by_me isEqualToString:@"1"]) {
        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
    }else{
        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
    }
    
    //[cell.CH_flag addTarget:self action:@selector(Flag:) forControlEvents:UIControlEventTouchUpInside];
    [cell.CH_playVideo setTag:currentIndex];
    
    [cell.CH_flag setTag:currentIndex];
    cell.CH_commentsBtn.enabled = YES;
    cell.CH_RcommentsBtn.enabled = YES;
    [cell.CH_commentsBtn addTarget:self action:@selector(ReplyCommentpressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.CH_commentsBtn setTag:currentIndex];
    
    currentIndex++;
    if(currentIndex < commentsObj.CommentsArray.count)
    {
        CommentsModel *tempVideos = [[CommentsModel alloc]init];
        tempVideos  = [commentsObj.CommentsArray objectAtIndex:currentIndex];
        [cell.CH_RcommentsBtn addTarget:self action:@selector(ReplyCommentpressed:) forControlEvents:UIControlEventTouchUpInside];
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
        cell.CH_RVideo_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        NSURL *url = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        if([tempVideos.is_anonymous  isEqualToString: @"0"]){
            cell.CH_RuserName.text = tempVideos.userName;
    
        }
        else{
            //cell.CH_RVideo_Thumbnail.image =[UIImage imageNamed:@"anonymousDp.png"];
            cell.CH_RuserName.text = @"Anonymous";
        }
        if ([tempVideos.liked_by_me isEqualToString:@"1"]) {
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
        cell.playImage.hidden           = YES;
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(IS_IPHONE_5)
        tableHeight = 150.0f;
    else if (IS_IPAD)
        tableHeight = 362.0f;
    else
        tableHeight = 180.0f;
    return tableHeight;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int rows = (int)([commentsObj.CommentsArray count]/2);
    if([commentsObj.CommentsArray count] %2 == 1) {
        rows++;
    }
    return rows;
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
    
    videoModel.videoID              = tempVideos.VideoID;
    videoModel.video_thumbnail_link = tempVideos.video_thumbnail_link;
    videoModel.video_link           = tempVideos.video_link;
    videoModel.profile_image        =  tempVideos.profile_link;
    videoModel.userName             = tempVideos.userName;
    videoModel.is_anonymous         = tempVideos.is_anonymous;
    videoModel.title                = tempVideos.title;
    videoModel.like_count           = tempVideos.comment_like_count;
    videoModel.like_by_me           = tempVideos.liked_by_me;
    videoModel.seen_count           = tempVideos.seen_count;
    videoModel.title                = tempVideos.title;
    videoModel.comments_count       = tempVideos.comments_count;
    videoModel.reply_count          = tempVideos.reply_count;

    [self GetCommnetsOnPost];
}
-(void) GetCommnetsOnPost{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_COMMENTS_BY_PARENT_ID,@"method",
                              token,@"Session_token",@"1",@"page_no",ParentCommentID,@"parent_id",cPostId,@"post_id", nil];
    
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
                    _comment.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                    _comment.seen_count = [tempDict objectForKey:@"seen_count"];
                    _comment.reply_count = [tempDict objectForKey:@"reply_count"];
                    
                    [CommentsModelObj.ImagesArray addObject:_comment.profile_link];
                    [CommentsModelObj.ThumbnailsArray addObject:_comment.video_thumbnail_link];
                    [CommentsModelObj.mainArray addObject:_comment.video_link];
                    [CommentsModelObj.CommentsArray addObject:_comment];
                }
                // commentsObj = CommentsModelObj;
                CommentsVC *commentController ;
                if(IS_IPAD)
                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC_iPad" bundle:nil];
                else
                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
                commentController.commentsObj = CommentsModelObj;
                commentController.postArray = videoModel;
                commentController.cPostId   = cPostId;
                commentController.isFirstComment = FALSE;
                commentController.isComment     = TRUE;
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
#pragma mark - Beam Pressed

- (IBAction)beamPressed:(id)sender {
    if([sender tag] == 100){
        uploadAnonymous = true;
        uploadBeamTag = false;
    }
    else if([sender tag ] == 101)
    {
        uploadAnonymous = false;
        uploadBeamTag = true;
    }
    if([postArray.reply_count intValue] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Comments are not allowed on this Beam" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else{
    
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
}
#pragma mark - Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // user hit cancel
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
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
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        CMTime time = [asset duration];
        time.value = 0;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        thumbnailToUpload = thumbnail;
        profileData = UIImagePNGRepresentation(thumbnail);
        [self movetoUploadBeamController];
}
-(void) movetoUploadBeamController{
    BeamUploadVC *uploadController = [[BeamUploadVC alloc] initWithNibName:@"BeamUploadVC" bundle:nil];
    uploadController.dataToUpload = movieData;
    uploadController.video_duration = video_duration;
    if(isFirstComment)
        uploadController.ParentCommentID = @"-1";
    else
        uploadController.ParentCommentID = postArray.videoID;
    uploadController.postID = cPostId;
    uploadController.isAudio = false;
    uploadController.profileData = profileData;
    uploadController.isComment = TRUE;
    uploadController.thumbnailImage = thumbnailToUpload;
    if(uploadAnonymous)
        uploadController.isAnonymous = true;
    else
        uploadController.isAnonymous = false;
    [[self navigationController] pushViewController:uploadController animated:YES];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)RecorderPressed:(id)sender {
    if([postArray.reply_count intValue] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Comments are not allowed on this Beam" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    [self.view addSubview:_uploadAudioView];
    
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
    if(isFirstComment)
        uploadController.ParentCommentID = @"-1";
    else
        uploadController.ParentCommentID = postArray.videoID;
    uploadController.postID = cPostId;
    uploadController.isAudio = true;
    uploadController.isComment = TRUE;
    [[self navigationController] pushViewController:uploadController animated:YES];
   
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

- (void)LikeHearts:(UIButton*)sender{
    //liked = nil;
    UIButton *LikeBtn = (UIButton *)sender;
    currentSelectedIndex = LikeBtn.tag;
    CommentsModel *tempVideos = [[CommentsModel alloc]init];
    tempVideos  = [commentsObj.CommentsArray objectAtIndex:currentSelectedIndex];
    postID = tempVideos.VideoID;
    [self LikePost:currentSelectedIndex];
//    
//    if (liked == YES) {
//        [LikeBtn setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
//    }else if (liked == NO){
//        [LikeBtn setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
//    }
}
-(void)playVideo:(UIButton*)sender{
    
    UIButton *playBtn = (UIButton *)sender;
    currentSelectedIndex = playBtn.tag;
    [videoObj removeAllObjects];
    
    for(int i = 0; i < commentsObj.CommentsArray.count ; i++){
            CommentsModel *model = [commentsObj.CommentsArray objectAtIndex:i];
            VideoModel *temp = [[VideoModel alloc] init];
            temp.is_anonymous           = model.is_anonymous;
            temp.title                  = model.title;
            temp.comments_count         = model.comments_count;
            temp.userName               = model.userName;
            temp.topic_id               = model.topic_id;
            temp.user_id                = model.user_id;
            temp.profile_image          = model.profile_link;
            temp.video_link             = model.video_link;
            temp.video_thumbnail_link   = model.video_thumbnail_link;
            temp.image_link             = model.image_link;
            temp.videoID                = model.VideoID;
            temp.video_length           = model.video_length;
            temp.like_count             = model.comment_like_count;
            temp.like_by_me             = model.liked_by_me;
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
        videoPlayer.videoObjs       = videoObj;
        videoPlayer.indexToDisplay  = currentSelectedIndex;
        videoPlayer.isComment       = true;
        videoPlayer.cPostId         = cPostId;
        videoPlayer.isFirst         = false;
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
#pragma mark - Like Post
- (void) LikePost:(NSUInteger )indexToLike{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_LIKE_COMMENT,@"method",
                              token,@"session_token",postID,@"comment_id",nil];
    
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
                if ([message isEqualToString:@"Comment is Successfully Liked."]) {
                    //liked = YES;
                    CommentsModel *_Videos = [[CommentsModel alloc]init];
                    _Videos  = [commentsObj.CommentsArray objectAtIndex:indexToLike];
                    NSInteger likeCount = [_Videos.comment_like_count intValue];
                    likeCount++;
                    _Videos.comment_like_count = [NSString stringWithFormat: @"%ld", likeCount];
                    _Videos.liked_by_me = @"1";
                    [commentsObj.CommentsArray replaceObjectAtIndex:indexToLike withObject:_Videos];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [commentsTable beginUpdates];
                    [commentsTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [commentsTable endUpdates];
                }else if ([message isEqualToString:@"User have Successfully Unliked the comment"])
                {
                  //  liked = NO;
                    CommentsModel *_Videos = [[CommentsModel alloc]init];
                    _Videos  = [commentsObj.CommentsArray objectAtIndex:indexToLike];
                    NSInteger likeCount = [_Videos.comment_like_count intValue];
                    if(likeCount > 0)
                        likeCount--;
                    _Videos.comment_like_count = [NSString stringWithFormat: @"%ld", likeCount];
                    _Videos.liked_by_me = @"0";
                    [commentsObj.CommentsArray replaceObjectAtIndex:indexToLike withObject:_Videos];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [commentsTable beginUpdates];
                    [commentsTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [commentsTable endUpdates];

                }
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
- (IBAction)MainPlayBtn:(id)sender {
    UIButton *playBtn = (UIButton *)sender;
    currentSelectedIndex = playBtn.tag;
    [videoObj removeAllObjects];
    VideoModel *temp = [[VideoModel alloc] init];
    temp.is_anonymous           = postArray.is_anonymous;
    temp.title                  = postArray.title;
    temp.comments_count         = postArray.comments_count;
    temp.userName               = postArray.userName;
    temp.profile_image          = postArray.profile_image;
    temp.video_link             = postArray.video_link;
    temp.video_thumbnail_link   = postArray.video_thumbnail_link;
    temp.videoID                = postArray.videoID;
    temp.video_length           = postArray.video_length;
    temp.like_count             = postArray.like_count;
    temp.like_by_me             = postArray.like_by_me;
    temp.seen_count             = postArray.seen_count;
    temp.reply_count            = postArray.reply_count;
    temp.user_id                = postArray.user_id;
    [videoObj addObject:temp];
    VideoPlayerVC *videoPlayer;
    if(IS_IPAD)
        videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPad" bundle:nil];
    else if(IS_IPHONE_6Plus)
        videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPhonePlus" bundle:nil];
    else
        videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
    videoPlayer.videoObjs       = videoObj;
    videoPlayer.isFirst         = isFirstComment;
    //videoPlayer.isComment       = isComment;
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
//    [[NavigationHandler getInstance]MoveToPlayer];
}
-(IBAction)likeComment:(id)sender{
    if(!isComment)
    {
        if([postArray.like_by_me isEqualToString:@"1"])
        {
            [likeBtn setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
            postArray.like_by_me = @"0";
            NSInteger likeCount = [likes.text intValue];
            likeCount--;
            likes.text = [NSString stringWithFormat: @"%ld", likeCount];
        }
        else{
            [likeBtn setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
            postArray.like_by_me = @"1";
            NSInteger likeCount = [likes.text intValue];
            likeCount++;
            likes.text = [NSString stringWithFormat: @"%ld", likeCount];
        }
        [self LikeTopPost];
    }
    else
    {
        if([postArray.like_by_me isEqualToString:@"1"])
        {
            [likeBtn setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
            postArray.like_by_me = @"0";
            NSInteger likeCount = [likes.text intValue];
            likeCount--;
            likes.text = [NSString stringWithFormat: @"%ld", likeCount];
        }
        else{
            [likeBtn setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
            postArray.like_by_me = @"1";
            NSInteger likeCount = [likes.text intValue];
            likeCount++;
            likes.text = [NSString stringWithFormat: @"%ld", likeCount];
        }
        [self LikeComment];
    }
}
- (void) LikeComment{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_LIKE_COMMENT,@"method",
                              token,@"session_token",postID,@"comment_id",nil];
    
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
                appDelegate.timeToupdateHome = TRUE;
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }];
}
-(IBAction)editBtnPressed:(id)sender
{
    editView.hidden = false;
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
}
- (IBAction)CancelEditBtn:(id)sender{
    editView.hidden = YES;
}
- (IBAction)ReportBtn:(id)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    editView.hidden = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"reportPost",@"method",
                              token,@"session_token",cPostId,@"post_id",@"For No Reason",@"reason",nil];
    
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
-(IBAction)BlockPerson:(id)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    editView.hidden = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"blockUser",@"method",
                              token,@"session_token",postArray.user_id,@"blocking_user_id",nil];
    
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
                appDelegate.timeToupdateHome = TRUE;
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
-(void) LikeTopPost{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_LIKE_POST,@"method",
                              token,@"session_token",postArray.videoID,@"post_id",nil];
    
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
                    appDelegate.timeToupdateHome = TRUE;
                
                }
                else if ([message isEqualToString:@"Post is Successfully unliked by this user."])
                {
                    appDelegate.timeToupdateHome = TRUE;
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
