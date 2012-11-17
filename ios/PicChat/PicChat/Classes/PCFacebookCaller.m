//
//  PCFacebookCaller.m
//  PicChat
//
//  Created by Matthew Holcombe on 11.10.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCFacebookCaller.h"
#import "PCAppDelegate.h"

@implementation PCFacebookCaller
@synthesize facebook  =_facebook;

+ (NSArray *)friendIDsFromUser:(NSString *)fbID {
	NSMutableArray *friends = [NSMutableArray array];
	
	[FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		for (NSDictionary *friend in [(NSDictionary *)result objectForKey:@"data"]) {
			[friends addObject:friend];
		}
	}];
	
	return ([friends copy]);
}

+ (void)postStatus:(NSString *)msg {
	if ([PCAppDelegate allowsFBPosting]) {
		NSDictionary *params = [NSDictionary dictionaryWithObject:msg forKey:@"message"];
		[FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
			NSLog(@"POSTED STATUS");
		}];
	}
}

+ (void)postToActivity:(PCChatEntryVO *)vo withAction:(NSString *)action {
	if ([PCAppDelegate allowsFBPosting]) {
		NSMutableDictionary *params = [NSMutableDictionary new];
		[params setObject:[NSString stringWithFormat:@"%@?cID=%d", [PCAppDelegate facebookCanvasURL], vo.entryID] forKey:@"challenge"];
		//[params setObject:[NSString stringWithFormat:@"%@_l.jpg", vo.imageURL] forKey:@"image[0][url]"];
		
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"me/pchallenge:%@", action] parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
			NSLog(@"POSTED TO ACTVITY :[%@]",[result objectForKey:@"id"]);
			
//			if (error)
//				[[[UIAlertView alloc] initWithTitle:@"Result" message:[NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code] delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
		}];
	}
}

+ (void)postToTicker:(NSString *)msg {
	if ([PCAppDelegate allowsFBPosting]) {
	}
}

+ (void)postToTimeline:(PCChatEntryVO *)vo {
	if ([PCAppDelegate allowsFBPosting]) {
		NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
													  [NSString stringWithFormat:@"%@?cID=%d", [PCAppDelegate facebookCanvasURL], vo.entryID], @"link",
													  [NSString stringWithFormat:@"%@_l.jpg", [vo.images objectAtIndex:0]], @"picture",
													  vo.authorName, @"name",
													  @"", @"caption",
													  vo.participantName, @"description", nil];
		
		[FBRequestConnection startWithGraphPath:@"me/feed" parameters:postParams HTTPMethod:@"POST" completionHandler:
		 ^(FBRequestConnection *connection, id result, NSError *error) {
			 NSString *alertText;
			 
			 if (error)
				 alertText = [NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code];
			 
			 else
				 alertText = [NSString stringWithFormat: @"Posted action, id: %@", [result objectForKey:@"id"]];
			 
			 
			 //[[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
		 }];
	}
}

+ (void)postToFriendTimeline:(NSString *)fbID chat:(PCChatEntryVO *)vo {
	if ([PCAppDelegate allowsFBPosting]) {
		NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
													  [NSString stringWithFormat:@"%@?cID=%d", [PCAppDelegate facebookCanvasURL], vo.entryID], @"link",
													  [NSString stringWithFormat:@"%@_l.jpg", [vo.images objectAtIndex:0]], @"picture",
													  vo.authorName, @"name",
													  @"", @"caption",
													  vo.participantName, @"description", nil];
		
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed", fbID] parameters:postParams HTTPMethod:@"POST" completionHandler:
		 ^(FBRequestConnection *connection, id result, NSError *error) {
			 NSString *alertText;
			 
			 if (error)
				 alertText = [NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code];
			 
			 else
				 alertText = [NSString stringWithFormat: @"Posted action, id: %@", [result objectForKey:@"id"]];
			 
			 
			 //[[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
		 }];
	}
}

+ (void)postMessageToFriendTimeline:(NSString *)fbID message:(NSString *)msg {
	if ([PCAppDelegate allowsFBPosting]) {
		NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
													  msg, @"message",
													  [NSString stringWithFormat:@"%@", [PCAppDelegate facebookCanvasURL]], @"link",
													  @"name here", @"name",
													  @"caption", @"caption",
													  @"info", @"description", nil];
		
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed", fbID] parameters:postParams HTTPMethod:@"POST" completionHandler:
		 ^(FBRequestConnection *connection, id result, NSError *error) {
			 NSString *alertText;
			 
			 if (error)
				 alertText = [NSString stringWithFormat:@"error: description = %@, code = %d", error.description, error.code];
			 
			 else
				 alertText = [NSString stringWithFormat: @"Posted action, id: %@", [result objectForKey:@"id"]];
			 
			 
			 //[[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
		 }];
	}
}

+ (void)sendAppRequestToUser:(NSString *)fbID {
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 @"I'm inviting you to PicChat!",  @"message",
											 fbID, @"to",
											 nil];
	
	Facebook *facebook = [[Facebook alloc] initWithAppId:@"435929366454543" andDelegate:nil];
	facebook.accessToken = FBSession.activeSession.accessToken;
	facebook.expirationDate = FBSession.activeSession.expirationDate;
	
	[facebook enableFrictionlessRequests];
	[facebook dialog:@"apprequests"
			 andParams:params
		  andDelegate:nil];
}

+ (void)sendAppRequestBroadcast {
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 @"I'm inviting you to PicChat!",  @"message",
											 nil];
	
	Facebook *facebook = [[Facebook alloc] initWithAppId:@"435929366454543" andDelegate:nil];
	facebook.accessToken = FBSession.activeSession.accessToken;
	facebook.expirationDate = FBSession.activeSession.expirationDate;
	
	[facebook enableFrictionlessRequests];
	[facebook dialog:@"apprequests"
			 andParams:params
		  andDelegate:nil];
}

+ (void)sendAppRequestBroadcastWithIDs:(NSArray *)ids {
	NSString *list = @"";
	
	for (NSString *fbID in ids) {
		list = [list stringByAppendingFormat:@"%@,", fbID];
	}
	
	list = [list substringToIndex:[list length] - 1];
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 @"I'm inviting you to PicChat!",  @"message",
											 list, @"to",
											 nil];
	
	Facebook *facebook = [[Facebook alloc] initWithAppId:@"435929366454543" andDelegate:nil];
	facebook.accessToken = FBSession.activeSession.accessToken;
	facebook.expirationDate = FBSession.activeSession.expirationDate;
	
	[facebook enableFrictionlessRequests];
	[facebook dialog:@"apprequests"
			 andParams:params
		  andDelegate:nil];
}

@end
