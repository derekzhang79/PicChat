//
//  PCSubmitChatViewController.h
//  PicChat
//
//  Created by Matthew Holcombe on 11.02.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCSubmitChatViewController : UIViewController

- (id)initWithPhotos:(NSArray *)photos;
- (id)initWithPhotos:(NSArray *)photos withChatID:(int)chatID;
- (id)initWithPhotos:(NSArray *)photos withChatID:(int)chatID withSubject:(NSString *)subject;
- (id)initWithPhotos:(NSArray *)photos withChatID:(int)chatID withSubject:(NSString *)subject withFBID:(NSString *)fbID withFBName:(NSString *)fbName;
- (id)initWithPhotos:(NSArray *)photos withSubject:(NSString *)subject;

@end
