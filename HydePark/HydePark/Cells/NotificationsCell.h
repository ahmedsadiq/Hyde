//
//  NotificationsCell.h
//  HydePark
//
//  Created by Mr on 15/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsCell : UITableViewCell
{
    
    IBOutlet UIImageView *notifImage;
    IBOutlet UILabel *Name;
    IBOutlet UILabel *Time;
    IBOutlet UILabel *message;
    IBOutlet UIButton *notifyBtn;
}


@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic, strong)  UILabel *Time;
@property (nonatomic, strong)  UIImageView *notifImage;
//@property (nonatomic, strong)  UILabel *Name;
@property (nonatomic, strong)  UILabel *message;
@property (nonatomic,strong)  UIButton *notifyBtn;
@end
