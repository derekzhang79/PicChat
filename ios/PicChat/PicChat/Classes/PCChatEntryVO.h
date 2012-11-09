//
//  PCChatEntryVO.h
//  PicChat
//
//  Created by Matthew Holcombe on 11.01.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCChatEntryVO : NSObject
+ (PCChatEntryVO *)entryWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int entryID;
@property (nonatomic) int authorID;
@property (nonatomic, retain) NSString *authorName;
@property (nonatomic, retain) NSString *authorFB;
@property (nonatomic) int participantID;
@property (nonatomic, retain) NSString *participantName;
@property (nonatomic, retain) NSString *participantFB;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSDate *addedDate;

@end
