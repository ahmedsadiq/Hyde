//
//  NotificationsModel.h
//  HydePark
//
//  Created by Mr on 15/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationsModel : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *notificationType;
@property (nonatomic, retain) NSMutableArray *notificationArray;
@property (nonatomic, retain) NSDictionary *notificationsData;
@property (nonatomic, retain) NSDictionary *postData;
@property (nonatomic, retain) NSString *friend_ID;
@property (nonatomic, retain) id notif_ID ;
@property (nonatomic, retain) NSString *post_ID;
@property (nonatomic, retain) id seen;
@property (nonatomic, retain) NSString *profile_link;
@property (nonatomic, retain) NSString *parent_Id;

@end
