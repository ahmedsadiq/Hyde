//
//  VideoCells.h
//  HydePark
//
//  Created by Apple on 25/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AsyncImageView.h"

@interface VideoCells : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UILabel *VideoTitle;
@property (strong, nonatomic) IBOutlet AsyncImageView *profileImage;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIButton *CH_heart;
@property (strong, nonatomic) IBOutlet UIButton *CH_commentsBtn;
@property (strong, nonatomic) IBOutlet UILabel *commentsCount;
@property (strong, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityind;
@property (strong, nonatomic) MPMoviePlayerController * movieplayer;
@end
