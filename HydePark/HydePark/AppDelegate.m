//
//  AppDelegate.m
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Constants.h"
#import "HomeVC.h"
#import "NavigationHandler.h"


@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize viewController,navigationController,loggedInSession = _loggedInSession,strEmail,strFirstN,strLastN,strUserId,user_id,isLoggedIn,videotoPlay,videotitle,videotags,videoUploader,IS_celeb,currentScreen,commentObj,hasBeenUpdated,hasBlockedSomeOne,hasbeenEdited,emailGPLus;

NSString *const FBSessionStateChangedNotification = @"FBSessionStateChangedNotification";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [NSThread sleepForTimeInterval:2.0];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    NavigationHandler *navHandler = [[NavigationHandler alloc] initWithMainWindow:self.window];
    [navHandler loadFirstVC];
    
    [self.window makeKeyAndVisible];
    [FBLoginView class];
    
    return YES;
}


#pragma mark - Twitter SDK
- (void)getTwitterAccountOnCompletion:(void (^)(ACAccount *))completionHandler {
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [store requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            // Remember that twitterType was instantiated above
            NSArray *twitterAccounts = [store accountsWithAccountType:twitterType];
            
            // If there are no accounts, we need to pop up an alert
            if(twitterAccounts == nil || [twitterAccounts count] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts"
                                                                message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
            } else {
                //Get the first account in the array
                ACAccount *twitterAccount = [twitterAccounts objectAtIndex:0];
                //Save the used SocialAccountType so it can be retrieved the next time the app is started.
                
                //Call the completion handler so the calling object can retrieve the twitter account.
                completionHandler(twitterAccount);
            }
        }
    }];
    
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                
                [FBRequestConnection
                 startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                   NSDictionary<FBGraphUser> *user,
                                                   NSError *error) {
                     if (!error) {
                         self.loggedInSession = FBSession.activeSession;
                     }
                 }];
            
            break;
            }
        case FBSessionStateClosed:
        {
                break;
        }
        case FBSessionStateClosedLoginFailed:
        {
            [FBSession.activeSession closeAndClearTokenInformation];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"BackToHydePark"
             object:nil];
        }
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        
        
        //When cancel button is pressed on fb login view
        
        //        UIAlertView *alertView = [[UIAlertView alloc]
        //                                  initWithTitle:@"Error"
        //                                  message:error.localizedDescription
        //                                  delegate:nil
        //                                  cancelButtonTitle:@"OK"
        //                                  otherButtonTitles:nil];
        //        [alertView show];
    }
}


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray * permissions = [[NSArray alloc] initWithObjects:@"publish_actions",@"email",@"user_about_me",@"user_friends",@"user_location",@"user_birthday",@"public_profile", nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session state:state error:error];
                                         }];
    
    
    //        FBLoginView *loginView =
    //        [[FBLoginView alloc] initWithReadPermissions:@[@"Public_profile", @"email", @"user_likes"]];
}
- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([_strSocial isEqualToString:@"Facebook"]){
        
        return [FBSession.activeSession handleOpenURL:url];
        
    } if ([_strSocial isEqualToString:@"GPlus"]) {
        return [GPPURLHandler handleURL:url
                      sourceApplication:sourceApplication
                             annotation:annotation];
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the 
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if (FBSession.activeSession.state == FBSessionStateCreatedOpening) {
        [FBSession.activeSession close];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

@end
