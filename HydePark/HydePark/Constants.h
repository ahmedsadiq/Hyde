//
//  Constants.h
//  HydePark
//
//  Created by Ahmed Sadiq on 14/05/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#ifndef HydePark_Constants_h
#define HydePark_Constants_h

#pragma mark-
#pragma mark Server Calling Constants
#define SERVER_URL @"http://hydepark.witsapplication.com/api/page.php"
#define METHOD_SIGN_UP @"userSignUp"
#define METHOD_LOG_IN @"userLogin"
#define BlueThemeColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define METHOD_UPLOAD_STATUS @"uploadStatus"
#define METHOD_LOGOUT @"userLogout"
#define METHOD_GET_PROFILE @"getProfile"
#define METHOD_GET_USERPROFILE @"getProfileById"
#define METHOD_UPDATE_PROFILE @"updateProfile"
#define METHOD_ACCEPT_REQUEST @"acceptRequest"
#define METHOD_SEND_REQUEST @"sendRequest"
#define METHOD_DELETE_REQUEST @"deleteFriend"
#define METHOD_DELETE_FRIEND @"deleteFriend"
#define METHOD_SEARCH_FRIEND @"searchFriend"
#define METHOD_LIKE_COMMENT @"likeComment"
#define METHOD_LIKE_POST @"likePost"
#define METHOD_POST_SEEN @"postSeen"
#define METHOD_DELETE_POST @"deletePost"
#define METHOD_GET_BEAMS_BY_TOPICS @"getBeamsByTopicids"
#define METHOD_GET_MY_BEAMS @"getMyBeams"
#define METHOD_GET_HOME_CONTENTS @"getHomeContent"
#define METHOD_GET_MY_CHENNAL @"getMyChannel"
#define METHOD_GET_POST_BY_ID @"getPostById"
#define METHOD_EDIT_POST @"editpost"
#define METHOD_TRENDING_VIDEOS @"getTrendingVideos"
#define METHOD_COMMENTS_BY_PARENT_ID @"getCommentsByParentId"
#define METHOD_COMMENTS_POST @"commentPost"
#define METHOD_GET_TOPICS @"getTopics"
#define METHOD_GET_FAMOUS_USERS @"getFamousUsers"
#define METHOD_GET_USERS_CHANNEL @"getUserChannelById"
#define METHOD_GET_NOTIFICATIONS @"getNotifications"
#define METHOD_GET_FOLLOWING_AND_FOLLOWERS @"getFollowersFollowing"

#pragma mark-
#pragma mark Server Response
#define SUCCESS 1

#pragma mark-
#pragma mark Screen Sizes
#define IS_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPAD ([[UIScreen mainScreen] bounds].size.height == 1024)
#define IS_IPHONE_6Plus ([[UIScreen mainScreen] bounds].size.height == 736)
#pragma mark-
#pragma mark Social Logins
#define GOOGlE_SCHEME @"com.txlabz.hydeparks"
#define FACEBOOK_SCHEME @"fb669173346520177"

//#define Client_Id @"922745837972-pn2tsofqg8dqfk3eijjl63sgg15lrj2e.apps.googleusercontent.com"
#define Client_Id @"910966812831-tugtns7pb6oqmasmebqlbufu78k418nd.apps.googleusercontent.com"
///HydePark Instagram ////
#define KAUTHURL @"https://api.instagram.com/oauth/authorize/"
#define kAPIURl @"https://api.instagram.com/v1/users/"
#define KCLIENTID @"1fb26065dc6f4ed29a8c7f935b4e6324"
#define KCLIENTSERCRET @"a06b76abab31430f8a1539b34e3ea885"
#define kREDIRECTURI @"http://opensource.brickred.com/socialauthdemo/socialAuthSuccessAction.do"

#endif
