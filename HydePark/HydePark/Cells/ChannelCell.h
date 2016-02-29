//
//  ChannelCell.h
//  HydePark
//
//  Created by Mr on 22/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ChannelCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *imgContainer;
@property (strong, nonatomic) IBOutlet UIButton *CH_playVideo;
@property (strong, nonatomic) IBOutlet AsyncImageView *CH_profileImage;
@property (strong, nonatomic) IBOutlet UIButton *CH_heart;
@property (strong, nonatomic) IBOutlet UILabel *CH_heartCountlbl;
@property (strong, nonatomic) IBOutlet UIButton *CH_commentsBtn;
@property (strong, nonatomic) IBOutlet UILabel *CH_CommentscountLbl;
@property (strong, nonatomic) IBOutlet UILabel *CH_seen;
@property (strong, nonatomic) IBOutlet UIButton *CH_flag;
@property (strong, nonatomic) IBOutlet UILabel *CH_userName;
@property (strong, nonatomic) IBOutlet UILabel *CH_VideoTitle;
@property (strong, nonatomic) IBOutlet UILabel *CH_hashTags;
@property (strong, nonatomic) IBOutlet AsyncImageView *CH_Video_Thumbnail;
@property (strong, nonatomic) IBOutlet UILabel *Ch_videoLength;
@property (weak, nonatomic) IBOutlet UIButton *userProfileView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityInd;

@end
