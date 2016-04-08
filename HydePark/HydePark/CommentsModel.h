//
//  CommentsModel.h
//  HydePark
//
//  Created by Mr on 29/06/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentsModel : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *comments_count;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *topic_id;
@property (nonatomic, retain) NSString *like_count;
@property (nonatomic, retain) NSString *seen_count;
@property (nonatomic, retain) NSString *image_link;
@property (nonatomic, retain) NSString *video_thumbnail_link;
@property (nonatomic, retain) NSString *video_link;
@property (nonatomic, retain) NSString *video_length;
@property (nonatomic, retain) NSString *comment_like_count;
@property (nonatomic, retain) NSString *liked_by_me;
@property (nonatomic, retain) NSString *mute;
@property (nonatomic, retain) NSString *timestamp;
@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *profile_link;
@property (nonatomic, retain) NSString *is_anonymous;
@property (nonatomic, retain) NSString *reply_count;
@property (nonatomic, retain) NSMutableArray *CommentsArray;
@property (nonatomic, retain) NSMutableArray *mainArray;
@property (nonatomic, retain) NSMutableArray *ImagesArray;
@property (nonatomic, retain) NSMutableArray *ThumbnailsArray;
@property (nonatomic, retain) NSMutableArray *ChildCommentsArray;


@property int video_angle;
@property (nonatomic, retain) id VideoID;

@end
