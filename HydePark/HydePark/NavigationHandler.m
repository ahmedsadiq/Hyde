//
//  NavigationHandler.m
//  Yolo
//
//  Created by Salman Khalid on 13/06/2014.
//  Copyright (c) 2014 Xint Solutions. All rights reserved.
//

#import "NavigationHandler.h"
#import "HomeVC.h"
#import "Constants.h"
#import "ViewController.h"
#import "Topics.h"
#import "MyBeam.h"
#import "VideoPlayer.h"
#import "SignUpVC.h"
#import "ProfileVC.h"
#import "NotificationsVC.h"
#import "SearchFriendsVC.h"
#import "Constants.h"
#import "Utils.h"
#import "SVProgressHUD.h"
#import "PopularUsersVC.h"
#import "CommentsVC.h"
@implementation NavigationHandler

- (id)initWithMainWindow:(UIWindow *)_tempWindow{
    
    if(self = [super init])
    {
        _window = _tempWindow;
    }
    instance = self;
    return self;
}

static NavigationHandler *instance= NULL;

+(NavigationHandler *)getInstance
{
    if (instance == nil) {
        instance = [[super alloc] init];
    }
    
    return instance;
}

-(void)loadFirstVC{
    
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    HomeVC *homeVC1 = [[HomeVC alloc] init];
    navController = [[UINavigationController alloc] initWithRootViewController:homeVC1];
    
    _window.rootViewController = navController;
    [navController setNavigationBarHidden:YES];
    
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"logged_in"])
    {
        HomeVC *homeVC1 = [[HomeVC alloc] init];
        navController = [[UINavigationController alloc] initWithRootViewController:homeVC1];
        
        _window.rootViewController = navController;
        [navController setNavigationBarHidden:YES];
        
    }
    //    else{
    //        TutorialViewController *_mainVC = [[TutorialViewController alloc] init];
    //        navController = [[UINavigationController alloc] initWithRootViewController:_mainVC];
    //        _window.rootViewController = navController;
    //        [navController setNavigationBarHidden:YES];
    //    }
    else{
        
        ViewController *_mainVC = [[ViewController alloc] init];
        navController = [[UINavigationController alloc] initWithRootViewController:_mainVC];
        _window.rootViewController = navController;
        [navController setNavigationBarHidden:YES];
    }
}

-(void)NavigateToHomeScreen{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"newSignup"]) {
        
        PopularUsersVC *users = [[PopularUsersVC alloc] init];
        navController = [[UINavigationController alloc] initWithRootViewController:users];
        _window.rootViewController = navController;
        [navController setNavigationBarHidden:YES];
        
    }else{
        
        navController = nil;
        if (IS_IPAD) {
            
            HomeVC *homeVC1 = [[HomeVC alloc] initWithNibName:@"HomeVC_iPad" bundle:nil];
            navController = [[UINavigationController alloc] initWithRootViewController:homeVC1];
        }
        
        else{
            
            HomeVC *homeVC2 = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
            navController = [[UINavigationController alloc] initWithRootViewController:homeVC2];
        }
        _window.rootViewController = navController;
        [navController setNavigationBarHidden:YES];
    }
    
}

-(void)NavigateToLoginScreen{
    
    navController = nil;
    if (IS_IPAD) {
        
        ViewController *LoginVC1 = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
        navController = [[UINavigationController alloc] initWithRootViewController:LoginVC1];
    }
    
    else{
        
        ViewController *LoginVC2 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
        navController = [[UINavigationController alloc] initWithRootViewController:LoginVC2];
        
        [navController popToViewController:LoginVC2 animated:YES];
    }
    
    _window.rootViewController = navController;
    [navController setNavigationBarHidden:YES];
    
}

-(void)NavigateToSignUpScreen{
    
    [navController popToRootViewControllerAnimated:YES];
    
    if (IS_IPAD) {
        
        SignUpVC *_main1 = [[SignUpVC alloc] initWithNibName:@"SignUpVC_iPad" bundle:nil];
        [navController pushViewController:_main1 animated:YES];
    }else {
        SignUpVC *_main2 = [[SignUpVC alloc] initWithNibName:@"iPhone_5_6" bundle:nil];
        [navController pushViewController:_main2 animated:YES];
    }
    
    
}
-(void)MoveToTopics{
    
    [navController popToRootViewControllerAnimated:NO];
    
    if (IS_IPAD)
    {
        
        Topics *topic = [[Topics alloc] initWithNibName:@"Topics_iPad" bundle:nil];
        [navController pushViewController:topic animated:YES];
    }
    
    else
    {
        
        Topics *topic1 = [[Topics alloc] initWithNibName:@"Topics" bundle:nil];
        [navController pushViewController:topic1 animated:YES];
        
    }
    
}

-(void)MoveToMyBeam{
    [navController popToRootViewControllerAnimated:NO];
    if (IS_IPAD) {
        
        MyBeam *myBeam = [[MyBeam alloc] initWithNibName:@"MyBeam_iPad" bundle:nil];
        [navController pushViewController:myBeam animated:YES];
    }
    else{
        
        MyBeam *myBeam = [[MyBeam alloc] initWithNibName:@"MyBeam" bundle:nil];
        [navController pushViewController:myBeam animated:YES];
    }
}

-(void)NavigateToRoot{
    
    [navController popToRootViewControllerAnimated:YES];
}

-(void)MoveToPlayer{
    
    //[navController popToRootViewControllerAnimated:YES];
    if (IS_IPAD) {
        
        VideoPlayer *myBeam = [[VideoPlayer alloc] initWithNibName:@"VideoPlayer" bundle:nil];
        [navController pushViewController:myBeam animated:YES];
    }
    else{
        
        VideoPlayer *myBeam = [[VideoPlayer alloc] initWithNibName:@"VideoPlayer" bundle:nil];
        [navController pushViewController:myBeam animated:YES];
    }
}
-(void)MoveToProfile{
    
    [navController popToRootViewControllerAnimated:NO];
    if (IS_IPAD) {
        
        ProfileVC *myBeam = [[ProfileVC alloc] initWithNibName:@"ProfileVC_iPad" bundle:nil];
        [navController pushViewController:myBeam animated:YES];
    }
    else{
        
        ProfileVC *myBeam = [[ProfileVC alloc] initWithNibName:@"ProfileVC" bundle:nil];
        [navController pushViewController:myBeam animated:YES];
    }
}
-(void)MoveToComments{
    
    [navController popToRootViewControllerAnimated:NO];
    //    if (IS_IPAD) {
    //
    //        ProfileVC *myBeam = [[ProfileVC alloc] initWithNibName:@"ProfileVC_iPad" bundle:nil];
    //        [navController pushViewController:myBeam animated:YES];
    //    }
    //    else{
    //
    CommentsVC *myBeam = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
    [navController pushViewController:myBeam animated:YES];
}

-(void)MoveToNotifications{
    
    [navController popToRootViewControllerAnimated:NO];
    if (IS_IPAD) {
        
        NotificationsVC *notification = [[NotificationsVC alloc] initWithNibName:@"NotificationsVC_iPad" bundle:nil];
        [navController pushViewController:notification animated:YES];
    }
    else{
        
        NotificationsVC *notification = [[NotificationsVC alloc] initWithNibName:@"NotificationsVC" bundle:nil];
        [navController pushViewController:notification animated:YES];
    }
}

-(void)MoveToSearchFriends{
    
    [navController popToRootViewControllerAnimated:NO];
    if (IS_IPAD) {
        
        SearchFriendsVC *search = [[SearchFriendsVC alloc] initWithNibName:@"SearchFriendsVC_iPad" bundle:nil];
        [navController pushViewController:search animated:NO];
    }
    else{
        
        SearchFriendsVC *search = [[SearchFriendsVC alloc] initWithNibName:@"SearchFriendsVC" bundle:nil];
        [navController pushViewController:search animated:NO];
    }
}

-(void)MoveToPopularUsers{
    
    [navController popToRootViewControllerAnimated:NO];
    if (IS_IPAD) {
        
        PopularUsersVC *users = [[PopularUsersVC alloc] initWithNibName:@"PopularUsersVC_iPad" bundle:nil];
        [navController pushViewController:users animated:YES];
    }else if(IS_IPHONE_6 || IS_IPHONE_5){
        
        PopularUsersVC *users = [[PopularUsersVC alloc] initWithNibName:@"PopularUsersVC_iPhone6" bundle:nil];
        [navController pushViewController:users animated:YES];
    }
    
    else{
        
        PopularUsersVC *users = [[PopularUsersVC alloc] initWithNibName:@"PopularUsersVC" bundle:nil];
        [navController pushViewController:users animated:YES];
    }
}
-(void)LogoutUser{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_LOGOUT,@"method",
                              token,@"Session_token",uniqueIdentifier,@"device_id", nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            [SVProgressHUD dismiss];
            int success = [[result objectForKey:@"success"] intValue];
            
            NSString *message = [result objectForKey:@"message"];
            if(success == 1) {
                //Navigate to Login Screen
                appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                appDelegate.isLoggedIn = false;
                
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"logged_in"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self NavigateToLoginScreen];
            }
            [self NavigateToLoginScreen];
        }
        else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
    
    
}



@end
