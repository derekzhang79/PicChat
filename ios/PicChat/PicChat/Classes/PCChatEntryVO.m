//
//  PCChatEntryVO.m
//  PicChat
//
//  Created by Matthew Holcombe on 11.01.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCChatEntryVO.h"

@implementation PCChatEntryVO

@synthesize dictionary;
@synthesize entryID, authorID, authorName, authorFB, participantID, participantName, participantFB, images, addedDate;

+ (PCChatEntryVO *)entryWithDictionary:(NSDictionary *)dictionary {
	PCChatEntryVO *vo = [[PCChatEntryVO alloc] init];
	
	vo.dictionary = dictionary;
	
	vo.entryID = [[dictionary objectForKey:@"id"] intValue];
	vo.authorID = [[dictionary objectForKey:@"author_id"] intValue];
	vo.authorName = [dictionary objectForKey:@"author_name"];
	vo.authorFB = [dictionary objectForKey:@"author_fb"];
	vo.participantID = [[dictionary objectForKey:@"participant_id"] intValue];
	vo.participantName = [dictionary objectForKey:@"participant_name"];
	vo.participantFB = [dictionary objectForKey:@"participant_fb"];
	
	vo.images = [NSMutableArray array];
	for (NSDictionary *imgDict in [dictionary objectForKey:@"images"]) {
		[vo.images addObject:[imgDict objectForKey:@"url"]];
	}
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.addedDate = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	
	return (vo);
}

- (void)dealloc {
	self.authorName = nil;
	self.authorFB = nil;
	self.participantName = nil;
	self.participantFB = nil;
	self.images = nil;
	self.addedDate = nil;
}

@end
