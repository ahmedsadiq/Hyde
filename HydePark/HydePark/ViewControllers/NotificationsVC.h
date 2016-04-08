//
//  NotificationsVC.h
//  HydePark
//
//  Created by Mr on 15/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationsModel.h"
#import "ASIFormDataRequest.h"
#import "UserChannelModel.h"
#import "VideoModel.h"
#import "CommentsModel.h"
@interface NotificationsVC : UIViewController<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate>
{
    
    IBOutlet UITableView *notificationsTbl;
    NSUInteger currentSelectedIndex;
    NotificationsModel *notifModel;
    NSArray *notificationsArray;
    NSString *friendID;
#pragma mark -UserChannelrrays
    NSArray *chPostArray;
    NSArray *chVideosArray;
    NSArray *chArrImage;
    NSArray *chArrThumbnail;
    UserChannelModel *userChannelObj;
    CommentsModel *CommentsModelObj;
    VideoModel *videomodel;
    VideoModel *videoCommentModel;
    NSArray *arrImages;
    NSArray *arrThumbnail;
    NSArray *CommentsArray;
    NSArray *commentsVideosArray;
    NSString *postID;
    NSString *ParentCommentID;
    IBOutlet UIView *blockerView;
#pragma mark pagination
    BOOL serverCall;
    BOOL goSearch;
    BOOL cannotScroll;
    int pageNum;
    int searchPageNum;
}
- (IBAction)back:(id)sender;
@end
