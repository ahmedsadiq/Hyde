//
//  ViewController.h
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "AppDelegate.h"
#import "SVProgressHUDCustom.h"
@class SA_OAuthTwitterEngine;


@interface ViewController : UIViewController<UITextFieldDelegate,FBLoginViewDelegate,GPPSignInDelegate>{

    
    SVProgressHUDCustom *SVCustom;
    IBOutlet UIScrollView *socialScrollview;
    
    IBOutlet UIView *walkthrough;
    IBOutlet UIImageView *socialBgimg;
    IBOutlet UIImageView *logo;
    IBOutlet UIImageView *logo1;
    IBOutlet UIImageView *logo2;
    
    __weak IBOutlet UIImageView *dot;
    GPPSignIn *signIn;
    
    IBOutlet UIButton *btnStarted;
    IBOutlet UIView *LoginTabLine;
    IBOutlet UIView *socialTabLine;
    IBOutlet UIView *viewTabline;
    IBOutlet UIView *socialLoginView;
      AppDelegate *appfbLogin;
      AppDelegate *appDelegate;
}
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UIButton *gplusbtn;
@property (weak, nonatomic) IBOutlet UIButton *fbbtn;

@property BOOL isFBActiveSession;

- (IBAction)getStarted:(id)sender;

@property (strong, nonatomic) FBSession *loggedInSession;

@property (strong, nonatomic) IBOutlet UIView *socialLogin;
- (IBAction)gplusLogin:(id)sender;
- (IBAction)fbLogin:(id)sender;
- (IBAction)twitterLogin:(id)sender;
- (IBAction)switchtoCustomLogin:(id)sender;
- (IBAction)InstagramLogin:(id)sender;


@property (strong, nonatomic) IBOutlet UIView *CustomLoginView;
- (IBAction)switchtoSocialLogin:(id)sender;

- (IBAction)LoginPressed:(id)sender;
- (IBAction)ForgetPasswordPressed:(id)sender;
- (IBAction)SignupPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *txtEmailField;

@property (strong, nonatomic) IBOutlet UITextField *txtPassword;

@property (strong, nonatomic) IBOutlet UIView *ForgetPasswordView;
@property (strong, nonatomic) IBOutlet UITextField *txtForgetEmailField;
- (IBAction)ResetPressed:(id)sender;
- (IBAction)backtoLoginview:(id)sender;


@property int user_id;

@property (strong, nonatomic) NSString *profile_pic_url;
@property (strong, nonatomic) NSString *strUserId;
@property (strong, nonatomic) NSString *strSocial;
@property (strong, nonatomic) NSString *strFirstN;
@property (strong, nonatomic) NSString *strLastN;
@property (strong, nonatomic) NSString *strEmail;
@property (strong, nonatomic) NSString *strGender;


@end
