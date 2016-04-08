//
//  FriendsVC.h
//  HydePark
//
//  Created by Apple on 04/04/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "ViewController.h"
#import "UserChannelModel.h"
@interface FriendsVC : UIViewController
{
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *NoFollowers;
    NSString *friendId;
    NSUInteger currentSelectedIndex;
    UserChannelModel *userChannelObj;
    NSArray *chPostArray;
    NSArray *chVideosArray;
    NSArray *chArrImage;
    NSArray *chArrThumbnail;
}
@property (strong, nonatomic)   IBOutlet UITableView *follwersAndFollwings;
@property (strong, nonatomic)   NSMutableArray *friendsArray;
@property (strong, nonatomic)   NSString *titles;
@property (nonatomic)           BOOL *NoFriends;

@end
