//
//  PopularUsersVC.h
//  HydePark
//
//  Created by Mr on 24/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopularUsersModel.h"

@interface PopularUsersVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *usersArray;
    NSArray *arrImages;
    PopularUsersModel *PopUsers;
    NSString *userStatus;
    
    NSUInteger currentSelectedIndex;
    NSString *friendId;
    
    IBOutlet UITextField *searchField;
    IBOutlet UITableView *PopularUserTbl;
    BOOL serverCall;
    BOOL goSearch;
    BOOL cannotScroll;
    int pageNum;
    int searchPageNum;
    
}
- (IBAction)back:(id)sender;
- (IBAction)Searchbtn:(id)sender;
- (void)statusPressed:(UIButton *)sender;

@end
