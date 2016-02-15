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
    
    [self getTopics];
     [_topicsScrollview setContentSize:CGSizeMake(_topicsScrollview.frame.size.width, _topicsScrollview.frame.size.height+80)];
    
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
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            
            int success = [[result objectForKey:@"success"] intValue];
            NSString *topics = [result objectForKey:@"topics"];
            
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];

}
-(void) populateTopics{
    
    [name_lbl1 setText:[topicNameArray objectAtIndex:0]];
    [name_lbl2 setText:[topicNameArray objectAtIndex:1]];
    [name_lbl3 setText:[topicNameArray objectAtIndex:2]];
    [name_lbl4 setText:[topicNameArray objectAtIndex:3]];
    [name_lbl5 setText:[topicNameArray objectAtIndex:4]];
    
    [beam_lbl1 setText:[[NSString alloc]initWithFormat:@"%@ Beams",[beamsArray objectAtIndex:0]]];
    [beam_lbl2 setText:[[NSString alloc]initWithFormat:@"%@ Beams",[beamsArray objectAtIndex:1]]];
    [beam_lbl3 setText:[[NSString alloc]initWithFormat:@"%@ Beams",[beamsArray objectAtIndex:2]]];
    [beam_lbl4 setText:[[NSString alloc]initWithFormat:@"%@ Beams",[beamsArray objectAtIndex:3]]];
    [beam_lbl5 setText:[[NSString alloc]initWithFormat:@"%@ Beams",[beamsArray objectAtIndex:4]]];
        
    [SVProgressHUD dismiss];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)topic1Pressed:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
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
    
    [[NavigationHandler getInstance]NavigateToHomeScreen];
}
- (IBAction)searchHideShow:(id)sender {
    [SVProgressHUD dismiss];
    [[NavigationHandler getInstance] MoveToSearchFriends];
}
@end
