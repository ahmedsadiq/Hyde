//
//  myBeamsModel.h
//  HydePark
//
//  Created by Mr on 17/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface myBeamsModel : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *comments_count;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *topic_id;
@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *profile_image;
@property (nonatomic, retain) NSString *like_count;
@property (nonatomic, retain) NSString *like_by_me;
@property (nonatomic, retain) NSString *seen_count;
@property (nonatomic, retain) NSString *video_thumbnail_link;
@property (nonatomic, retain) NSString *video_link;
@property (nonatomic, retain) NSString *video_length;
@property (nonatomic, retain) NSMutableArray *trendingArray;
@property (nonatomic, retain) NSMutableArray *mainArray;
@property (nonatomic, retain) NSMutableArray *imagesArray;
@property (nonatomic, retain) NSMutableArray *ThumbnailsArray;
@property(nonatomic,retain) NSString *is_anonymous;
@property int video_angle;
@property (nonatomic, retain) id VideoID;


@end
