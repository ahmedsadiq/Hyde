//
//  myChannelModel.h
//  HydePark
//
//  Created by Mr on 17/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface myChannelModel : NSObject

///// Profile ////
@property (nonatomic, retain) NSString *beams_count;
@property (nonatomic, retain) NSString *friends_count;
@property (nonatomic, retain) NSString *likes_count;
@property (nonatomic, retain) NSString *cover_link;
@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *profile_image;
@property (nonatomic, retain) NSString *cover_image;
@property (nonatomic, retain) NSString *full_name;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *is_celeb;
@property (nonatomic, retain) NSString *reply_count;

///// my channel Post////
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *comments_count;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *topic_id;
@property (nonatomic, retain) NSString *like_count;
@property (nonatomic, retain) NSString *like_by_me;
@property (nonatomic, retain) NSString *seen_count;
@property (nonatomic, retain) NSString *video_thumbnail_link;
@property (nonatomic, retain) NSString *video_link;
@property (nonatomic, retain) NSString *video_length;
@property (nonatomic, retain) NSString *Tags;
@property (nonatomic, retain) NSString *image_link;
@property (nonatomic, retain) NSString *is_anonymous;
@property (nonatomic, retain) NSString *Post_ID;

@property (nonatomic, retain) NSMutableArray *trendingArray;
@property (nonatomic, retain) NSMutableArray *mainArray;
@property (nonatomic, retain) NSMutableArray *ImagesArray;
@property (nonatomic, retain) NSMutableArray *ThumbnailsArray;

@property int video_angle;
@property (nonatomic, retain) id VideoID;


@end
