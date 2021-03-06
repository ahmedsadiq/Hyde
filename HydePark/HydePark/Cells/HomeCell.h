//
//  HomeCell.h
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface HomeCell : UITableViewCell




@property (strong, nonatomic) IBOutlet UIButton *playVideo;
@property (strong, nonatomic) IBOutlet AsyncImageView *profileImage;
@property (strong, nonatomic) IBOutlet UIButton *heart;
@property (strong, nonatomic) IBOutlet UILabel *heartCountlbl;
@property (strong, nonatomic) IBOutlet UIButton *commentsBtn;
@property (strong, nonatomic) IBOutlet UILabel *CommentscountLbl;
@property (strong, nonatomic) IBOutlet UILabel *seenLbl;
@property (strong, nonatomic) IBOutlet UIButton *flag;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *VideoTitle;
@property (strong, nonatomic) IBOutlet UILabel *hashTags;
@property (strong, nonatomic) IBOutlet AsyncImageView *videoThumbnail;
@property (strong, nonatomic) IBOutlet UILabel *videoLength;

@end
