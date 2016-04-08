//
//  Topics.m
//  HydePark
//
//  Created by Mr on 22/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "Topics.h"
#import "DrawerVC.h"
#import "Utils.h"
#import "NavigationHandler.h"
#import "SVProgressHUD.h"
#import "Constants.h"
#import "AsyncImageView.h"
#import "VideoModel.h"
#import "VideoPlayerVC.h"

@interface Topics ()

@end

@implementation Topics

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
    topics_model = [[topicsModel alloc]init];
    topicsS = [[NSMutableArray alloc] init];
    videoModelContainer = [[NSMutableArray alloc]init];
    [self getTopics];
    [_topicsScrollview setContentSize:CGSizeMake(_topicsScrollview.frame.size.width, _topicsScrollview.frame.size.height+80)];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    topicString = @"";
}

-(void) getTopics{
    [SVProgressHUD showWithStatus:@"Getting Topics..."];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_TOPICS,@"method",
                              token,@"Session_token",@"",@"post_id", nil];
    
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
            NSString *topics = [result objectForKey:@"topics"];
            NSLog(@"%@",result);
            if(success == 1) {
                topicsArray = [result objectForKey:@"topics"];
                
                topics_model.topics_array = [[NSMutableArray alloc] init];
                topics_model.images_array = [[NSMutableArray alloc]init];
                topics_model.beams_array = [[NSMutableArray alloc] init];
                topics_model.names_array = [[NSMutableArray alloc]init];
                
                for(NSDictionary *tempDict in topicsArray){
                    
                    topicsModel *_topics = [[topicsModel alloc] init];
                    
                    _topics.beams_count = [tempDict objectForKey:@"beams_count"];
                    _topics.topic_id = [tempDict objectForKey:@"id"];
                    _topics.topic_name = [tempDict objectForKey:@"name"];
                    _topics.topic_image = [tempDict objectForKey:@"image"];
                    
                    
                    [topics_model.images_array addObject:_topics.topic_image];
                    [topics_model.names_array addObject:_topics.topic_name];
                    [topics_model.beams_array addObject:_topics.beams_count];
                    [topics_model.topics_array addObject:_topics];
                    
                    topicsArray = topics_model.topics_array;
                    imagesArray = topics_model.images_array;
                    topicNameArray = topics_model.names_array;
                    beamsArray = topics_model.beams_array;
                }
                [self populateTopics];
            }
            
        }
        else{
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
    
}
-(void) populateTopics{
    
    if(topics_model.topics_array.count > 0){
        [name_lbl1 setText:[topicNameArray objectAtIndex:0]];
        [beam_lbl1 setText:[[NSString alloc]initWithFormat:@"%@ Beams",[beamsArray objectAtIndex:0]]];
    }
    if(topics_model.topics_array.count > 1){
        [name_lbl2 setText:[topicNameArray objectAtIndex:1]];
        [beam_lbl2 setText:[[NSString alloc]initWithFormat:@"%@ Beams",[beamsArray objectAtIndex:1]]];
    }
    if(topics_model.topics_array.count > 2){
        [name_lbl3 setText:[topicNameArray objectAtIndex:2]];
        [beam_lbl3 setText:[[NSString alloc]initWithFormat:@"%@ Beams",[beamsArray objectAtIndex:2]]];
    }
    if(topics_model.topics_array.count > 3){
        [name_lbl4 setText:[topicNameArray objectAtIndex:3]];
        [beam_lbl4 setText:[[NSString alloc]initWithFormat:@"%@ Beams",[beamsArray objectAtIndex:3]]];
    }
    if(topics_model.topics_array.count > 4){
        [name_lbl5 setText:[topicNameArray objectAtIndex:4]];
        [beam_lbl5 setText:[[NSString alloc]initWithFormat:@"%@ Beams",[beamsArray objectAtIndex:4]]];
    }
    
//    if([beamsArray objectAtIndex:0])
//        
//    if([beamsArray objectAtIndex:1])
//        
//    if([beamsArray objectAtIndex:2])
//        
//    if([beamsArray objectAtIndex:3])
//        
//    if([beamsArray objectAtIndex:4])
    
    
    [SVProgressHUD dismiss];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)topic1Pressed:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if(topics_model.topics_array.count > 0){
        topicsModel *_topics = [topics_model.topics_array  objectAtIndex:0];
        [topicsS addObject:_topics.topic_id];
    }
    if(btn.tag == 0) {
        btn.tag = 1;
        [btn setBackgroundImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
    }
    else {
        btn.tag = 0;
        [btn setBackgroundImage:[UIImage imageNamed:@"addTopic.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)topic2Pressed:(id)sender {
    UIButton *btn = (UIButton*)sender;
   if(topics_model.topics_array.count > 1){
        topicsModel *_topics = [topics_model.topics_array  objectAtIndex:1];
        [topicsS addObject:_topics.topic_id];
    }
    if(btn.tag == 0) {
        btn.tag = 1;
        [btn setBackgroundImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
    }
    else {
        btn.tag = 0;
        [btn setBackgroundImage:[UIImage imageNamed:@"addTopic.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)topic3Pressed:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if(topics_model.topics_array.count > 2){
        topicsModel *_topics = [topics_model.topics_array  objectAtIndex:2];
        [topicsS addObject:_topics.topic_id];
    }
    if(btn.tag == 0) {
        btn.tag = 1;
        [btn setBackgroundImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
    }
    else {
        btn.tag = 0;
        [btn setBackgroundImage:[UIImage imageNamed:@"addTopic.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)topic4Pressed:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if(topics_model.topics_array.count > 3){
        topicsModel *_topics = [topics_model.topics_array  objectAtIndex:3];
        [topicsS addObject:_topics.topic_id];
    }
    if(btn.tag == 0) {
        btn.tag = 1;
        [btn setBackgroundImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
    }
    else {
        btn.tag = 0;
        [btn setBackgroundImage:[UIImage imageNamed:@"addTopic.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)topic5Pressed:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if(topics_model.topics_array.count > 4){
        topicsModel *_topics = [topics_model.topics_array  objectAtIndex:4];
        [topicsS addObject:_topics.topic_id];
    }
    if(btn.tag == 0) {
        btn.tag = 1;
        [btn setBackgroundImage:[UIImage imageNamed:@"selected.png"] forState:UIControlStateNormal];
    }
    else {
        btn.tag = 0;
        [btn setBackgroundImage:[UIImage imageNamed:@"addTopic.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)ShowDrawer:(id)sender {
    [[DrawerVC getInstance] AddInView:self.view];
    [[DrawerVC getInstance] ShowInView];
}
- (IBAction)DoneBtn:(id)sender {
    [videoModelContainer removeAllObjects];
    NSString *topicString = [topicsS componentsJoinedByString:@","];
    [SVProgressHUD showWithStatus:@"Getting Topics..."];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"getBeamsByTopicIds",@"method",
                              token,@"Session_token",@"1",@"page_no",topicString,@"topic_ids",nil];
    
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
            NSLog(@"%@",result);
            if(success == 1) {
                NSArray *beams = [result objectForKey:@"beams"];
                if(beams.count == 0 || beams == nil)
                {
                    [SVProgressHUD dismiss];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No beams for selected topic" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                }
                else{
                for(NSDictionary *tempDict in beams){
                    VideoModel *_Videos = [[VideoModel alloc] init];
                    
                    _Videos.title = [tempDict objectForKey:@"caption"];
                    _Videos.comments_count = [tempDict objectForKey:@"comment_count"];
                    _Videos.userName = [tempDict objectForKey:@"full_name"];
                    _Videos.topic_id = [tempDict objectForKey:@"topic_id"];
                    _Videos.user_id = [tempDict objectForKey:@"user_id"];
                    _Videos.profile_image = [tempDict objectForKey:@"profile_link"];
                    _Videos.like_count = [tempDict objectForKey:@"like_count"];
                    _Videos.seen_count = [tempDict objectForKey:@"seen_count"];
                    _Videos.like_by_me = [tempDict objectForKey:@"liked_by_me"];
                    _Videos.video_link = [tempDict objectForKey:@"video_link"];
                    _Videos.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                    _Videos.videoID = [tempDict objectForKey:@"id"];
                    _Videos.video_length = [tempDict objectForKey:@"video_length"];
                    _Videos.image_link = [tempDict objectForKey:@"image_link"];
                    _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                    
                    [videoModelContainer addObject:_Videos];
                }
                VideoPlayerVC *videoPlayer;
                    if(IS_IPAD)
                        videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPad" bundle:nil];
                    else if(IS_IPHONE_6Plus)
                        videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPhonePlus" bundle:nil];
                    else
                        videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
                videoPlayer.videoObjs       = videoModelContainer;
                videoPlayer.indexToDisplay  = 0;
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
            }
            }
            else if(success == 0){
                    [SVProgressHUD dismiss];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No beams for selected topic" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
            }
        }
        else{
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
    
    //    [[NavigationHandler getInstance]NavigateToHomeScreen];
}
- (IBAction)searchHideShow:(id)sender {
    [SVProgressHUD dismiss];
    [[NavigationHandler getInstance] MoveToSearchFriends];
}
@end
