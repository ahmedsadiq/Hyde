//
//  SignUpVC.m
//  HydePark
//
//  Created by Mr on 05/05/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "SignUpVC.h"
#import "NavigationHandler.h"
#import "HomeVC.h"
#import "Constants.h"
#import "Utils.h"
#import "SVProgressHUD.h"
#import "DLRadioButton.h"

@interface SignUpVC ()

@property (strong, nonatomic) IBOutletCollection(DLRadioButton) NSArray *topRadioButtons;

@end

@implementation SignUpVC


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
        
        self = [super initWithNibName:@"SignUpVC_iPad.xib" bundle:Nil];
    }
    
    else{
        self = [super initWithNibName:@"iPhone_5_6.xib" bundle:Nil];
    }
       return self;
}

#pragma mark - Helpers

//- (void)showSelectedButton:(NSArray *)radioButtons {
//   btnTitle = [(DLRadioButton *)radioButtons[0] selectedButton].titleLabel.text;
//    [accountType setTitle:btnTitle forState:UIControlStateNormal];
//    accounttypeView.hidden = YES;
// 
//}
//
//- (IBAction)touched:(id)sender {
//    [self showSelectedButton:self.topRadioButtons];
//}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    SVCustom = [[SVProgressHUDCustom alloc]init];
    [SVCustom customProgressHUD];
    accountTypes = [[NSArray alloc] initWithObjects:@"Normal",@"Public Figure", nil];
    
    // set up button icons
//    for (DLRadioButton *radioButton in self.topRadioButtons) {
//        radioButton.ButtonIcon = [UIImage imageNamed:@"unchecked24.png"];
//        radioButton.ButtonIconSelected = [UIImage imageNamed:@"checked24.png"];
//    }
//    
//    
    UIColor *color = [UIColor whiteColor];
    txtUserName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"User Name" attributes:@{NSForegroundColorAttributeName: color}];
    txtEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
     txtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
     txtDisplayName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Full Name" attributes:@{NSForegroundColorAttributeName: color}];
//    if(IS_IPHONE_6Plus)
//    {
//         self.view.frame = CGRectMake(0, 0, 414, 736);
//    }
//    if (IS_IPHONE_5) {
//        self.view.autoresizingMask = UIViewAutoresizingNone;
//        bg.frame = CGRectMake(0, 0, 320, 568);
//         self.view.frame = CGRectMake(0, 0, 320, 568);
//        
//    }else if ([[UIScreen mainScreen] bounds].size.height == 667){
//         self.view.autoresizingMask = UIViewAutoresizingNone;
//      self.view.frame = CGRectMake(0, 0, 375, 667);
//       
//        imageBg.image = [UIImage imageNamed:@"signup-bg.png"];
//        imageBg.frame = CGRectMake(0, 0, 375, 667);
//       
//   }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)SignUp:(id)sender {
    
    if (txtEmail.text.length > 0 ) {
        
        if(![self validateEmail:txtEmail.text])
        {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter some valid email address." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            
            [alertView show];
            return;
            
        }else{
            if (!txtPassword.text.length >0){
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty Field" message:@"Please enter your Password." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alertView show];
                [txtPassword resignFirstResponder];
            }
            else if (!txtDisplayName.text.length >0){
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty Field" message:@"Please enter your Fullname." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alertView show];
                [txtDisplayName resignFirstResponder];
            }else if (!txtDisplayName.text.length >0){
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty Field" message:@"Please enter your Username." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alertView show];
                [txtDisplayName resignFirstResponder];
            }
            else if([accountType.titleLabel.text isEqualToString:@"Account Type"])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty Field" message:@"Please select account type." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                [self sendSignUpCall];
            }
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Email field is empty." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        
        [alertView show];
        return;
    }
}
-(IBAction)normalBtnPressed:(id)sender{
    is_celeb = @"0";
    accounttypeView.hidden = TRUE;
}
-(IBAction)CelebBtnPressed:(id)sender{
    is_celeb = @"1";
    accounttypeView.hidden = TRUE;
}
-(void) sendSignUpCall {
    [SVProgressHUD showWithStatus:@"Signing Up..."];
//    if ([btnTitle isEqualToString:@"Normal"]) {
//        is_celeb = @"0";
//    }else{
//        is_celeb = @"1";
//    }
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_SIGN_UP,@"method",
                            txtDisplayName.text,@"username", txtDisplayName.text,@"full_name",txtEmail.text,@"email",txtPassword.text, @"password",@"CUSTOM", @"account_type",is_celeb, @"is_celeb",  nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        NSLog(@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *data = [result objectForKey:@"data"];
            NSDictionary *profile = [data objectForKey:@"profile"];
            NSString *sessionToken = [profile objectForKey:@"session_token"];
            messageView = [result objectForKey:@"message"];
            if(success == 1) {
                //Navigate to Home Screen
                AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                appDelegate.isLoggedIn = true;
                
                NSDictionary *data = [result objectForKey:@"data"];
                NSDictionary *profile = [data objectForKey:@"profile"];
                NSString *sessionToken = [profile objectForKey:@"session_token"];
                NSString *is_celebs = [profile objectForKey:@"is_celeb"];
                BOOL is_celebrity = [is_celebs boolValue];
                NSString *user_id = [profile objectForKey:@"id"];
                [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:@"User_Id"];
                [[NSUserDefaults standardUserDefaults] setBool:is_celebrity forKey:@"is_celeb"];
                [[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:@"session_token"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"newSignup"];
                
                [[NavigationHandler getInstance]NavigateToHomeScreen];
            }
            else {
               // AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//appDelegate.isLoggedIn = true;
                
//                NSDictionary *profile = [result objectForKey:@"profile"];
//                NSString *sessionToken = [profile objectForKey:@"session_token"];
//                
//                [[NSUserDefaults standardUserDefaults] setObject:sessionToken forKey:@"session_token"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"newSignup"];
//                
//                HomeVC *controller = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
//                [self.navigationController pushViewController:controller animated:YES];
//
//                [[NavigationHandler getInstance]NavigateToHomeScreen];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:messageView  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (IBAction)BacktoLogin:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSignup"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NavigationHandler getInstance]NavigateToLoginScreen];
    
}

- (IBAction)accountType:(id)sender {
    senderForNiD = sender;
    //accounttypeView.hidden = NO;
    
    NSArray * arr = [[NSArray alloc] init];
    arr = accountTypes;
    NSArray * arrImage = [[NSArray alloc] init];
    arrImage = [NSArray arrayWithObjects:[UIImage imageNamed:@""], [UIImage imageNamed:@""], nil];
    if(dropDown == nil) {
        CGFloat f = arr.count*40;
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down":true];
        dropDown.delegate = self;
    }
    else {
        [dropDown hideDropDown:sender];
        [self rel];
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    
    
    if(sender.selectedIndex == 0) {
        [accountType setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        is_celeb = @"0";
    
    }
    else if (sender.selectedIndex == 1) {
        [accountType setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        is_celeb = @"1";
        
    }
    [self rel];
}

-(void)rel{
    dropDown = nil;
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
    BOOL signupValidations = TRUE;
    
    /*  NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,4}";
     NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; */
    
    
    return [emailTest evaluateWithObject:candidate];
}
//////////////Hiding Keyboard Touching Backgground/////////////

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([txtEmail isFirstResponder] && [touch view] != txtEmail) {
        [txtEmail resignFirstResponder];
        
    }
    else if ([txtPassword isFirstResponder] && [touch view] != txtPassword) {
        
        txtPassword.secureTextEntry=YES;
        [txtPassword resignFirstResponder];
        
    } else if ([txtEmail isFirstResponder] && [touch view] != txtEmail) {
        
        [txtEmail resignFirstResponder];
        
    }  else if ([txtDisplayName isFirstResponder] && [touch view] != txtDisplayName) {
        
        [txtDisplayName resignFirstResponder];
        
    }  [super touchesBegan:touches withEvent:event];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [dropDown hideDropDown:senderForNiD];
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if([txtUserName isFirstResponder]){
        
        [txtUserName resignFirstResponder];
        [txtEmail becomeFirstResponder];
        
    }else if ([txtEmail isFirstResponder]){
        [txtEmail resignFirstResponder];
        [txtDisplayName becomeFirstResponder];
        
    }else if ([txtDisplayName isFirstResponder]){
        [txtDisplayName resignFirstResponder];
        [txtPassword becomeFirstResponder];
        
    }else if ([txtPassword isFirstResponder]){
        [txtPassword resignFirstResponder];
       
    }else{
        [txtUserName resignFirstResponder];
        [txtPassword resignFirstResponder];
        [txtEmail resignFirstResponder];
        [txtDisplayName resignFirstResponder];
     
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
