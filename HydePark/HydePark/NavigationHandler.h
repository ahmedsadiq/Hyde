//
//  NavigationHandler.h
//  Yolo
//
//  Created by Salman Khalid on 13/06/2014.
//  Copyright (c) 2014 Xint Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface NavigationHandler : NSObject{
    
    UINavigationController *navController;
    UIWindow *_window;
    
     AppDelegate *appDelegate;
}

-(id)initWithMainWindow:(UIWindow *)_tempWindow;
-(void)loadFirstVC;

+(NavigationHandler *)getInstance;
-(void)NavigateToHomeScreen;
-(void)NavigateToLoginScreen;

-(void)MoveToMyBeam;
-(void)NavigateToSignUpScreen;
-(void)NavigateToRoot;
-(void)MoveToTopics;
-(void)MoveToPlayer;
-(void)MoveToProfile;
-(void)MoveToNotifications;
-(void)MoveToSearchFriends;
-(void)MoveToPopularUsers;
-(void)LogoutUser;

@end
