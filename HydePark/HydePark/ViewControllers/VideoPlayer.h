//
//  VideoPlayer.h
//  HydePark
//
//  Created by Mr on 28/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "HomeVC.h"
#import "AppDelegate.h"
#import "VideoModel.h"
@interface VideoPlayer : UIViewController

{
    NSString *videoLink;
    NSString *videoTitle;
    NSString *Tags;
    NSString *Name;
    
    
    HomeVC *homeObj;
    AppDelegate *appDelegate;
    IBOutlet UILabel *user_name;
    
    IBOutlet UIImageView *user_image;
    IBOutlet UILabel *video_title;
    IBOutlet UILabel *hashTags;
}

//@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
- (IBAction)playMovie:(id)sender;
- (IBAction)back:(id)sender;
@property (strong, nonatomic) NSMutableArray *videoObjs;


@end
