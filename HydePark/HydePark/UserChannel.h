//
//  UserChannel.h
//  HydePark
//
//  Created by Apple on 22/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "ViewController.h"
#import "UserChannelModel.h"
#import "VideoModel.h"
#import "CommentsModel.h"
@interface UserChannel : ViewController<UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITableView *friendsChannelTable;
    IBOutlet UIView *FriendsProfileView;
    IBOutlet UILabel *friendsFollowings;
    IBOutlet UILabel *friendsFollowers;
    IBOutlet UILabel *friendsBeamcount;
    IBOutlet UIButton *friendsStatusbtn;
    IBOutlet UIImageView *friendsCover;
    IBOutlet UIImageView *friendsImage;
    IBOutlet UILabel *friendsNamelbl;
    NSUInteger currentSelectedIndex;
    NSString *friendId;
    VideoModel *videomodel;
    NSString *postID;
    NSString *ParentCommentID;
    CommentsModel *CommentsModelObj;
    NSArray *arrImages;
    NSArray *arrThumbnail;
    NSArray *CommentsArray;
    NSArray *commentsVideosArray;
    NSUInteger currentIndex;
    NSMutableArray *videoObj;
    NSArray *FollowingsArray;
    NSMutableArray *FollowingsAM;
}
- (IBAction)getFollowings:(id)sender;
- (IBAction)getFollowers:(id)sender;
@property (strong, nonatomic) UserChannelModel *ChannelObj;
@end
