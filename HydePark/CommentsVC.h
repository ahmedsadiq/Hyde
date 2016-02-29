//
//  CommentsVC.h
//  HydePark
//
//  Created by Apple on 18/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentsModel.h"
#import "AppDelegate.h"
#import "AVFoundation/AVFoundation.h"
#import "AsyncImageView.h"
#import "VideoModel.h"
@interface CommentsVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *commentsTable;
    AppDelegate *appDelegate;
    NSUInteger currentSelectedIndex;
    NSString *postID;
    NSString *ParentCommentID;
    CommentsModel *CommentsModelObj;
    VideoModel *videoModel;
    NSArray *CommentsArray;
    IBOutlet AsyncImageView *coverimgComments;
    IBOutlet AsyncImageView *UserImg;
    IBOutlet UILabel *Postusername;
    IBOutlet UILabel *videoLengthComments;
    IBOutlet UILabel *titleComments;
    
}
@property (strong, nonatomic) CommentsModel *commentsObj;
@property (strong, nonatomic) VideoModel *postArray;

- (IBAction)back:(id)sender;
- (IBAction)MainPlayBtn:(id)sender;
@end
