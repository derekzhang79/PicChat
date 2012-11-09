//
//  PCChatVO.h
//  PicChat
//
//  Created by Matthew Holcombe on 10.29.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCChatVO : NSObject

+ (PCChatVO *)chatWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int chatID;
@property (nonatomic) int creatorID;
@property (nonatomic, retain) NSString *creatorName;
@property (nonatomic, retain) NSString *creatorFB;
@property (nonatomic) int participantID;
@property (nonatomic, retain) NSString *participantName;
@property (nonatomic, retain) NSString *participantFB;
@property (nonatomic) int statusID;
@property (nonatomic, retain) NSString *status;
@property (nonatomic) int subjectID;
@property (nonatomic, retain) NSString *subjectName;
@property (nonatomic, retain) NSDate *addedDate;

@end
