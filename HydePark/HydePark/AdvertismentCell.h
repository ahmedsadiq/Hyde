//
//  AdvertismentCell.h
//  HydePark
//
//  Created by Ahmed Sadiq on 24/05/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvertismentCell : UITableViewCell {
    NSTimer *myTimer;
    int counter1;
}
@property (weak, nonatomic) IBOutlet UIImageView *ad1;
@property (weak, nonatomic) IBOutlet UIImageView *ad2;
@property (weak, nonatomic) IBOutlet UIImageView *ad3;

@end
