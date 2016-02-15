//
//  SearchCell.h
//  HydePark
//
//  Created by Mr on 15/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface SearchCell : UITableViewCell
{
    
    IBOutlet UIButton *tagbtn;
    IBOutlet AsyncImageView *profilePic;
    IBOutlet UILabel *friendsName;
    IBOutlet UIButton *statusImage;
    IBOutlet UIButton *friendsChannelBtn;
}
@property (strong, nonatomic) UIButton *friendsChannelBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityInd;

@property (nonatomic, strong) AsyncImageView *profilePic;
@property (nonatomic, strong) UILabel *friendsName;
@property (nonatomic, strong) UIButton *statusImage;
@property (nonatomic, strong) UIButton *tagbtn;
@end
