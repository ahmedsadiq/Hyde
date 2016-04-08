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
@interface CommentsVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,AVAudioRecorderDelegate>
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
    IBOutlet UIView *cointerView;
    IBOutlet UILabel *likes;
    IBOutlet UILabel *views;
    IBOutlet UILabel *replies;
    IBOutlet UIButton *editButto;
    NSUInteger currentIndex;
    IBOutlet UIButton *likeBtn;
    NSMutableArray *videoObj;
    BOOL uploadBeamTag;
    BOOL uploadAnonymous;
    IBOutlet UIView *editView;
    NSString *video_duration;
    NSData *movieData;
    NSData *profileData; // for Thumbnail selected
    NSData *audioData;
    IBOutlet UIButton *closeBtnAudio;
    NSTimer *timerToupdateLbl;
    BOOL isRecording;
    NSTimer* audioTimeOut;
    IBOutlet UILabel *countDownlabel;
    IBOutlet UIImageView *audioBtnImage;
    int secondsLeft;
    NSString *secondsConsumed;
    IBOutlet UIView *bottomBarView;
    UIImage *thumbnailToUpload;
    UIGestureRecognizer *tapper;
    IBOutlet UIImageView *editImage;
    CGFloat tableHeight;
}
@property (strong, nonatomic) CommentsModel *commentsObj;
@property (strong, nonatomic) VideoModel *postArray;
@property (strong, nonatomic) NSString *cPostId;
@property (nonatomic) BOOL isComment;
@property (nonatomic) BOOL isFirstComment;

@property (weak, nonatomic) IBOutlet UIButton *audioRecordBtn;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) IBOutlet UIView *uploadAudioView;
- (IBAction)editBtnPressed:(id)sender;
- (IBAction)likeComment:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)MainPlayBtn:(id)sender;
- (IBAction)CancelEditBtn:(id)sender;
- (IBAction)ReportBtn:(id)sender;
- (IBAction)BlockPerson:(id)sender;
- (IBAction)beamPressed:(id)sender;
- (IBAction)RecorderPressed:(id)sender;
- (IBAction)AudioClosePressed:(id)sender;
@end
