//
//  VideoModel.h
//  HydePark
//
//  Created by Apple on 19/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject
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
@property (nonatomic, retain) NSString *Tags;
@property (nonatomic, retain) NSString *message_Thread;
@property (nonatomic, retain) NSString *image_link;
@property (nonatomic, retain) NSString *is_anonymous;
@property (nonatomic, retain) NSString *videoID;

@property (nonatomic, retain) NSMutableArray *videoArray;
@end
