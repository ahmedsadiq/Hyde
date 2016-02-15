//
//  DrawerVC.h
//  HydePark
//
//  Created by Mr on 22/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

enum {
    
    OFF_HIDDEN = 0,
    ON_SCREEN = 1,
    
};
typedef NSUInteger CurrentState;


@interface DrawerVC : UIViewController{
    UIView *parentView;
    CurrentState _currentState;

    AppDelegate *appDelegate;
    
     IBOutlet UIButton *removeBtn;
    
    IBOutlet UIButton *homeBtn;
    IBOutlet UIButton *myBeamBtn;
    IBOutlet UIButton *meassagesBtn;
    IBOutlet UIButton *notificationsBtn;
    IBOutlet UIButton *profileBtn;
    IBOutlet UIButton *topicsBtn;
    IBOutlet UIButton *settingsBtn;
    IBOutlet UIButton *logoutBtn;
    
}
@property CurrentState _currentState;

@property ( strong , nonatomic ) UINavigationController *navigationController;

+(DrawerVC *)getInstance;
-(void)AddInView:(UIView *)parentView;
-(void)ShowInView;

-(IBAction)generalAction:(id)sender;
- (IBAction)Home:(id)sender;
- (IBAction)MyBeam:(id)sender;
- (IBAction)Messages:(id)sender;
- (IBAction)Notification:(id)sender;
- (IBAction)Profile:(id)sender;
- (IBAction)Topics:(id)sender;
- (IBAction)Settings:(id)sender;
- (IBAction)Logout:(id)sender;
- (IBAction)WhotoFollow:(id)sender;


@end
