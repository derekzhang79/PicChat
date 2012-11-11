//
//  PCCameraViewController.h
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (id)initWithChatID:(int)chatID;
- (id)initWithChatID:(int)chatID withSubject:(NSString *)subject;
@end
