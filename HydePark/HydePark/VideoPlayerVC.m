//
//  VideoPlayerVC.m
//  HydePark
//
//  Created by Apple on 25/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "VideoPlayerVC.h"
#import "NavigationHandler.h"
#import "VideoCells.h"
#import "Constants.h"
#import "VideoModel.h"
#import "UIImageView+RoundImage.h"
#import <AVFoundation/AVPlayer.h>
@import AVKit;
@interface VideoPlayerVC ()

@end

@implementation VideoPlayerVC
@synthesize videoObjs;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    cache = [[NSMutableDictionary alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:false];
}
#pragma mark ----------------------
#pragma mark TableView Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 660.0f;;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [videoObjs count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    VideoCells *cell;
    
    if (IS_IPAD) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoCells" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else{
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoCells" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if(indexPath.row == 0){
        scrollDown.hidden = NO;
    }
    else{
        scrollDown.hidden = YES;
    }
    VideoModel *tempVideo = [videoObjs objectAtIndex:indexPath.row];
    cell.profileImage.imageURL = [NSURL URLWithString:tempVideo.profile_image];
    NSURL *url = [NSURL URLWithString:tempVideo.profile_image];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    [cell.profileImage roundImageCorner];
    cell.VideoTitle.text = tempVideo.title;
    cell.username.text = tempVideo.userName;
    
    //if ([cache objectForKey:[NSString stringWithFormat:@"key%lu", indexPath.row]] != nil) {
      //  cell = [cache objectForKey:[NSString stringWithFormat:@"key%lu", indexPath.row]];
   // }
    //else{
    NSURL *url1 = [NSURL URLWithString:tempVideo.video_link];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = [AVPlayer playerWithURL:url1];
         dispatch_sync(dispatch_get_main_queue(), ^{
    //cell.movieplayer.controlStyle = MPMovieControlStyleDefault;
    //cell.movieplayer = [[MPMoviePlayerController alloc]initWithContentURL:url1];
    [playerViewController.view setFrame:CGRectMake(10,180, 360, 300)];
    [cell.contentView addSubview:playerViewController.view];
    //[cell.movieplayer.view setFrame:CGRectMake(10,180, 360, 300)];
    //[cell.contentView addSubview:cell.movieplayer.view];
    //[cell.movieplayer prepareToPlay];
    //[cell.movieplayer play];
         });
    });
    [cache setValue:cell forKey:[NSString stringWithFormat:@"key%lu", indexPath.row]];
    
    //}
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


@end
