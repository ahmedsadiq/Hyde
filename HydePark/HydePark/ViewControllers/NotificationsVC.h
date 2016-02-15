//
//  NotificationsVC.h
//  HydePark
//
//  Created by Mr on 15/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationsModel.h"
#import "ASIFormDataRequest.h"

@interface NotificationsVC : UIViewController<UITableViewDataSource,UITableViewDelegate,ASIHTTPRequestDelegate>
{

    IBOutlet UITableView *notificationsTbl;
  
    NotificationsModel *notifModel;
    NSArray *notificationsArray;
}
- (IBAction)back:(id)sender;
@end
