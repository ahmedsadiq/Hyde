//
//  HPCUser.h
//  HydePark
//
//  Created by Ahmed Sadiq on 14/05/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPCUser : NSObject

@property ( strong , nonatomic ) NSString *userID;
@property ( strong , nonatomic ) NSString *userName;
@property ( strong , nonatomic ) NSString *fullName;
@property ( strong , nonatomic ) NSString *email;
@property ( strong , nonatomic ) NSString *dob;
@property ( strong , nonatomic ) NSString *gender;

@end
