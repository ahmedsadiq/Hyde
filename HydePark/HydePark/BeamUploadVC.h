//
//  BeamUploadVC.h
//  HydePark
//
//  Created by Apple on 21/03/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
@interface BeamUploadVC : ViewController<UIScrollViewDelegate>
{
    IBOutlet UILabel *everyOnelbl;
    IBOutlet UILabel *onlyMelbl;
    IBOutlet UILabel *Friendslbl;
    IBOutlet UILabel *Unlimited;
    IBOutlet UILabel *noreplies;
    IBOutlet UILabel *upto60;
    IBOutlet UIView *blockerView;
    IBOutlet UIImageView *cpeveryone;
    IBOutlet UIImageView *cponlyme;
    IBOutlet UIImageView *cpfriends;
    IBOutlet UIImageView *up60;
    IBOutlet UIImageView *noreply;
    IBOutlet UIImageView *unlimited;
    BOOL uploadBeamTag;
    BOOL uploadAnonymous;
    NSString *IS_mute;
    NSString *commentAllowed;
    NSString *privacySelected;
    BOOL changeColorForTag;
    NSDictionary *normalAttrdict;
    NSDictionary *highlightAttrdict;
    BOOL isFirstTimeClicked;
    NSString *tagsString;
    NSString *is_Anonymous;
    AppDelegate *apDelegate;
    UIGestureRecognizer *tepper;
    IBOutlet UIView *upperView;
    CGRect frameBeamscroller;
}
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton *CPEveryone;
@property (weak, nonatomic) IBOutlet UIButton *CPOnlyMe;
@property (weak, nonatomic) IBOutlet UIButton *CPFriends;
@property (weak, nonatomic) IBOutlet UIButton *upto60Comments;
@property (weak, nonatomic) IBOutlet UIButton *NoRepliesbtn;
@property (weak, nonatomic) IBOutlet UIButton *unlimitedRepliesbtn;
@property (weak, nonatomic) IBOutlet UIScrollView *uploadbeamScroller;
@property (weak, nonatomic) IBOutlet UITextView *statusText;

@property (nonatomic) UIImage *thumbnailImage;
@property (nonatomic) BOOL isAnonymous;
@property (nonatomic) BOOL isAudio;
@property (nonatomic) BOOL isComment;
@property (strong,nonatomic) NSData *dataToUpload;
@property (strong,nonatomic) NSData *profileData;
@property (strong,nonatomic) NSString *postID;
@property (strong,nonatomic) NSString *ParentCommentID;
@property (strong,nonatomic) NSString *video_duration;
@property (strong,nonatomic) NSString *video_thumbnail;

- (IBAction)uploadBeamBackPressed:(id)sender;
- (IBAction)uploadBeamPressed:(id)sender;
- (IBAction)PrivacyEveryOne:(id)sender;
- (IBAction)PrivacyOnlyMe:(id)sender;
- (IBAction)PrivacyFriends:(id)sender;
- (IBAction)upto60Pressed:(id)sender;
- (IBAction)noRepliesPressed:(id)sender;
- (IBAction)UnlimitedPressed:(id)sender;
@end
