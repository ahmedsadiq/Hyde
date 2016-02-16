//
//  ProfileVC.h
//  HydePark
//
//  Created by Mr on 07/05/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileModel.h"
#import "CountryPicker.h"
#import "NIDropDown.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"

@interface ProfileVC : UIViewController<UITextFieldDelegate,CountryPickerDelegate,NIDropDownDelegate,ASIHTTPRequestDelegate>


{
    ProfileModel *ProfileObj;
    ASIFormDataRequest *request;
    IBOutlet UIButton *genderBtn;
    NSString *strgender;
    NSArray *arr_gender;
    NIDropDown *dropDown;
    BOOL isGender;
    BOOL isMale;
    BOOL isFemale;
    AppDelegate *appdelegate;
    //new Profile Outlets
    
     IBOutlet UITextField *workingEditF;
     IBOutlet UITextField *FollowersEditField;
     IBOutlet UITextField *locationEditField;
     IBOutlet UITextField *StudiedField;
    
    IBOutlet UILabel *lblWorkingat;
    NSString *finalDate;
    NSString *workedAt;
    IBOutlet UIView *editProfileView;
    IBOutlet UILabel *location;
    IBOutlet UILabel *gender;
    IBOutlet UILabel *UserName;
    
    IBOutlet UILabel *lblBirthday;
    IBOutlet UILabel *userEmail;
    IBOutlet UIImageView *ProfilePic;
    IBOutlet UITableView *tableProfile;
    IBOutlet UIImageView *coverImg;
    
    IBOutlet UIImageView *editprofilepic;
    IBOutlet UILabel *lblLikes;
    IBOutlet UILabel *lblBeams;
    IBOutlet UILabel *lblFriends;
    

    IBOutlet UILabel *txtEmail;
    IBOutlet UIButton *txtgender;
    IBOutlet UITextField *txtName;
    IBOutlet UILabel *txtCountry;
    IBOutlet UITextField *txtCity;
    IBOutlet UILabel *txtBirthday;
    
    IBOutlet UITableView *countriesTableView;
    IBOutlet UIView *countriesView;
    NSMutableArray *countries;
    IBOutlet CountryPicker *countryPicker;
    
     IBOutlet UIScrollView *EditProfileScrollView;
    IBOutlet UIView *dobView;
    IBOutlet UIDatePicker *dobPicker;
    
    UIView *overlayView;
    
}

@property (nonatomic, assign) BOOL isMenuVisible;
- (IBAction)GenderSelect:(id)sender;
- (IBAction)openDrawer:(id)sender;
- (IBAction)editProfile:(id)sender;
- (IBAction)EditPic:(id)sender;
- (IBAction)SelectDateOfBirth:(id)sender;
- (IBAction)saveProfile:(id)sender;
- (IBAction)countryPressed:(id)sender;

@end
