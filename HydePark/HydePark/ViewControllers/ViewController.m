//
//  ViewController.m
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "ViewController.h"
#import "HomeVC.h"
#import "MyBeam.h"
#import "Topics.h"
#import "VideoPlayer.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <Security/Security.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "SVProgressHUD.h"
#import "SignUpVC.h"
#import "NavigationHandler.h"
#import "Constants.h"
#import "Utils.h"
#import "HPCUser.h"
#import "SVProgressHUDCustom.h"

@interface ViewController ()

@end

@implementation ViewController

#define kOAuthConsumerKey        @"XL0qdKEsuBscc8zUQDHo0VXQa"         //REPLACE With Twitter App OAuth Key
#define kOAuthConsumerSecret    @"SUlS1QVX5I9XxhVXZJmcUzsUhvnMCbEut8LERJZBYFI1BRCmtL"

static NSString * const kClientId = Client_Id;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)init
{
    
    if (IS_IPAD) {
        
        self = [super initWithNibName:@"ViewController_iPad" bundle:Nil];
    }
    
    else{
        self = [super initWithNibName:@"ViewController" bundle:Nil];
    }
    
    return self;
}
-(void)viewWillAppear:(BOOL)animated

{
    
    [super viewWillAppear:animated];
    
    //your table view name
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.navigationController.navigationBarHidden = YES;
    SVCustom = [[SVProgressHUDCustom alloc]init];
    appfbLogin = [[UIApplication sharedApplication] delegate];
    appDelegate = [[UIApplication sharedApplication] delegate];
    [SVCustom customProgressHUD];
    BOOL signup = [[NSUserDefaults standardUserDefaults]boolForKey:@"isSignup"];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"logged_in"]) {
        
        [self.view addSubview:walkthrough];
        [self.view bringSubviewToFront:walkthrough];
    }
    if (signup == YES) {
        [walkthrough removeFromSuperview];
    }else{
        [self.view addSubview:walkthrough];
        [self.view bringSubviewToFront:walkthrough];
    }
    
    dot.image = [dot.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [dot setTintColor:[UIColor colorWithRed:54.0f/255.0f
                                      green:78.0f/255.0f
                                       blue:141.0f/255.0f
                                      alpha:1.0f]];
    UIColor *color = [UIColor whiteColor];
    _txtEmailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    _txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    _txtForgetEmailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserID = YES;
    
    signIn.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification object:nil];
   
    if(IS_IPHONE_4){
        _socialLogin.frame = CGRectMake(0, 0, 320, 480);
        socialLoginView.frame = CGRectMake(0, 0, 320, 480);
        _CustomLoginView.frame = CGRectMake(320, 0, 320, 480);
        _ForgetPasswordView.frame = CGRectMake(0, 0, 320, 480);
        socialScrollview.contentSize = CGSizeMake(320*2, socialScrollview.frame.size.height);
    }else if (IS_IPHONE_5){
        _socialLogin.frame = CGRectMake(0, 0, 320, 568);
        socialLoginView.frame = CGRectMake(0, 0, 320, 568);
        _CustomLoginView.frame = CGRectMake(320, 0, 320, 568);
        _ForgetPasswordView.frame = CGRectMake(0, 0, 320, 568);
        socialScrollview.contentSize = CGSizeMake(320*2, socialScrollview.frame.size.height);
    }else if (IS_IPHONE_6){
        _socialLogin.frame = CGRectMake(0, 0, 375, 667);
        socialLoginView.frame = CGRectMake(0, 0, 375, 667);
        _CustomLoginView.frame = CGRectMake(375, 0, 375, 667);
        _ForgetPasswordView.frame = CGRectMake(0, 0, 375, 667);
        socialScrollview.contentSize = CGSizeMake(375*2, socialScrollview.frame.size.height);
    }else if(IS_IPHONE_6Plus){
        _socialLogin.frame = CGRectMake(0, 0, 414, 736);
        socialLoginView.frame = CGRectMake(0, 0, 414, 736);
        _CustomLoginView.frame = CGRectMake(414, 0, 414, 736);
        _ForgetPasswordView.frame = CGRectMake(0, 0, 414, 736);
        socialScrollview.contentSize = CGSizeMake(414*2,socialScrollview.frame.size.height);
        logo.frame = CGRectMake(67, 94,280,52);
        logo1.frame = CGRectMake(67, 94,280,52);
        logo2.frame = CGRectMake(67 , 94,280,52);
    }
    else if (IS_IPAD){
        _socialLogin.frame = CGRectMake(0, 0, 768, 1024);
        socialLoginView.frame = CGRectMake(768, 0, 768, 1024);
        _CustomLoginView.frame = CGRectMake(768, 0, 768, 1024);
        _ForgetPasswordView.frame = CGRectMake(0, 0, 768, 1024);
        socialScrollview.contentSize = CGSizeMake(768*2, socialScrollview.frame.size.height);
    }
    socialScrollview.pagingEnabled = YES;
    [socialScrollview setShowsHorizontalScrollIndicator:NO];
    [socialScrollview setShowsVerticalScrollIndicator:NO];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //[socialScrollview setContentOffset:CGPointMake(0, 0) animated:YES];
    [socialScrollview addSubview:self.CustomLoginView];

}
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint scrollPos = scrollView.contentOffset;
    
    if (scrollPos.x >319) {
        //socialBgimg.image = [UIImage imageNamed:@"Signin_bg.png"];
        socialTabLine.hidden = YES;
        LoginTabLine.hidden = NO;
        
    }else{
        //socialBgimg.image = [UIImage imageNamed:@"social_bg.png"];
        socialTabLine.hidden = NO;
        LoginTabLine.hidden = YES;
    }
    if (IS_IPAD) {
        if (scrollPos.x  < 768) {
            //socialBgimg.image = [UIImage imageNamed:@"Signin_bg.png"];
            socialTabLine.hidden = YES;
            LoginTabLine.hidden = NO;
        }else  {
            //socialBgimg.image = [UIImage imageNamed:@"social_bg.png"];
            socialTabLine.hidden = NO;
            LoginTabLine.hidden = YES;
        }
    }else if (IS_IPHONE_6){
        
        if (scrollPos.x >374) {
            //socialBgimg.image = [UIImage imageNamed:@"Signin_bg.png"];
            socialTabLine.hidden = YES;
            LoginTabLine.hidden = NO;
        }else if (scrollPos.x < 375){
            //socialBgimg.image = [UIImage imageNamed:@"social_bg.png"];
            socialTabLine.hidden = NO;
            LoginTabLine.hidden = YES;
        }
        
    }
    else if (IS_IPHONE_6Plus){
        
        if (scrollPos.x >413) {
            //socialBgimg.image = [UIImage imageNamed:@"Signin_bg.png"];
            socialTabLine.hidden = YES;
            LoginTabLine.hidden = NO;
        }else if (scrollPos.x < 413){
            //socialBgimg.image = [UIImage imageNamed:@"social_bg.png"];
            socialTabLine.hidden = NO;
            LoginTabLine.hidden = YES;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)getStarted:(id)sender {
    
    [btnStarted setImage:[UIImage imageNamed:@"btnStarted_iPad.png"] forState:UIControlStateNormal];
    [walkthrough removeFromSuperview];
    
}

#pragma mark G+ Login

- (IBAction)gplusLogin:(id)sender {
    
    //[SVProgressHUD showWithStatus:@"Getting User Info..."];
    appDelegate.strSocial = @"GPlus";
    _gplusbtn.enabled = NO;
    _fbbtn.enabled = NO;
    [self loginWithGooglePlus];
}

- (void)loginWithGooglePlus
{
    [GPPSignIn sharedInstance].clientID = Client_Id;
    [GPPSignIn sharedInstance].scopes= [NSArray arrayWithObjects:kGTLAuthScopePlusLogin, nil];
    [GPPSignIn sharedInstance].shouldFetchGoogleUserID=YES;
    [GPPSignIn sharedInstance].shouldFetchGoogleUserEmail=YES;
    [GPPSignIn sharedInstance].delegate=self;
    [[GPPSignIn sharedInstance] authenticate];
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error
{
    if (!error)
    {
        NSLog(@"Google+ login successful");
        appDelegate.isLoggedIn = YES;
        
        NSLog(@"%@", signIn.authentication.userEmail);
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:signIn.authentication];
        
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error) {
                        GTMLoggerError(@"Error: %@", error);
                        _gplusbtn.enabled = YES;
                        _fbbtn.enabled = YES;
                        
                    } else {
                        // Retrieve the display name and "about me" text
                        
                        _strUserId =[person.name.givenName stringByAppendingFormat:@"%@", person.name.familyName];
                        _strFirstN = person.displayName;
                        _strEmail = [GPPSignIn sharedInstance].authentication.userEmail;
                        _strGender = person.gender;
//                          NSString *description = [NSString stringWithFormat:
//                        @"%@\n%@\n%@\n%@\n", person.displayName,
//                        person.image,person.gender,person.identifier];
                         _profile_pic_url = person.image.url;
                        NSRange lastComma = [_profile_pic_url rangeOfString:@"0" options:NSBackwardsSearch];
                       
                        if(lastComma.location != NSNotFound) {
                            _profile_pic_url = [_profile_pic_url stringByReplacingCharactersInRange:lastComma
                                                               withString: @"150"];
                        }
                       
                        [self sendsocialSignUpCall:@"GOOGLE_PLUS"];
                    }
                }];
        
        
    }
    else
    {
        NSLog(@"Error: %@", error);
        _gplusbtn.enabled = YES;
        _fbbtn.enabled = YES;
        appDelegate.isLoggedIn = NO;
    }
    // [SVProgressHUD dismiss];
}

#pragma mark Facebook Login

- (IBAction)fbLogin:(id)sender {
    
    // [SVProgressHUD showWithStatus:@"Getting User Info..."];
    appDelegate.strSocial = @"Facebook";
    _gplusbtn.enabled = NO;
    _fbbtn.enabled = NO;
    if (FBSession.activeSession.isOpen) {
        
        [self sessionStateChanged:nil];
        
    } else {
        
        [appfbLogin openSessionWithAllowLoginUI:YES];
    }
}

- (void)sessionStateChanged:(NSNotification *)notification {
    if (FBSession.activeSession.isOpen) {
        
        FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,picture,birthday,location"];
        [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            NSArray *data = [result objectForKey:@"data"];
            for (FBGraphObject<FBGraphUser> *friend in data) {
                NSLog(@"%@:%@", [friend name],[friend birthday]);
            }}];
        
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            
            if (!error) {
                
                _strFirstN = [user objectForKey:@"first_name"];
                _strLastN = [user objectForKey:@"last_name"];
                _strEmail = [user objectForKey:@"email"];
                _strUserId = [user objectForKey:@"name"];
                _user_id = [[user objectForKey:@"id"]intValue];
                
                
                NSString *userName = [user name];
                NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [user objectForKey:@"id"]];
                
                appDelegate.profile_pic_url = userImageURL;
                _profile_pic_url = userImageURL;
                
                appDelegate.isLoggedIn = YES;
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_profile_pic_url]];
                
                // Run network request asynchronously
                [NSURLConnection sendAsynchronousRequest:urlRequest
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:
                 ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                     if (connectionError == nil && data != nil) {
                         
                         NSLog(@"Getting Picture : %@ %@",user,_profile_pic_url);
                         if (userName) {
                             [self sendsocialSignUpCall:@"FACEBOOK"];
                         }
                         //  [SVProgressHUD dismiss];
                     }
                 }];
            }
        }];
    }
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    
    [[self navigationController] pushViewController:viewController animated:YES];
}

#pragma mark Twitter Login

- (IBAction)twitterLogin:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Getting User Info..."];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                // Creating a request to get the info about a user on Twitter
                NSString *screenName = twitterAccount.username;
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:screenName forKey:@"screen_name"]];
                [twitterInfoRequest setAccount:twitterAccount];
                
                // Making the request
                
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        
                        if (responseData) {
                            
                            
                            
                            NSError *error = nil;
                            NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            // Filter the preferred data
                            
                            NSString *screen_name = [(NSDictionary *)TWData objectForKey:@"name"];
                            NSString *name = [(NSDictionary *)TWData objectForKey:@"name"];
                            
                            NSString *profileImageStringURL = [(NSDictionary *)TWData objectForKey:@"profile_image_url_https"];
                            NSString *bannerImageStringURL =[(NSDictionary *)TWData objectForKey:@"profile_banner_url"];
                            
                            _strUserId = screen_name;
                            _strFirstN = name;
                            
                            _strEmail = name;
                            _strLastN = name;
                            
                            _profile_pic_url = profileImageStringURL;
                            
                            // Get the profile image in the original resolution
                            
                            profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                            
                            
                            [self getTwitterAccountInformation];
                            [self twitterLookupApi];
                            
                            
                            if(_strFirstN== nil){
                                UIAlertView *NameAlert = [[UIAlertView alloc] initWithTitle:@"Account Configuration Error" message:@"Go to Device Settings and set up FullName in Twitter Account and Try Again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [NameAlert show];
                                [SVProgressHUD dismiss];
                                
                            }else{
                                [self sendsocialSignUpCall:@"TWITTER"];
                                
                            }
                        }
                    });
                }];
            }
            else {
                UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Account Configuration Error" message:@"Go to Device Settings and set up Twitter Account" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [warningAlert show];
                [SVProgressHUD dismiss];
            }
        } else {
            NSLog(@"No access granted");
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"Access Denied by User" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            [SVProgressHUD dismiss];
        }
    }];
    
}

- (void)getTwitterAccountInformation // get user's simple data
{
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    //    NSString *message = _textView.text;
    //hear before posting u can allow user to select the account
    NSArray *arrayOfAccons = [account accountsWithAccountType:accountType];
    for(ACAccount *acc in arrayOfAccons)
    {
        NSLog(@"Twitter username %@",acc.username);
        NSLog(@"accountDescription:::: %@",acc.accountDescription);
        NSLog(@"description::::: %@",acc.description);
        NSLog(@"credential::::::: %@",acc.credential);
        NSLog(@"userFullName::::::: %@",acc.userFullName);
        
        NSDictionary *properties = [acc dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]];
        NSDictionary *details = [properties objectForKey:@"properties"];
        NSLog(@"details  =  %@",[properties objectForKey:@"properties"]);
        NSLog(@"properties  =  %@",properties);
        NSLog(@"acc  =  %@",acc);
        
        
        NSLog(@"user_id  =  %@",[details objectForKey:@"user_id"]);
        //user id
        NSLog(@"FullName  =  %@",[details objectForKey:@"fullName"]);
        
        _strFirstN= [details objectForKey:@"fullName"];
        //   appDelegate.strLastN = @" ";
        _strEmail = acc.username;
        _strUserId = [details objectForKey:@"user_id"];
        
        NSString *imageUrlString = [details objectForKey:@"profile_image_url_https"];
        
        _profile_pic_url = imageUrlString;
        
        imageUrlString = [imageUrlString stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
        
        NSLog(@"image: %@",_profile_pic_url);
    }
    
    [self twitterLookupApi];
    //    [self twitterAlert];
    
}

-(void)twitterLookupApi {
    // to get your deeper account detail like status, profile image, name, screen_name etc
    
    NSString *strURL = [NSString stringWithFormat:@"http://api.twitter.com/1/users/lookup.json?user_id=%@",_strUserId];
    
    NSString *urlUsers = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json"];
    
    NSURL *url = [NSURL URLWithString:urlUsers];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:_strUserId forKey:@"user_id"];
    [params setObject:@"0" forKey:@"include_rts"]; // don't include retweets
    [params setObject:@"1" forKey:@"trim_user"]; // trim the user information
    [params setObject:@"1" forKey:@"count"]; // i don't even know what this does but it does something useful
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    NSArray *twitterAccounts = [store accountsWithAccountType:twitterType];
    
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodGET];
    //  Attach an account to the request
    ACAccount *account = [twitterAccounts objectAtIndex:0];
    
    [request setAccount:account]; // this can be any Twitter account obtained from the Account store
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSDictionary *twitterData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:NULL];
            NSLog(@"received Twitter data: %@", twitterData);
            
            // to do something useful with this data:
            NSString *screen_name = [twitterData objectForKey:@"screen_name"]; // the screen name you were after
            NSLog(@"profile Image : %@",[twitterData objectForKey:@"profile_image_url_https"]);
            NSLog(@"screen_name : %@",[twitterData objectForKey:@"name"]);
            
            _strFirstN = [twitterData objectForKey:@"name"];
            
            NSString *imageUrlString = [twitterData objectForKey:@"profile_image_url_https"];
            
            _profile_pic_url = imageUrlString;
            
            imageUrlString = [imageUrlString stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
            
            _strUserId = [twitterData objectForKey:@"user_id"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // update your UI in here
                
                //displayName = [twitterData objectForKey:@"name"];
                // profileImageUrl = [twitterData objectForKey:@"profile_image_url_https"];
            });
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_profile_pic_url]];
                //  UIImage *image = [UIImage imageWithData:imageData]; // the matching profile image
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // assign it to an imageview in your UI here
                    
                    
                });
            });
        }else{
            NSLog(@"Error while downloading Twitter user data: %@", error);
        }
    }];
}


#pragma mark Custom Login
- (IBAction)LoginPressed:(id)sender {
    
    
    if (_txtEmailField.text.length > 0 ) {
        
        if(![self validateEmail:_txtEmailField.text])
        {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter some valid email address." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            
            [alertView show];
            return;
            
        }else{
            
            if (!_txtPassword.text.length >0){
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty Field" message:@"Please enter Password." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                [self sendLoginCall];
            }
            
        }
        [_txtEmailField resignFirstResponder];
        [_txtPassword resignFirstResponder];
    }else{
        
        if (!_txtEmailField.text.length>0) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty Field" message:@"Please enter some valid email address." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            
            [alertView show];
        }else
            
            [_txtEmailField resignFirstResponder];
        [_txtPassword resignFirstResponder];
    }
}

-(void) sendLoginCall {
    
    [SVProgressHUD show];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_LOG_IN,@"method",
                              _txtEmailField.text,@"email", _txtPassword.text, @"password",  nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            [SVProgressHUD dismiss];
            int success = [[result objectForKey:@"success"] intValue];
            NSString *message = [result objectForKey:@"message"];
            NSDictionary *data = [result objectForKey:@"data"];
            NSDictionary *profile = [data objectForKey:@"profile"];
            NSString *sessionToken = [profile objectForKey:@"session_token"];
            NSString *id = [profile objectForKey:@"id"];
            if(success == 1) {
                //Navigate to Home Screen
                AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                appDelegate.isLoggedIn = true;
                
                [[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:@"session_token"];
                [[NSUserDefaults standardUserDefaults] setObject:id forKey:@"id"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                HomeVC *controller = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
                [self.navigationController pushViewController:controller animated:YES];
                
                [[NavigationHandler getInstance]NavigateToHomeScreen];
            }
            else {
//                //show error
//                //                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
//                //                [[NSUserDefaults standardUserDefaults] synchronize];
//                //                HomeVC *controller = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
//                //                [self.navigationController pushViewController:controller animated:YES];
//                
//                AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//                appDelegate.isLoggedIn = true;
//                
//                [[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:@"session_token"];
//                
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                //                HomeVC *controller = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
//                //                [self.navigationController pushViewController:controller animated:YES];
//                [[NavigationHandler getInstance]NavigateToHomeScreen];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Whether username or password is incorrect!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

#pragma mark Forget Password

- (IBAction)ForgetPasswordPressed:(id)sender {
    [self.view addSubview:self.ForgetPasswordView];
    //     [self.navigationController.view addSubview:self.ForgetPasswordView];
    //    [UIView beginAnimations:nil context:nil];
    //    [UIView setAnimationDuration:0.5];
    //    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
    //                           forView:self.ForgetPasswordView
    //                             cache:YES];
    //    [UIView commitAnimations];
    
}

- (IBAction)ResetPressed:(id)sender {
    [self ResetPasswordRequest];
}

-(void) ResetPasswordRequest {
    [SVProgressHUD showWithStatus:@"Loading..."];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"forgotPassword",@"method",
                              _txtForgetEmailField.text,@"email",  nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *data = [result objectForKey:@"data"];
            
            if(success == 1) {
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Password" message:@"Reset password request has been sent." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Email is incorrect!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
}


- (IBAction)SignupPressed:(id)sender {
    
    //        if (IS_IPAD) {
    //
    //            SignUpVC *_main1 = [[SignUpVC alloc] initWithNibName:@"SignUpVC_iPad" bundle:nil];
    //            [self.navigationController pushViewController:_main1 animated:YES];
    //        }else if(IS_IPHONE_6Plus)
    //        {
    //            SignUpVC *_main2 = [[SignUpVC alloc] initWithNibName:@"SignUpVC_iPhone_6Plus" bundle:nil];
    //            [self.navigationController pushViewController:_main2 animated:YES];
    //        }
    //        else{
    //            SignUpVC *_main2 = [[SignUpVC alloc] initWithNibName:@"SignUpVC" bundle:nil];
    //             [self.navigationController pushViewController:_main2 animated:YES];
    //        }
    
    [[NavigationHandler getInstance]NavigateToSignUpScreen];
    
}

- (IBAction)switchtoCustomLogin:(id)sender {
    [SVProgressHUD dismiss];
    [socialScrollview setContentOffset:CGPointMake(320, 0) animated:YES];
    if (IS_IPAD) {
        [socialScrollview setContentOffset:CGPointMake(768, 0) animated:YES];
    }else if (IS_IPHONE_6){
        [socialScrollview setContentOffset:CGPointMake(375, 0) animated:YES];
    }
    else if (IS_IPHONE_6Plus){
        [socialScrollview setContentOffset:CGPointMake(414, 0) animated:YES];
    }
    //socialTabLine.hidden = YES;
    //LoginTabLine.hidden = NO;
    //socialBgimg.image = [UIImage imageNamed:@"Signin_bg.png"];
    
}



#pragma mark Navigation

- (IBAction)switchtoSocialLogin:(id)sender {
    [SVProgressHUD dismiss];
    [socialScrollview setContentOffset:CGPointMake(0, 0) animated:YES];
   
    //socialBgimg.image = [UIImage imageNamed:@"social_bg.png"];
    // socialTabLine.hidden = NO;
    // LoginTabLine.hidden = YES;
}

- (IBAction)backtoLoginview:(id)sender {
    [SVProgressHUD dismiss];
    [_ForgetPasswordView removeFromSuperview];
    socialTabLine.hidden = YES;
    LoginTabLine.hidden = NO;
    if(IS_IPAD)
    {
        socialTabLine.hidden = NO;
        LoginTabLine.hidden = YES;
    }
    
}
#pragma mark SignUp Methods

-(void) sendsocialSignUpCall : (NSString*) type {
    //[SVProgressHUD showWithStatus:@"Signing Up..."];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_SIGN_UP,@"method",
                              _strUserId,@"username", _strFirstN,@"full_name",_strEmail,@"email",type,@"account_type",@"0",@"is_celeb",_profile_pic_url,@"profile_image_url",  nil];
    
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        // [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *data = [result objectForKey:@"data"];
            NSDictionary *profile = [data objectForKey:@"profile"];
            NSString *sessionToken = [profile objectForKey:@"session_token"];
            NSString *id = [profile objectForKey:@"id"];
            
            if(success == 1) {
                //Navigate to Home Screen
                AppDelegate *appDelegatea = (AppDelegate*)[UIApplication sharedApplication].delegate;
                appDelegatea.isLoggedIn = true;
                
                [[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:@"session_token"];
                [[NSUserDefaults standardUserDefaults] setObject:id forKey:@"id"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
                
                //  HomeVC *controller = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
                // [self.navigationController pushViewController:controller animated:YES];
                [[NavigationHandler getInstance]NavigateToHomeScreen];
                
            }
            else {
                AppDelegate *appDelegatea = (AppDelegate*)[UIApplication sharedApplication].delegate;
                appDelegatea.isLoggedIn = true;
                
                [[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:@"session_token"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
                //  HomeVC *controller = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
                // [self.navigationController pushViewController:controller animated:YES];
                [[NavigationHandler getInstance]NavigateToHomeScreen];
                
            }
        }
        else{
            _gplusbtn.enabled = true;
            _fbbtn.enabled = true;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
}

#pragma mark Textfields Delegate Methods

-(BOOL)validateEmail:(NSString *)candidate {
    
    
    /////////////////// Email Validations
    // NSString *email = [txtFldUsername.text lowercaseString];
    NSString *emailRegEx =@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF  MATCHES %@", emailRegEx];
    BOOL *signupValidations = TRUE;
    
    /*  NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,4}";
     NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; */
    
    
    return [emailTest evaluateWithObject:candidate];
}
//////////////Hiding Keyboard Touching Backgground/////////////

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_txtEmailField isFirstResponder] && [touch view] != _txtEmailField) {
        [_txtEmailField resignFirstResponder];
        
    }
    else if ([_txtPassword isFirstResponder] && [touch view] != _txtPassword) {
        
        _txtPassword.secureTextEntry=YES;
        [_txtPassword resignFirstResponder];
        
    } else if ([_txtForgetEmailField isFirstResponder] && [touch view] != _txtForgetEmailField) {
        
        [_txtForgetEmailField resignFirstResponder];
        
    }    [super touchesBegan:touches withEvent:event];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
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
    
    if([_txtEmailField isFirstResponder]){
        
        [_txtEmailField resignFirstResponder];
        [_txtPassword becomeFirstResponder];
    }else{
        [_txtForgetEmailField resignFirstResponder];
        [_txtPassword resignFirstResponder];
        [textField resignFirstResponder];
    }
    return YES;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 100; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}
@end
