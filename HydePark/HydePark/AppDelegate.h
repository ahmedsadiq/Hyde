//
//  AppDelegate.h
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>

@class ViewController;
@class HomeVC;

#define kSocialAccountTypeKey @"SOCIAL_ACCOUNT_TYPE"

extern NSString * const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property ( strong , nonatomic ) UINavigationController *navigationController;
@property ( strong , nonatomic ) ViewController *viewController;

@property ( strong , nonatomic ) HomeVC *HomeVC;
@property BOOL loaduserProfiel;
@property int userToView;
@property BOOL isLoggedIn;

@property int user_id;
@property (strong, nonatomic) NSString *profile_pic_url;
@property (strong, nonatomic) NSString *strUserId;
@property (strong, nonatomic) NSString *strSocial;
@property (strong, nonatomic) NSString *strFirstN;
@property (strong, nonatomic) NSString *strLastN;
@property (strong, nonatomic) NSString *strEmail;
@property (strong, nonatomic) NSString *strProfileImage;
@property BOOL IS_celeb;


@property (nonatomic, retain) NSString *videotoPlay;
@property (nonatomic, retain) NSString *videotitle;
@property (nonatomic, retain) NSString *videotags;
@property (nonatomic, retain) NSString *videoUploader;
@property (nonatomic, retain) NSString *currentScreen;


@property (strong, nonatomic) FBSession *loggedInSession;


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@end

