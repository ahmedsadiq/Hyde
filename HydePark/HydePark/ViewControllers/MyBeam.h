//
//  MyBeam.h
//  HydePark
//
//  Created by Mr on 22/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myBeamsModel.h"
#import "AppDelegate.h"
#import "AsyncImageView.h"
#import "CommentsModel.h"

@interface MyBeam : UIViewController<UITableViewDelegate,UITableViewDataSource>
{

    myBeamsModel *mybeamsObj;
    AppDelegate *appDelegate;
    CommentsModel *CommentsModelObj;
    
    NSUInteger currentSelectedIndex;
    
    
    NSString *postID;
    NSString *ParentCommentID;
    
    BOOL liked;
    BOOL seenPost;
    
    NSArray *beamsArray;
    NSArray *videosArray;
    NSArray *ArrayForSearch;
    NSArray *arrImages;
    NSArray *arrThumbnail;
    NSArray *CommentsArray;
    NSArray *commentsVideosArray;
    
    NSIndexPath* index;
    UIView *overlayView;
    
#pragma mark Commentsview
    
    IBOutlet UITableView *commentsTable;
    IBOutlet UIView *commentsView;
    
    IBOutlet AsyncImageView *userImage;
    IBOutlet AsyncImageView *coverimgComments;
    
    IBOutlet UILabel *videoTitleComments;
    IBOutlet UILabel *usernameCommnet;
    IBOutlet UILabel *likeCountsComment;
    IBOutlet UILabel *seencountcomment;
    IBOutlet UILabel *commentsCountCommnetview;
    IBOutlet UILabel *videoLengthComments;
    
    int pageNum;
    int searchPageNum;
    BOOL cannotScroll;
    BOOL goSearch;
    
}
@property (strong, nonatomic) IBOutlet UITableView *TableBeams;
@property (strong, nonatomic) IBOutlet UIView *optionsView;
@property (nonatomic, assign) BOOL isMenuVisible;

- (IBAction)backBtn:(id)sender;
- (IBAction)showDrawer:(id)sender;
- (IBAction)showHidesearchbar:(id)sender;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)CommentsBack:(id)sender;

- (IBAction)editBtn:(id)sender;
- (IBAction)DeleteBtn:(id)sender;



@end
