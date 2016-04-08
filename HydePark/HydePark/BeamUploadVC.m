//
//  BeamUploadVC.m
//  HydePark
//
//  Created by Apple on 21/03/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "BeamUploadVC.h"
#import "ASIFormDataRequest.h"
#import "Utils.h"
#import <AudioToolbox/AudioServices.h>
#import "SVProgressHUD.h"
#import "CommentsModel.h"
@interface BeamUploadVC ()

@end
@implementation BeamUploadVC
@synthesize dataToUpload,isAnonymous,isAudio,thumbnailImage,profileData,postID,ParentCommentID,video_duration,video_thumbnail,isComment;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    normalAttrdict = [NSDictionary dictionaryWithObject:BlueThemeColor(145,151,163) forKey:NSForegroundColorAttributeName];
    highlightAttrdict = [NSDictionary dictionaryWithObject:BlueThemeColor(54,78,141) forKey:NSForegroundColorAttributeName ];
    tepper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tepper.cancelsTouchesInView = NO;
    //self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    if(IS_IPHONE_5)
        [_uploadbeamScroller setContentSize:CGSizeMake(320,600)];
    else if (IS_IPHONE_6)
        [_uploadbeamScroller setContentSize:CGSizeMake(375,800)];
    else if(IS_IPAD)
    {
        upperView.frame = CGRectMake(0, 0, 768, 86);
        //        frameBeamscroller = _uploadbeamScroller.frame;
        //        frameBeamscroller.origin.y += 86;
        //        _uploadbeamScroller.frame = frameBeamscroller;
    }
    if(appDelegate.hasbeenEdited)
    {
        NSURL *url = [NSURL URLWithString:[video_thumbnail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                _thumbnailImageView.image = image;
            }
        }];
    }
    IS_mute = @"NO";
    _statusText.delegate = self;
    
    commentAllowed = @"-1";
    privacySelected = @"PUBLIC";
    tagsString = @"";
    _thumbnailImageView.image = thumbnailImage;
    if(isAnonymous)
        is_Anonymous = @"1";
    else
        is_Anonymous = @"0";
    if(isAudio)
        _thumbnailImageView.image = [UIImage imageNamed: @"splash_audio_image.png"];
    apDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self PrivacyEveryOne:nil];
    [self UnlimitedPressed:nil];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    //    const int movementDistance = 145; // tweak as needed
    //    const float movementDuration = 0.3f; // tweak as needed
    //
    //    int movement = (up ? -movementDistance : movementDistance);
    //
    //    [UIView beginAnimations: @"anim" context: nil];
    //    [UIView setAnimationBeginsFromCurrentState: YES];
    //    [UIView setAnimationDuration: movementDuration];
    //    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    //    [UIView commitAnimations];
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (IBAction)uploadBeamPressed:(id)sender{
    if(!apDelegate.hasbeenEdited){
        if(isAudio && !isComment)
            [self uploadAduio:dataToUpload];
        else if(isComment && !isAudio)
            [self uploadComment:dataToUpload];
        else if (isComment && isAudio)
            [self uploadAudioComment:dataToUpload];
        else
            [self uploadBeam:dataToUpload];
    }
    else{
        appDelegate.hasbeenEdited = FALSE;
        [self editUploadedBeam];
    }
    [self.view addSubview:blockerView];
    
}
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                                   //rewardsiconimgview.image = [UIImage imageNamed:@"rewardsicon.png"];
                               }
                           }];
}
-(void) editUploadedBeam{
    [SVProgressHUD showWithStatus:@"Saving Changes"];
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request setPostValue:userSession forKey:@"session_token"];
    [request setPostValue:privacySelected forKey:@"privacy"];
    [request setPostValue:commentAllowed forKey:@"reply_count"];
    [request setPostValue:_statusText.text forKey:@"caption"];
    [request setPostValue:@"0" forKey:@"mute"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:@"COLOUR" forKey:@"filter"];
    [request setPostValue:@"editPost" forKey:@"method"];
    [request setUploadProgressDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request startAsynchronous];
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

-(void) uploadBeam :(NSData*)file {
    [SVProgressHUD showWithStatus:@"Uploading Beam"];
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
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
    if([_statusText.text isEqualToString:@"Your thoughts..."])
        [request setPostValue:@"" forKey:@"caption"];
    else
        [request setPostValue:_statusText.text forKey:@"caption"];
    //[request setPostValue:videotype forKey:@"filter"];
    [request setPostValue:IS_mute forKey:@"mute"];
    if(![tagsString isEqualToString:@""])
        [request setPostValue:tagsString forKey:@"topic_name"];
    [request setPostValue:video_duration forKey:@"video_length"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    [request setPostValue:is_Anonymous forKey:@"is_anonymous"];
    [request setPostValue:METHOD_UPLOAD_STATUS forKey:@"method"];
    //[request setShowAccurateProgress:YES];
    [request setUploadProgressDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request startAsynchronous];
}
-(void) uploadComment:(NSData*)file{
    [SVProgressHUD showWithStatus:@"Uploading Comment"];
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
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
    if([_statusText.text isEqualToString:@"Your thoughts..."])
        [request setPostValue:@"" forKey:@"caption"];
    else
        [request setPostValue:_statusText.text forKey:@"caption"];
    //[request setPostValue:videotype forKey:@"filter"];
    [request setPostValue:IS_mute forKey:@"mute"];
    if(![tagsString isEqualToString:@""])
        [request setPostValue:tagsString forKey:@"topic_name"];
    [request setPostValue:video_duration forKey:@"video_length"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    [request setPostValue:is_Anonymous forKey:@"is_anonymous"];
    [request setPostValue:@"COLOUR" forKey:@"filter"];
    [request setPostValue:METHOD_COMMENTS_POST forKey:@"method"];
    //[request setShowAccurateProgress:YES];
    [request setUploadProgressDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request startAsynchronous];
}
-(void) uploadAudioComment:(NSData*)file{
    [SVProgressHUD showWithStatus:@"Uploading Audio Comment"];
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [request setData:file withFileName:[NSString stringWithFormat:@"%@.wav",@"sound"] andContentType:@"audio/wav" forKey:@"audio_link"];
    
    [request setPostValue:userSession forKey:@"session_token"];
    [request setPostValue:privacySelected forKey:@"privacy"];
    //[request setPostValue:TopicSelected forKey:@"topic_id"];
    [request setPostValue:commentAllowed forKey:@"reply_count"];
    if([_statusText.text isEqualToString:@"Your thoughts..."])
        [request setPostValue:@"" forKey:@"caption"];
    else
        [request setPostValue:_statusText.text forKey:@"caption"];
    //[request setPostValue:videotype forKey:@"filter"];
    [request setPostValue:@"0" forKey:@"is_anonymous"];
    [request setPostValue:@"0" forKey:@"mute"];
    if(![tagsString isEqualToString:@""])
        [request setPostValue:tagsString forKey:@"topic_name"];
    [request setPostValue:video_duration forKey:@"video_length"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    [request setPostValue:@"COLOUR" forKey:@"filter"];
    [request setPostValue:METHOD_COMMENTS_POST forKey:@"method"];
    //[request setShowAccurateProgress:YES];
    [request setUploadProgressDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request startAsynchronous];
}
-(void) uploadAduio:(NSData*)file{
    [SVProgressHUD showWithStatus:@"Uploading Audio"];
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [request setData:file withFileName:[NSString stringWithFormat:@"%@.wav",@"sound"] andContentType:@"audio/wav" forKey:@"audio_link"];
    
    [request setPostValue:userSession forKey:@"session_token"];
    [request setPostValue:privacySelected forKey:@"privacy"];
    //[request setPostValue:TopicSelected forKey:@"topic_id"];
    [request setPostValue:commentAllowed forKey:@"reply_count"];
    if([_statusText.text isEqualToString:@"Your thoughts..."])
        [request setPostValue:@"" forKey:@"caption"];
    else
        [request setPostValue:_statusText.text forKey:@"caption"];
    //[request setPostValue:videotype forKey:@"filter"];
    [request setPostValue:@"0" forKey:@"is_anonymous"];
    [request setPostValue:@"0" forKey:@"mute"];
    if(![tagsString isEqualToString:@""])
        [request setPostValue:tagsString forKey:@"topic_name"];
    [request setPostValue:video_duration forKey:@"video_length"];
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
- (IBAction)uploadBeamBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)PrivacyEveryOne:(id)sender {
    [cpeveryone setImage:[UIImage imageNamed:@"blueradio.png"]];
    [cponlyme setImage:[UIImage imageNamed:@"greyradio.png"]];
    [cpfriends setImage:[UIImage imageNamed:@"greyradio.png"] ];
    everyOnelbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    onlyMelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    Friendslbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    privacySelected = @"PUBLIC";
    
}

- (IBAction)PrivacyOnlyMe:(id)sender {
    [cpeveryone setImage:[UIImage imageNamed:@"greyradio.png"]];
    [cponlyme setImage:[UIImage imageNamed:@"blueradio.png"]];
    [cpfriends setImage:[UIImage imageNamed:@"greyradio.png"] ];
    onlyMelbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    everyOnelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    Friendslbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    privacySelected = @"PRIVATE";
}

- (IBAction)PrivacyFriends:(id)sender {
    [cpeveryone setImage:[UIImage imageNamed:@"greyradio.png"] ];
    [cponlyme setImage:[UIImage imageNamed:@"greyradio.png"]];
    [cpfriends setImage:[UIImage imageNamed:@"blueradio.png"]];
    Friendslbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    onlyMelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    everyOnelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    privacySelected = @"FRIENDS";
}

- (IBAction)upto60Pressed:(id)sender {
    [up60 setImage:[UIImage imageNamed:@"blueradio.png"]];
    [noreply setImage:[UIImage imageNamed:@"greyradio.png"]];
    [unlimited setImage:[UIImage imageNamed:@"greyradio.png"] ];
    upto60.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    Unlimited.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    noreplies.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    commentAllowed = @"50";
    
}

- (IBAction)noRepliesPressed:(id)sender {
    [up60 setImage:[UIImage imageNamed:@"greyradio.png"]];
    [noreply setImage:[UIImage imageNamed:@"blueradio.png"]];
    [unlimited setImage:[UIImage imageNamed:@"greyradio.png"] ];
    noreplies.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    Unlimited.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    upto60.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    commentAllowed = @"0";
}

- (IBAction)UnlimitedPressed:(id)sender {
    [up60 setImage:[UIImage imageNamed:@"greyradio.png"] ];
    [noreply setImage:[UIImage imageNamed:@"greyradio.png"]];
    [unlimited setImage:[UIImage imageNamed:@"blueradio.png"]];
    Unlimited.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    upto60.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    noreplies.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    commentAllowed = @"-1";
}
#pragma mark ASI delegates
- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength {
    NSLog(@"data length: %lld", newLength);
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    [blockerView removeFromSuperview];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
    NSLog(@"This is respone ::: %@",result);
    AudioServicesPlaySystemSound(1003);
    
    CommentsModel *_comment = [[CommentsModel alloc] init];
    NSArray *post = [result objectForKey:@"coment"];
    
    for(int i=0;i<post.count; i++) {
        
        NSDictionary *tempDixt = [post objectAtIndex:i];
        
        _comment.title = [tempDixt objectForKey:@"caption"];
        _comment.comments_count = [tempDixt objectForKey:@"comment_count"];
        _comment.comment_like_count = [tempDixt objectForKey:@"like_count"];
        _comment.userName = [tempDixt objectForKey:@"full_name"];
        _comment.topic_id = [tempDixt objectForKey:@"topic_id"];
        _comment.user_id = [tempDixt objectForKey:@"user_id"];
        _comment.profile_link = [tempDixt objectForKey:@"profile_link"];
        _comment.liked_by_me = [tempDixt objectForKey:@"liked_by_me"];
        _comment.mute = [tempDixt objectForKey:@"mute"];
        _comment.video_link = [tempDixt objectForKey:@"video_link"];
        _comment.video_thumbnail_link = [tempDixt objectForKey:@"video_thumbnail_link"];
        _comment.image_link = [tempDixt objectForKey:@"image_link"];
        _comment.VideoID = [tempDixt objectForKey:@"id"];
        _comment.video_length = [tempDixt objectForKey:@"video_length"];
        _comment.timestamp = [tempDixt objectForKey:@"timestamp"];
        _comment.is_anonymous = [tempDixt objectForKey:@"is_anonymous"];
        _comment.seen_count = [tempDixt objectForKey:@"seen_count"];
        _comment.reply_count = [tempDixt objectForKey:@"reply_count"];
        appDelegate.commentObj = _comment;
        appDelegate.hasBeenUpdated = true;
        appDelegate.timeToupdateHome = TRUE;
        break;
    }
    
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)requestFailed:(ASIHTTPRequest *)theRequest {
    [SVProgressHUD dismiss];
    [blockerView removeFromSuperview];
    NSString *response = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"This is respone ::: %@",response);
    [self.navigationController popViewControllerAnimated:NO];
}

@end
