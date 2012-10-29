//
//  PCCameraViewController.h
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (void)showLibrary;
- (void)takePicture;
- (void)closeCamera;
- (void)changeCamera;

@end
