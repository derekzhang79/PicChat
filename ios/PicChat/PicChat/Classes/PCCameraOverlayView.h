//
//  PCCameraOverlayView.h
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PCCameraViewController.h"

@protocol PCCameraOverlayViewDelegate;
@interface PCCameraOverlayView : UIView

@property(nonatomic, assign) id <PCCameraOverlayViewDelegate> delegate;

@end


@protocol PCCameraOverlayViewDelegate
- (void)pcCameraOverlayViewTakePicture:(PCCameraOverlayView *)pcCameraOverlayView;
- (void)pcCameraOverlayViewChangeCamera:(PCCameraOverlayView *)pcCameraOverlayView;
- (void)pcCameraOverlayViewShowCameraRoll:(PCCameraOverlayView *)pcCameraOverlayView;
- (void)pcCameraOverlayViewCloseCamera:(PCCameraOverlayView *)pcCameraOverlayView;
@optional
- (void)pcCameraOverlayViewChangeFlash:(PCCameraOverlayView *)pcCameraOverlayView;
- (void)pcCameraOverlayViewHidePreview:(PCCameraOverlayView *)pcCameraOverlayView;
@end