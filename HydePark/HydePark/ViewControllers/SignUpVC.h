//
//  SignUpVC.h
//  HydePark
//
//  Created by Mr on 05/05/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIDropDown.h"
#import "SVProgressHUDCustom.h"
@class RadioButton;

@interface SignUpVC : UIViewController<NIDropDownDelegate,UITextFieldDelegate>
{
    IBOutlet UITextField *txtUserName;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    IBOutlet UITextField *txtDisplayName;
    
    NSArray *accountTypes;
    NIDropDown *dropDown;
    NSString *messageView;
    NSString *is_celeb;
    NSString *btnTitle;
    IBOutlet UIImageView *bg;
    IBOutlet UIView *accounttypeView;
    IBOutlet UIButton *accountType;
    SVProgressHUDCustom *SVCustom;
    UIButton *senderForNiD;
}
- (IBAction)SignUp:(id)sender;
- (IBAction)BacktoLogin:(id)sender;

- (IBAction)accountType:(id)sender;
@property (strong, nonatomic) IBOutlet RadioButton *radioButtons;
-(IBAction)onRadioBtn:(id)sender;

@end
