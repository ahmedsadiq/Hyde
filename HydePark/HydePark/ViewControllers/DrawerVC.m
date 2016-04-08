//
//  DrawerVC.m
//  HydePark
//
//  Created by Mr on 22/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "DrawerVC.h"
#import "Utils.h"
#import "HomeVC.h"
#import "MyBeam.h"
#import "Topics.h"
#import "NavigationHandler.h"
#import "ProfileVC.h"
#import "Constants.h"

@interface DrawerVC ()

@end

static DrawerVC *DrawerVC_Instance= NULL;

@implementation DrawerVC

@synthesize _currentState;
float _yLocation;

+(DrawerVC *)getInstance{
    
    if(DrawerVC_Instance == NULL)
    {
        if (IS_IPAD){
            DrawerVC_Instance = [[DrawerVC alloc] initWithNibName:@"DrawerVC_iPad" bundle:nil];
            _yLocation = 0.0f;
        }
        
        else{
            DrawerVC_Instance = [[DrawerVC alloc] initWithNibName:@"DrawerVC" bundle:nil];
            _yLocation = 0.0f;
        }
    }
    return DrawerVC_Instance;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _currentState = OFF_HIDDEN;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (IS_IPHONE_6 ) {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 667);
    }else if (IS_IPHONE_5){
    
    }
    else if (IS_IPHONE_6Plus){
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 736)];
    }
    DrawerVC_Instance = self;
    removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeBtn setFrame:CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height)];
    [removeBtn addTarget:self action:@selector(ShowInView) forControlEvents:UIControlEventTouchUpInside];
}

-(void)AddInView:(UIView *)_parentView{
    parentView = _parentView;
    
    //if(_currentState == OFF_HIDDEN)
        //        [self.view setFrame:CGRectMake(parentView.frame.size.width, _yLocation, self.view.frame.size.width, self.view.frame.size.height)];
        if (IS_IPAD) {
            [self.view setFrame:CGRectMake(-424, _yLocation, self.view.frame.size.width, parentView.frame.size.height -_yLocation)];
        }else{
            
            [self.view setFrame:CGRectMake(-280, _yLocation, self.view.frame.size.width, self.view.frame.size.height)];
            if (IS_IPHONE_6) {
                [self.view setFrame:CGRectMake(-298, _yLocation, self.view.frame.size.width, self.view.frame.size.height)];
            }
        }
    [_parentView addSubview:self.view];

}
-(void)ShowInView{
    if(_currentState == OFF_HIDDEN)
    {
        [UIView transitionWithView:self.view duration:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            _currentState = ON_SCREEN;
            
            // final view elements attributes goes here
            // [self.view setFrame:CGRectMake(parentView.frame.size.width - self.view.frame.size.width, _yLocation, self.view.frame.size.width, parentView.frame.size.height-_yLocation)];
            [self.view setFrame:CGRectMake(0, _yLocation, self.view.frame.size.width, parentView.frame.size.height-_yLocation)];
            
            [parentView addSubview:removeBtn];
            [parentView bringSubviewToFront:self.view];
            
            
        } completion:nil];
    }
    
    else if(_currentState == ON_SCREEN)
    {
        [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            _currentState = OFF_HIDDEN;
            //[[parentView viewWithTag:HIDE_TAG] removeFromSuperview];
            
            // final view elements attributes goes here
            // [self.view setFrame:CGRectMake(parentView.frame.size.width, _yLocation, self.view.frame.size.width, parentView.frame.size.height -_yLocation)];
            if (IS_IPAD) {
                [self.view setFrame:CGRectMake(-424, _yLocation, self.view.frame.size.width, parentView.frame.size.height -_yLocation)];
            }else{
                [self.view setFrame:CGRectMake(-280, _yLocation, self.view.frame.size.width, parentView.frame.size.height -_yLocation)];
                if (IS_IPHONE_6) {
                    [self.view setFrame:CGRectMake(-298 , _yLocation, self.view.frame.size.width, self.view.frame.size.height)];
                }
            }
            [removeBtn removeFromSuperview];
            
        } completion:nil];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)generalAction:(id)sender{
    
    [self ShowInView];
}


- (IBAction)Home:(id)sender {

    [[NavigationHandler getInstance]NavigateToHomeScreen];
}

- (IBAction)MyBeam:(id)sender {

   [[NavigationHandler getInstance]MoveToMyBeam];
    
}

- (IBAction)Messages:(id)sender {
    
}

- (IBAction)Notification:(id)sender {
    [[NavigationHandler getInstance]MoveToNotifications];
}

- (IBAction)Profile:(id)sender {
    [[NavigationHandler getInstance]MoveToProfile];
   
}

- (IBAction)Topics:(id)sender {
    
    [[NavigationHandler getInstance]MoveToTopics];
}

- (IBAction)Settings:(id)sender {
}

- (IBAction)Logout:(id)sender {
      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"logged_in"];
    
    [[NavigationHandler getInstance]LogoutUser];
}

- (IBAction)WhotoFollow:(id)sender {
    
    [[NavigationHandler getInstance]MoveToPopularUsers];
}
@end
