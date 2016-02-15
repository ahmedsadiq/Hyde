//
//  PopularUsersModel.h
//  HydePark
//
//  Created by Mr on 24/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PopularUsersModel : NSObject

@property (nonatomic, retain) NSString *full_name;
@property (nonatomic, retain) NSString *profile_link;
@property (nonatomic, retain) NSString *profile_type;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *friendID;
@property (nonatomic, retain) NSMutableArray *PopUsersArray;
@property (nonatomic, retain) NSMutableArray *imagesArray;

@end
