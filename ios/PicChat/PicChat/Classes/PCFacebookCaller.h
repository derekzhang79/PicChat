//
//  PCFacebookCaller.h
//  PicChat
//
//  Created by Matthew Holcombe on 11.10.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

#import "PCChatVO.h"

@interface PCFacebookCaller : NSObject
@property (strong, nonatomic) Facebook *facebook;


+ (NSArray *)friendIDsFromUser:(NSString *)fbID;
+ (void)postToActivity:(PCChatVO *)vo withAction:(NSString *)action;
+ (void)postStatus:(NSString *)msg;
+ (void)postToTimeline:(PCChatVO *)vo;
+ (void)postToTicker:(NSString *)msg;
+ (void)postToFriendTimeline:(NSString *)fbID chat:(PCChatVO *)vo;
+ (void)postMessageToFriendTimeline:(NSString *)fbID message:(NSString *)msg;
+ (void)sendAppRequestToUser:(NSString *)fbID;
+ (void)sendAppRequestBroadcast;
+ (void)sendAppRequestBroadcastWithIDs:(NSArray *)ids;

@end
