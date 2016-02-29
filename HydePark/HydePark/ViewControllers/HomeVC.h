//
//  HomeVC.h
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCell.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "ASIFormDataRequest.h"
#import "AGEmojiKeyBoardView.h"
#import "GetTrendingVideos.h"
#import "AppDelegate.h"
#import "myChannelModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PopularUsersModel.h"
#import "UserChannelModel.h"
#import "CommentsModel.h"
#import "ProfileModel.h"
#import "SVProgressHUDCustom.h"
#import "Followings.h"
#import "AVFoundation/AVFoundation.h"
#import "VideoModel.h"

@class RadioButton;

typedef enum enumStates{
    CurrentImageCategoryCover = 0,
    CurrentImageCategoryUpload = 1,
    uploadBeamFromGallery,
    CurrentImageCategoryBeam,
    CurrentImageCategoryCommentPhoto,
    VideoOnCommentsGallery
    
}CurrentImageCategory;
@interface HomeVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate,ASIHTTPRequestDelegate,UITextViewDelegate,AGEmojiKeyboardViewDelegate,AGEmojiKeyboardViewDataSource, UIAlertViewDelegate,MPMediaPickerControllerDelegate,AVAudioRecorderDelegate>

{
    ProfileModel *ProfileObj;
    ASIFormDataRequest *requestc;
    SVProgressHUDCustom *SVCustom;
    UIButton *_selectedButtonCover;
    UIButton *_selectedButtonImage;
    IBOutlet UIView *searchView;
    IBOutlet UITableView *searchTable;
    UITableView *tableView;
    IBOutlet UIView *tagFriendsView;
    
    IBOutlet UIButton *Cm_VideoPlay;
    IBOutlet UIView *noBeamsView;
    
    NSArray *usersArray;
    NSArray *arrImages;
    VideoModel *videomodel;
    IBOutlet UIImageView *audioBtnImage;
    NSArray *CommentsArray;
    PopularUsersModel *UsersModel;
    NSString *userStatus;
    NSString *friendId;
    NSString *searchKeyword;
    NSString *UserRelation;
    NSString *ParentCommentID;
    BOOL tabBarIsShown;
    BOOL IsStatus;
    AGEmojiKeyboardView *emojiKeyboardView;
    GetTrendingVideos *getTrendingVideos;
    myChannelModel *myChannelObj;
    UserChannelModel *userChannelObj;
    CommentsModel *CommentsModelObj;
    Followings *getFollowings;
    NSTimer *timerToupdateLbl;
    int secondsLeft;
    IBOutlet UILabel *countDownlabel;
    NSTimer* audioTimeOut;
    NSString *secondsConsumed;
    NSArray *FollowingsArray;
    NSMutableArray *FollowingsAM;
    
    float totalBytestoUpload;
    float totalBytesUploaded;
    BOOL fromPullToRefresh;
    BOOL loadFollowings;
    UIGestureRecognizer *tapper;
    
    NSString *IS_mute;
    NSString *commentAllowed;
    NSString *privacySelected;
    NSString *TopicSelected;
    NSString *videotype;
    NSData *profileData; // for Thumbnail selected
    NSData *audioData;
    IBOutlet UITextField *searchField;
    IBOutlet UITextField *searchField2;
    
    NSArray *ArrayForSearch;
    NSUInteger currentSelectedIndex;
    
    NSArray *trendArray;
    NSArray *videosArray;
    NSArray *arrImage;
    NSArray *arrThumbnail;
    
    NSArray *chPostArray;
    NSArray *chVideosArray;
    NSArray *chArrImage;
    NSArray *chArrThumbnail;
    
    NSArray *newsfeedPostArray;
    NSArray *newsfeedVideosArray;
    NSArray *newsfeedArrImage;
    NSArray *newsfeedArrThumbnail;
    NSDictionary *normalAttrdict;
    NSDictionary *highlightAttrdict;
    NSString *postID;
    BOOL liked;
    BOOL seenPost;
    BOOL changeColorForTag;
    NSUInteger indexForTag;
    NSString *tagsString;
    
    NSUInteger value;
    UILabel *likesCountLbl;
    AppDelegate *appDelegate;
    
    NSMutableArray *arr;
    BOOL isFirstTimeClicked;
    float returnValue;
    int count;
    NSData *movieData;
    NSIndexPath* index;
    NSData *commentImageData;
    
    IBOutlet UILabel *userName;
    IBOutlet AsyncImageView *User_pic;
    IBOutlet UILabel *userBeams;
    
    IBOutlet UILabel *userFriends;
    IBOutlet UILabel *userLikes;
    
    UIImage *thumbnail_BnW_1;
    UIImage *thumbnail_BnW_2;
    UIImage *thumbnail_BnW_3;
    
    UIImage *thumbnail_Color_1;
    UIImage *thumbnail_Color_2;
    UIImage *thumbnail_Color_3;
    UIImage *filteredImage;
    
    IBOutlet UIButton *btnTrending;
    IBOutlet UIButton *btnChannel;
    IBOutlet UIButton *btnHome;
    
    
    IBOutlet UIButton *btnUploadPhoto;
    IBOutlet UIButton *btnUploadVideo;
    IBOutlet UIImageView *beamIcon;
    IBOutlet UIImageView *cameraIcon;
    IBOutlet UILabel *beamLabel;
    IBOutlet UILabel *camLabel;
    
    IBOutlet UIImageView *tabLineChannel;
    IBOutlet UIImageView *tabLineHome;
    IBOutlet UIImageView *tabLineTrending;
    IBOutlet UIView *myChannelView;
    IBOutlet UIView *topTabbar;
    IBOutlet UIView *channelContainerView;
    CGRect channelContainerOriginalFrame;
    CGRect channelTableFrame;
    int channelContainerHeight;
    
    IBOutlet AsyncImageView *channelCover;
    BOOL hasScrolled;
    
    UIView *overlayView;
    
    IBOutlet UIView *topHeader;
    
    CGRect mainScrollerFrame;
    
#pragma mark profileView
    
    IBOutlet UIImageView *backgroundPicture;
    IBOutlet UIImageView *transparentLayer;
    IBOutlet UIImageView *profilePic;
    IBOutlet UIView *layerMiddle;
    IBOutlet UIView *channgelInnerView;
    CGRect originalChannelInnerViewFrame;
    CGRect originalChannelFrame;
    
    
    IBOutlet UIButton *btnBnW;
    IBOutlet UIButton *btnRotate;
    IBOutlet UIButton *btnColour;
    IBOutlet UIView *BeamTypeView;
    IBOutlet UIView *selctBeamSourceView;
    
    NSString *video_duration;
    BOOL SearchforTag;
#pragma mark Friend's Channel
    
    IBOutlet UIView *friendsChannelView;
    IBOutlet UIView *FriendsProfileView;
    
    
    IBOutlet UILabel *friendsFollowings;
    IBOutlet UILabel *friendsFollowers;
    IBOutlet UILabel *friendsBeamcount;
    IBOutlet UIButton *friendsStatusbtn;
    IBOutlet UIImageView *friendsCover;
    IBOutlet UIImageView *friendsImage;
    IBOutlet UILabel *friendsNamelbl;
    IBOutlet UITableView *friendsChannelTable;
    
    
#pragma mark Commentsview
    
    IBOutlet UITableView *commentsTable;
    IBOutlet UIView *commentsView;
    
    IBOutlet AsyncImageView *userImage;
    IBOutlet UILabel *videoTitleComments;
    IBOutlet UILabel *usernameCommnet;
    IBOutlet UILabel *likeCountsComment;
    IBOutlet UILabel *seencountcomment;
    IBOutlet UILabel *commentsCountCommnetview;
    IBOutlet UILabel *videoLengthComments;
    IBOutlet AsyncImageView *coverimgComments;
    
    IBOutlet UIView *uploadimageView;
    
#pragma Upload Beam
    IBOutlet UILabel *everyOnelbl;
    IBOutlet UILabel *onlyMelbl;
    IBOutlet UILabel *Friendslbl;
    
    IBOutlet UILabel *Unlimited;
    IBOutlet UILabel *noreplies;
    IBOutlet UILabel *upto60;
    IBOutlet UIButton *closeBtnAudio;
    CGRect TabBarFrame;
    bool cannotScrollForum;
    bool cannotScrollMyCorner;
    int myCornerPageNum;
    int forumPageNumber;
    BOOL uploadBeamTag;
    BOOL uploadAnonymous;
#pragma Corrections by Ahmed
    NSMutableArray *forumsVideo;
    NSMutableArray *channelVideos;
    NSMutableArray *newsfeedsVideos;
    int currentState;
    int pageNum;
    int searchPageNum;
    BOOL cannotScroll;
    BOOL goSearch;
    BOOL isDownwards;
    BOOL isRecording;
    NSMutableArray *videoObj;
}

- (IBAction)fromCamera:(id)sender;
- (IBAction)fromGallery:(id)sender;
- (IBAction)imagepickerCross:(id)sender;
- (IBAction)RecorderPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *uploadAudioView;
@property (weak, nonatomic) IBOutlet UIButton *audioRecordBtn;
#pragma mark Upload Beam View
@property (strong, nonatomic) IBOutlet UIView *uploadBeamView;
@property (weak, nonatomic) IBOutlet UITextView *statusText;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImg1;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImg2;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImg3;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton *thumbnail1;
@property (weak, nonatomic) IBOutlet UIButton *thumbnail2;
@property (weak, nonatomic) IBOutlet UIButton *thumbnail3;
@property (weak, nonatomic) IBOutlet UIView *emoticonsView;
@property (weak, nonatomic) IBOutlet UILabel *emojiLabel;
///----------pull to refresh
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIRefreshControl *refreshControlHome;
@property (strong, nonatomic) UIRefreshControl *refreshControlChannel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressview;

- (IBAction)thumbnail2Pressed:(id)sender;
- (IBAction)thumbnail3Pressed:(id)sender;
- (IBAction)uploadBeamBackPressed:(id)sender;
- (IBAction)tagFriendsPressed:(id)sender;
- (IBAction)emoticonPressed:(id)sender;
- (IBAction)privacyPressed:(id)sender;
- (IBAction)selectTopicPressed:(id)sender;
- (IBAction)thumbnail1Pressed:(id)sender;
- (IBAction)uploadBeamPressed:(id)sender;
- (IBAction)rotateThumbnails:(id)sender;
- (IBAction)colouredPressed:(id)sender;
- (IBAction)blacknWhitepressed:(id)sender;
- (IBAction)CommentsCountpressed:(id)sender;
- (IBAction)recorderTapped:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *CPEveryone;
@property (weak, nonatomic) IBOutlet UIButton *CPOnlyMe;
@property (weak, nonatomic) IBOutlet UIButton *CPFriends;
@property (weak, nonatomic) IBOutlet UIButton *upto60Comments;
@property (weak, nonatomic) IBOutlet UIButton *NoRepliesbtn;
@property (weak, nonatomic) IBOutlet UIButton *unlimitedRepliesbtn;

- (IBAction)searchFriendsforTag:(id)sender;
- (IBAction)CancelTaging:(id)sender;
- (IBAction)CrossTagView:(id)sender;


@property (nonatomic, assign) BOOL isLoading;
@property (strong, nonatomic) IBOutlet UIButton *muteBtn;
@property (strong, nonatomic) IBOutlet UIButton *commentcountBtn;

-(void)playVideo:(UIButton*)sender;
- (void)Hearts:(UIButton*)sender;
- (void)Flag:(UIButton*)sender;

@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic,assign) CGPoint lastContentPoint;
@property CGFloat previousScrollViewYOffset;
@property (nonatomic, assign) BOOL isMenuVisible;
@property (nonatomic, assign) NSInteger indexOfVisibleController;


@property (strong, nonatomic) IBOutlet UIView *BottomBar;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScroller;
@property (weak, nonatomic) IBOutlet UITableView *forumTable;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *TableHome;
@property (strong, nonatomic) IBOutlet UITableView *TablemyChannel;
@property (strong, nonatomic) IBOutlet UIView *optionsView;
@property (weak, nonatomic) IBOutlet UIScrollView *uploadbeamScroller;

- (IBAction)hideShowsearchbar:(id)sender;
- (IBAction)searchBack:(id)sender;

- (IBAction)ShowDrawer:(id)sender;
- (IBAction)showProfile:(id)sender;

- (IBAction)ChannelPressed:(id)sender;
- (IBAction)TrendingPressed:(id)sender;
- (IBAction)HomePressed:(id)sender;
- (IBAction)backBtn:(id)sender;
- (IBAction)editBtn:(id)sender;
- (IBAction)deleteBtn:(id)sender;

- (IBAction)findFriends:(id)sender;
- (IBAction)PhotoPressed:(id)sender;

- (IBAction)beamPressed:(id)sender;
- (IBAction)NormalBeantypePressed:(id)sender;
- (IBAction)AnonymoueBeamPressed:(id)sender;
- (IBAction)BeamTypeCross:(id)sender;
- (IBAction)recordBeamfromCamera:(id)sender;
- (IBAction)uploadfromGallery:(id)sender;
- (IBAction)uploadSourceCross:(id)sender;

- (IBAction)mute:(id)sender;

@property (strong, nonatomic)IBOutlet RadioButton *radioBtn;

- (IBAction)commentRadio:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *radio1;
@property (strong, nonatomic) IBOutlet UIButton *radio2;
@property (strong, nonatomic) IBOutlet UIButton *radio3;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
- (IBAction)showFollowings:(id)sender;
- (IBAction)showFollowers:(id)sender;

- (IBAction)userChannelBackbtn:(id)sender;
- (IBAction)UserStatusbtnPressed:(id)sender;
- (IBAction)CommentsBack:(id)sender;
- (IBAction)EditCoverImg:(id)sender;
- (IBAction)PhotoOnComments:(id)sender;
- (IBAction)VideoOnCommentsPressed:(id)sender;

- (IBAction)PrivacyEveryOne:(id)sender;
- (IBAction)PrivacyOnlyMe:(id)sender;
- (IBAction)PrivacyFriends:(id)sender;
- (IBAction)upto60Pressed:(id)sender;
- (IBAction)noRepliesPressed:(id)sender;
- (IBAction)UnlimitedPressed:(id)sender;



@end
