//
//  NewHomeCells.h
//  HydePark
//
//  Created by Apple on 09/03/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface NewHomeCells : UITableViewCell

@property (weak, nonatomic)   IBOutlet UIView *imgContainer;
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
@property (strong, nonatomic) IBOutlet UIImageView *transthumb;
@property (strong, nonatomic) IBOutlet AsyncImageView *CH_Video_Thumbnail;
@property (strong, nonatomic) IBOutlet UILabel *Ch_videoLength;
@property (weak, nonatomic)   IBOutlet UIButton *userProfileView;
@property (weak, nonatomic)   IBOutlet UIActivityIndicatorView *activityInd;
@property (weak, nonatomic)   IBOutlet UIImageView *leftreplImg;

@property (strong, nonatomic) IBOutlet UIButton *CH_RplayVideo;
@property (weak, nonatomic)   IBOutlet UIView *RimgContainer;
@property (strong, nonatomic) IBOutlet AsyncImageView *CH_RprofileImage;
@property (strong, nonatomic) IBOutlet AsyncImageView *CH_RVideo_Thumbnail;
@property (strong, nonatomic) IBOutlet UIImageView *Rtransthumb;
@property (strong, nonatomic) IBOutlet UIButton *CH_Rheart;
@property (strong, nonatomic) IBOutlet UIButton *CH_RcommentsBtn;
@property (strong, nonatomic) IBOutlet UILabel *CH_Rseen;
@property (strong, nonatomic) IBOutlet UILabel *CH_RuserName;
@property (strong, nonatomic) IBOutlet UILabel *CH_RVideoTitle;
@property (strong, nonatomic) IBOutlet UILabel *CH_RheartCountlbl;
@property (strong, nonatomic) IBOutlet UILabel *CH_RCommentscountLbl;
@property (weak, nonatomic)   IBOutlet UIImageView *rightreplImg;
@property (weak, nonatomic)   IBOutlet UIImageView *playImage;

@end
