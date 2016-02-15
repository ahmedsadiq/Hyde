//
//  topicsModel.h
//  HydePark
//
//  Created by Mr on 26/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface topicsModel : NSObject

@property (nonatomic, retain) NSString *beams_count;
@property (nonatomic, retain) NSString *topic_id;
@property (nonatomic, retain) NSString *topic_image;
@property (nonatomic, retain) NSString *topic_name;
@property (nonatomic, retain) NSMutableArray *topics_array;
@property (nonatomic, retain) NSMutableArray *images_array;
@property (nonatomic, retain) NSMutableArray *names_array;
@property (nonatomic, retain) NSMutableArray *beams_array;
@end
