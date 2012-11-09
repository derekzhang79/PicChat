//
//  PCChatVO.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.29.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCChatVO.h"

@implementation PCChatVO

@synthesize dictionary;
@synthesize chatID, creatorID, creatorName, creatorFB, participantID, participantName, participantFB, statusID, status, subjectID, subjectName, addedDate;

+ (PCChatVO *)chatWithDictionary:(NSDictionary *)dictionary {
	PCChatVO *vo = [[PCChatVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.chatID = [[dictionary objectForKey:@"id"] intValue];
	vo.creatorID = [[dictionary objectForKey:@"creator_id"] intValue];
	vo.creatorName = [dictionary objectForKey:@"creator_name"];
	vo.creatorFB = [dictionary objectForKey:@"creator_fb"];
	vo.participantID = [[dictionary objectForKey:@"participant_id"] intValue];
	vo.participantName = [dictionary objectForKey:@"participant_name"];
	vo.participantFB = [dictionary objectForKey:@"participant_fb"];
	vo.statusID = [[dictionary objectForKey:@"status_id"] intValue];
	vo.subjectID = [[dictionary objectForKey:@"subject_id"] intValue];
	vo.subjectName = [dictionary objectForKey:@"subject_name"];
	
	switch ([[dictionary objectForKey:@"status_id"] intValue]) {
		case 1:
			vo.status = @"Created";
			break;
			
		case 2:
			vo.status = @"Waiting";
			break;
			
		case 3:
			vo.status = @"Active";
			break;
			
		case 4:
			vo.status = @"Archived";
			break;
			
		case 5:
			vo.status = @"Deleted";
			break;
			
		default:
			vo.status = @"Unknown";
			break;
	}
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.addedDate = [dateFormat dateFromString:[dictionary objectForKey:@"added"]];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.creatorName = nil;
	self.creatorFB = nil;
	self.participantName = nil;
	self.participantFB = nil;
	self.status = nil;
	self.subjectName = nil;
	self.addedDate = nil;
}

@end
