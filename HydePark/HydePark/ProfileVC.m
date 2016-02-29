//
//  ProfileVC.m
//  HydePark
//
//  Created by Mr on 07/05/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "ProfileVC.h"
#import "Constants.h"
#import "DrawerVC.h"
#import "NavigationHandler.h"
#import "HomeCell.h"
#import "SVProgressHUD.h"
#import "Utils.h"
#import "NIDropDown.h"
#import "RadioButton.h"
@interface ProfileVC ()

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    // Do any additional setup after loading the view from its nib.
    _EditProfileBtn.hidden = TRUE;
    if(appdelegate.loaduserProfiel)
        [self getUserProfile];
    else{
        [self getProfile];
    }
    countryPicker.delegate = self;
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    if (IS_IPHONE_6) {
        editProfileView.frame = CGRectMake(0, 0, 375, 667);
    }
    
    arr_gender = [[NSArray alloc] initWithObjects:@"MALE", @"FEMALE", nil];
    [EditProfileScrollView setContentSize:CGSizeMake(EditProfileScrollView.frame.size.width,800)];
    /*     ProfilePic.clipsToBounds = YES;
     ProfilePic.layer.backgroundColor = [UIColor clearColor].CGColor;
     ProfilePic.layer.borderColor = [UIColor whiteColor].CGColor;
     ProfilePic.layer.borderWidth = 2.0f; */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}
#pragma mark GetProfile
- (void) getUserProfile{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *user_id = [NSString stringWithFormat:@"%d",appdelegate.userToView];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_USERPROFILE,@"method",token,@"session_token",user_id,@"user_id",nil];
    
    appdelegate.loaduserProfiel = false;
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *requests = [[NSMutableURLRequest alloc] init];
    [requests setURL:url];
    [requests setHTTPMethod:@"POST"];
    [requests setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:requests queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *profile = [result objectForKey:@"profile"];
            
            if(success == 1) {
                [self SetProfileObject:profile];
                [self setprofileData];
            }
            
        }
        else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
- (void) getProfile{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    _EditProfileBtn.hidden = FALSE;
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_PROFILE,@"method",token,@"session_token",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *requests = [[NSMutableURLRequest alloc] init];
    [requests setURL:url];
    [requests setHTTPMethod:@"POST"];
    [requests setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:requests queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *profile = [result objectForKey:@"profile"];
            
            if(success == 1) {
                [self SetProfileObject:profile];
                [self setprofileData];
            }
            
        }
        else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
-(void) SetProfileObject:(NSDictionary *)obj{
    ProfileObj = [[ProfileModel alloc]init];
    ///Saving Profile Data
    ProfileObj.user_id = [obj objectForKey:@"id"];
    ProfileObj.full_name = [obj objectForKey:@"full_name"];
    ProfileObj.account_type = [obj objectForKey:@"account_type"];
    ProfileObj.likes_count = [obj objectForKey:@"followers_count"];
    ProfileObj.profile_image = [obj objectForKey:@"profile_link"];
    ProfileObj.profile_type = [obj objectForKey:@"profile_type"];
    ProfileObj.session_token = [obj objectForKey:@"session_token"];
    ProfileObj.email = [obj objectForKey:@"email"];
    ProfileObj.friends_count = [obj objectForKey:@"following_count"];
    ProfileObj.cover_link = [obj objectForKey:@"cover_link"];
    ProfileObj.cover_type = [obj objectForKey:@"cover_type"];
    ProfileObj.city = [obj objectForKey:@"city"];
    ProfileObj.country = [obj objectForKey:@"country"];
    ProfileObj.date_of_birth = [obj objectForKey:@"date_of_birth"];
    ProfileObj.is_celeb = [obj objectForKey:@"is_celeb"];
    ProfileObj.beams_count = [obj objectForKey:@"beams_count"];
    ProfileObj.gender = [obj objectForKey:@"gender"];
    ProfileObj.WorkingPlace = [obj objectForKey:@"worked_at"];
    ProfileObj.mobileNo = [obj objectForKey:@"mobile_no"];
    ProfileObj.StudiedIn = [obj objectForKey:@"study_at"];
    
}
-(void) setprofileData{
    //// Setting Profile Data
    UserName.text = ProfileObj.full_name;
    userEmail.text = ProfileObj.email;
    lblBirthday.text = ProfileObj.date_of_birth;
    txtEmail.text = ProfileObj.email;
    lblBeams.text = ProfileObj.beams_count;
    lblFriends.text = [[NSString alloc]initWithFormat:@"%@ Following",ProfileObj.friends_count];
    lblLikes.text = [[NSString alloc]initWithFormat:@"Followed by %@",ProfileObj.likes_count];
    gender.text = ProfileObj.gender;
    location.text = [[NSString alloc]initWithFormat:@"Lives in %@ ",ProfileObj.country];
    txtName.text = ProfileObj.full_name;
    mobileLabel.text = [[NSString alloc]initWithFormat:@"%@ ",ProfileObj.mobileNo];
    txtCountry.text = ProfileObj.country;
    lblWorkingat.text = [[NSString alloc] initWithFormat:@"Working at %@",ProfileObj.WorkingPlace];
    StudiIn.text = [[NSString alloc] initWithFormat:@"Studied at %@",ProfileObj.StudiedIn];
}
#pragma mark UpdateProfile

- (void) updateProfile{
    _EditProfileBtn.hidden = FALSE;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request setPostValue:token forKey:@"session_token"];
    [request setPostValue:txtName.text forKey:@"full_name"];
    [request setPostValue:txtCity.text forKey:@"city"];
    [request setPostValue:LivesInField.text forKey:@"country"];
    [request setPostValue:gender.text forKey:@"gender"];
    //[request setPostValue:lblBirthday.text forKey:@"date_of_birth"];
    [request setPostValue:StudiedInField.text forKey:@"study_at"];
    [request setPostValue:mobileEditField.text forKey:@"mobile_no"];
    [request setPostValue:workingAtField.text forKey:@"worked_at"];
    
    [request setPostValue:METHOD_UPDATE_PROFILE forKey:@"method"];
    
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request startAsynchronous];
    
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // NSString *response = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
    int success = [[result objectForKey:@"success"] intValue];
    NSDictionary *profile = [result objectForKey:@"profile"];
    
    if(success == 1) {
        [self  SetProfileObject:profile];
        [self setprofileData];
        
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)theRequest {
    
    NSString *response = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    NSLog(@"This is respone ::: %@",response);
}

-(void) setUserProfileImage {
    
    ProfilePic.layer.cornerRadius = ProfilePic.frame.size.width / 2;
    
    for (UIView* subview in ProfilePic.subviews)
        subview.layer.cornerRadius = ProfilePic.frame.size.width / 2;
    
    ProfilePic.layer.shadowColor = [UIColor blackColor].CGColor;
    ProfilePic.layer.shadowOpacity = 0.7f;
    ProfilePic.layer.shadowOffset = CGSizeMake(0, 5);
    ProfilePic.layer.shadowRadius = 5.0f;
    ProfilePic.layer.masksToBounds = NO;
    
    ProfilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    ProfilePic.layer.borderWidth = 3.0f;
    
    ProfilePic.layer.cornerRadius = ProfilePic.frame.size.width / 2;
    
    for (UIView* subview in editprofilepic.subviews)
        subview.layer.cornerRadius = editprofilepic.frame.size.width / 2;
    
    editprofilepic.layer.shadowColor = [UIColor blackColor].CGColor;
    editprofilepic.layer.shadowOpacity = 0.7f;
    editprofilepic.layer.shadowOffset = CGSizeMake(0, 5);
    editprofilepic.layer.shadowRadius = 5.0f;
    editprofilepic.layer.masksToBounds = NO;
    
    
    NSURL *url1 = [NSURL URLWithString:ProfileObj.profile_image];
    NSData *data1 = [NSData dataWithContentsOfURL:url1];
    UIImage *img1 = [[UIImage alloc] initWithData:data1];
    CGSize size1 = img1.size;
    
    
    ProfilePic.layer.cornerRadius = ProfilePic.frame.size.width / 2;
    ProfilePic.layer.masksToBounds = NO;
    ProfilePic.clipsToBounds = YES;
    
    ProfilePic.layer.backgroundColor = [UIColor clearColor].CGColor;
    ProfilePic.layer.borderColor = [UIColor whiteColor].CGColor;
    ProfilePic.layer.borderWidth = 3.0f;
    
    editprofilepic.layer.cornerRadius = ProfilePic.frame.size.width / 2;
    editprofilepic.layer.masksToBounds = NO;
    editprofilepic.clipsToBounds = YES;
    
}

#pragma mark ----------------------
#pragma mark TableView Data Source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    float returnValue;
    if (IS_IPAD)
        returnValue = 350.0f;
    else
        returnValue = 230.0f;
    
    return returnValue;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    HomeCell *cell;
    
    if (IS_IPAD) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell_iPad" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else{
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    return cell;
}

#pragma mark - TableView Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


-(void)rel{
    
    dropDown = nil;
}

- (IBAction)GenderSelect:(id)sender {
    NSArray * arr = [[NSArray alloc] init];
    arr = arr_gender;
    NSArray * arrImage = [[NSArray alloc] init];
    arrImage = [NSArray arrayWithObjects:[UIImage imageNamed:@""], [UIImage imageNamed:@""], nil];
    GenderView.hidden = false;
//    if(dropDown == nil) {
//        CGFloat f = arr.count*40;
//        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down":true];
//        dropDown.delegate = self;
//        
//    }
//    else {
//        [dropDown hideDropDown:sender];
//        [self rel];
//    }
}

- (IBAction)EditProfilePressed:(id)sender {
    beamsView.hidden = YES;
    saveProfile.hidden = NO;
    LivesInField.hidden = NO;
    workingAtField.hidden = NO;
    StudiedInField.hidden = NO;
    mobileEditField.hidden = NO;
    txtgender.hidden = NO;
    birhdaybtn.hidden = NO;
    _EditProfileBtn.hidden = YES;
    StudiIn.text = @"Studied at";
    lblWorkingat.text = @"Working at";
    location.text = @"Lives in";
    mobileLabel.text = @"";
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, LivesInField.frame.size.height - 1, LivesInField.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:54.0f/255.0f green:78.0f/255.0f blue:141.0f/255.0f alpha:1].CGColor;
    CALayer *bottomBorder1 = [CALayer layer];
    bottomBorder1.frame = CGRectMake(0.0f, LivesInField.frame.size.height - 1, LivesInField.frame.size.width, 1.0f);
    bottomBorder1.backgroundColor = [UIColor colorWithRed:54.0f/255.0f green:78.0f/255.0f blue:141.0f/255.0f alpha:1].CGColor;
    CALayer *bottomBorder2 = [CALayer layer];
    bottomBorder2.frame = CGRectMake(0.0f, StudiedInField.frame.size.height - 1, StudiedInField.frame.size.width, 1.0f);
    bottomBorder2.backgroundColor = [UIColor colorWithRed:54.0f/255.0f green:78.0f/255.0f blue:141.0f/255.0f alpha:1].CGColor;
    CALayer *bottomBorder3 = [CALayer layer];
    bottomBorder3.frame = CGRectMake(0.0f, mobileEditField.frame.size.height - 1, mobileEditField.frame.size.width, 1.0f);
    bottomBorder3.backgroundColor = [UIColor colorWithRed:54.0f/255.0f green:78.0f/255.0f blue:141.0f/255.0f alpha:1].CGColor;
    [LivesInField.layer  addSublayer:bottomBorder1];
    [StudiedInField.layer addSublayer:bottomBorder2];
    [workingAtField.layer addSublayer:bottomBorder];
    [mobileEditField.layer addSublayer:bottomBorder3];
}


- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    
    
    if(sender.selectedIndex == 0) {
        [txtgender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if(isMale) {
            isMale = false;
            isFemale = true;
            
        }
        else {
            isMale = true;
            isFemale = false;
            
        }
        gender.text = @"MALE";
        strgender = @"MALE";
        [txtgender setTitle:@"MALE" forState:UIControlStateNormal];
    }
    else if (sender.selectedIndex == 1) {
        [txtgender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        if(isFemale) {
            isMale = true;
            isFemale = false;
            
        }
        else {
            isMale = false;
            isFemale = true;
            
        }
        gender.text = @"FEMALE";
        strgender = @"FEMALE";
        
    }
    
    [self rel];
}
-(IBAction)closegenderView:(id)sender
{
    GenderView.hidden = true;
}

-(IBAction)onRadioBtn:(RadioButton*)sender
{
    genderBtn.titleLabel.text = sender.titleLabel.text;
    gender.text = sender.titleLabel.text;
}
#pragma mark countries picker delegate
- (IBAction)countryPressed:(id)sender {
    
    [self.view endEditing:YES];
    countriesView.hidden = false;
    countryPicker.hidden = false;
    countriesView.layer.borderColor = [[UIColor darkGrayColor]CGColor];
    countriesView.layer.borderWidth = 1.0f;
    
    UIButton *DateSelected = [UIButton buttonWithType:UIButtonTypeCustom];
    [DateSelected setFrame:CGRectMake(countryPicker.frame.origin.x+30, countryPicker.frame.origin.y+countryPicker.frame.size.height+220, 80, 35)];
    if(IS_IPAD) {
        [DateSelected setFrame:CGRectMake(countryPicker.frame.origin.x+30, countryPicker.frame.origin.y+countryPicker.frame.size.height+350, 120, 50)];
    }
    [DateSelected setBackgroundImage:[UIImage imageNamed:@"redbar.png"] forState:UIControlStateNormal];
    [DateSelected setTitle:@"Done" forState:UIControlStateNormal];
    [DateSelected.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [DateSelected setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [DateSelected addTarget:self action:@selector(countrySelected:) forControlEvents:UIControlEventTouchUpInside];
    [countriesView addSubview:DateSelected];
    
    UIButton *CancelSelected = [UIButton buttonWithType:UIButtonTypeCustom];
    [CancelSelected setFrame:CGRectMake(DateSelected.frame.origin.x+DateSelected.frame.size.width+160, DateSelected.frame.origin.y, 80, 35)];
    if(IS_IPAD) {
        [CancelSelected setFrame:CGRectMake(DateSelected.frame.origin.x+DateSelected.frame.size.width+135, DateSelected.frame.origin.y, 120, 50)];
    }
    [CancelSelected setBackgroundImage:[UIImage imageNamed:@"redbar.png"] forState:UIControlStateNormal];
    [CancelSelected setTitle:@"Cancel" forState:UIControlStateNormal];
    [CancelSelected.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [CancelSelected setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [CancelSelected addTarget:self action:@selector(countrySelectionCancelled:) forControlEvents:UIControlEventTouchUpInside];
    [countriesView addSubview:CancelSelected];
    
}

- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    txtCountry.text = name;
}

-(void)countrySelected:(id)sender{
    
    countriesView.hidden = true;
    countryPicker.hidden = true;
    countriesView.layer.borderColor = [[UIColor darkGrayColor]CGColor];
    countriesView.layer.borderWidth = 1.0f;
}
-(void)countrySelectionCancelled:(id)sender{
    countriesView.hidden = true;
    countryPicker.hidden = true;
    
}

#pragma mark ---------------
#pragma mark Date Of Birth
- (IBAction)SelectDateOfBirth:(id)sender {
    [self.view endEditing:YES];
    dobPicker.hidden = NO;
    dobView.hidden = NO;
    dobView.layer.borderColor = [[UIColor grayColor]CGColor];
    dobView.layer.borderWidth = 1.0f;
    
    overlayView.hidden = false;
    
    [dobPicker setMaximumDate:[self getCurrentDate]];
    UIButton *DateSelected = [UIButton buttonWithType:UIButtonTypeCustom];
    [DateSelected setFrame:CGRectMake(dobView.frame.origin.x+70, dobView.frame.size.height-65, 80, 35)];
    
    if(IS_IPAD) {
        [DateSelected setFrame:CGRectMake(dobView.frame.origin.x-130, dobView.frame.size.height-60, 120, 50)];
    }
    [DateSelected setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    [DateSelected setTitle:@"Done" forState:UIControlStateNormal];
    [DateSelected.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [DateSelected setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [DateSelected addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventTouchUpInside];
    [dobView addSubview:DateSelected];
    
    UIButton *CancelSelected = [UIButton buttonWithType:UIButtonTypeCustom];
    [CancelSelected setFrame:CGRectMake(DateSelected.frame.origin.x+DateSelected.frame.size.width+70, DateSelected.frame.origin.y, 80, 35)];
    
    if(IS_IPAD) {
        [CancelSelected setFrame:CGRectMake(DateSelected.frame.origin.x+DateSelected.frame.size.width+140, DateSelected.frame.origin.y, 120, 50)];
    }
    [CancelSelected setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    [CancelSelected setTitle:@"Cancel" forState:UIControlStateNormal];
    [CancelSelected.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [CancelSelected setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [CancelSelected addTarget:self action:@selector(dateSelectionCancelled:) forControlEvents:UIControlEventTouchUpInside];
    [dobView addSubview:CancelSelected];
}
-(void)dateSelectionCancelled:(id)sender{
    dobPicker.hidden = true;
    dobView.hidden = true;
    
    overlayView.hidden = true;
}
-(void)dateSelected:(id)sender{
    
    /// IGNORING TIME COMPONENT
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *dateInOldFormat = [dobPicker date];
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:dateInOldFormat];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    
    /// CHANGING FORMAT
    
    NSString *_outputFormat = @"yyyy-MM-dd";
    //[dateFormatter setDateFormat:@"YYYY-M-d"];
    [dateFormatter setDateFormat:_outputFormat];
    
    NSString *dateInNewFormat = [dateFormatter stringFromDate:dateOnly];
    
    NSDate *date = [dateFormatter dateFromString:dateInNewFormat] ;
    NSLog(@"date=%@",date) ;
    NSTimeInterval interval  = [date timeIntervalSince1970] ;
    NSLog(@"interval=%f",interval) ;
    NSDate *methodStart = [NSDate dateWithTimeIntervalSince1970:interval] ;
    [dateFormatter setDateFormat:@"yyyy-MM-dd "] ;
    NSLog(@"result: %@", [dateFormatter stringFromDate:methodStart]) ;
    finalDate = [dateFormatter stringFromDate:methodStart];
    [lblBirthday setText:finalDate];
    [txtBirthday setText:finalDate];
    NSLog(@"%@",txtBirthday.text);
    dobPicker.hidden = true;
    dobView.hidden = true;
    overlayView.hidden = true;
}

-(NSDate *)getCurrentDate{
    
    return [NSDate date];
    
}

#pragma mark TextFields delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //
    //    UITouch *touch = [[event allTouches] anyObject];
    //    if ([txtName isFirstResponder] && [touch view] != txtName) {
    //        [txtName resignFirstResponder];
    //
    //    }
    //    else if ([txtCity isFirstResponder] && [touch view] != txtCity) {
    //
    //        [txtCity resignFirstResponder];
    //
    //    }  else if ([txtCountry isFirstResponder] && [touch view] != txtCountry) {
    //
    //        [txtCountry resignFirstResponder];
    //
    //    }  [super touchesBegan:touches withEvent:event];
    //    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    //    const int movementDistance = 145; // tweak as needed
    //    const float movementDuration = 0.3f; // tweak as needed
    //
    //    int movement = (up ? -movementDistance : movementDistance);
    //
    //    [UIView beginAnimations: @"anim" context: nil];
    //    [UIView setAnimationBeginsFromCurrentState: YES];
    //    [UIView setAnimationDuration: movementDuration];
    //    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    //    [UIView commitAnimations];
}

- (IBAction)openDrawer:(id)sender {
    
    
    //    CGSize size = self.view.frame.size;
    //
    //    if(self.isMenuVisible) {
    //        self.isMenuVisible = false;
    //        [overlayView removeFromSuperview];
    //        [UIView animateWithDuration:0.5 animations:^{
    //            self.view.frame = CGRectMake(0, 0, size.width, size.height);
    //        }];
    //    }
    //    else {
    //        [UIView animateWithDuration:0.5 animations:^{
    //            self.view.frame = CGRectMake(236, 0, size.width, size.height);
    //        }];
    //        self.isMenuVisible = true;
    //        CGRect screenRect = [[UIScreen mainScreen] bounds];
    //        overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, screenRect.size.width, screenRect.size.height)];
    //        overlayView.backgroundColor = [UIColor clearColor];
    //
    //        [self.view addSubview:overlayView];
    //
    //        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    //        [sgr setDirection:UISwipeGestureRecognizerDirectionLeft];
    //        [overlayView addGestureRecognizer:sgr];
    //    }
    
    
    [[DrawerVC getInstance] AddInView:self.view];
    [[DrawerVC getInstance] ShowInView];
}

- (void)leftSwipe:(UISwipeGestureRecognizer *)gesture
{
    if(self.isMenuVisible){
        [self openDrawer:nil];
    }
}

- (IBAction)editProfile:(id)sender {
    
    [self setUserProfileImage];
    
    [self.view addSubview:editProfileView];
}

- (IBAction)EditPic:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    [self setUserProfileImage];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    ProfilePic.image = chosenImage;
    editprofilepic.image = chosenImage;
    //   isFile = true;
    // popUpView.hidden = true;
    overlayView.hidden = true;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)saveProfile:(id)sender {
    GenderView.hidden = YES;
    beamsView.hidden = NO;
    saveProfile.hidden = YES;
    LivesInField.hidden = YES;
    workingAtField.hidden = YES;
    StudiedInField.hidden = YES;
    mobileEditField.hidden = YES;
    _EditProfileBtn.hidden = YES;
    txtgender.hidden = YES;
    birhdaybtn.hidden = YES;
    [self updateProfile];
}

@end
