//
//  VideoPlayerVC.h
//  HydePark
//
//  Created by Apple on 25/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CommentsModel.h"
#import "VideoModel.h"
@interface VideoPlayerVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *VideoPLayerTable;
    IBOutlet UILabel *scrollup;
    IBOutlet UILabel *scrollDown;
    IBOutlet UILabel *titleLbl;
    NSMutableDictionary *cache;
    NSUInteger currentSelectedIndex;
    NSString *postID;
    NSString *ParentCommentID;
    CommentsModel *CommentsModelObj;
    NSArray *CommentsArray;
    VideoModel *videoModel;
    NSString *oldId;
    BOOL isloadingOfCells;
    NSMutableArray *playerArray;
    CGRect frameForSix;
    NSInteger indexToPlay;
    AppDelegate *appDelegate;
}
@property (strong, nonatomic) NSMutableArray *videoObjs;
@property (nonatomic) NSUInteger indexToDisplay;
@property (nonatomic) BOOL isComment;
@property (strong, nonatomic) NSString *cPostId;
@property (nonatomic) BOOL isFirst;
@end
