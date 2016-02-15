//
//  SearchFriendsVCViewController.h
//  HydePark
//
//  Created by Mr on 15/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopularUsersModel.h"

@interface SearchFriendsVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    IBOutlet UITextField *searchField;
    IBOutlet UITableView *SearchTable;

    NSArray *usersArray;
    NSArray *arrImages;
    PopularUsersModel *UsersModel;
    NSString *userStatus;
    
    NSUInteger currentSelectedIndex;
    NSString *friendId;
    NSString *searchKeyword;

}
- (IBAction)back:(id)sender;
- (IBAction)Searchbtn:(id)sender;

@end
