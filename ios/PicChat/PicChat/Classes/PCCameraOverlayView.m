//
//  PCCameraOverlayView.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCCameraOverlayView.h"

#import "PCAppDelegate.h"

@interface PCCameraOverlayView()
@property (nonatomic, strong) UIImageView *overlayImgView;

- (void)_takePicture;
- (void)_setFlash;
- (void)_changeCamera;
- (void)_showCameraRoll;
- (void)_closeCamera;
- (void)_hidePreview;
@end

@implementation PCCameraOverlayView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
	}
	
	return (self);
}


#pragma mark - Delegate Calls
- (void)_takePicture {
	[_delegate cameraOverlayViewTakePicture:self];
}
- (void)_setFlash {
	[_delegate cameraOverlayViewChangeFlash:self];
}

- (void)_changeCamera {
	[_delegate cameraOverlayViewChangeCamera:self];
}

- (void)_showCameraRoll {
	[_delegate cameraOverlayViewShowCameraRoll:self];
}

- (void)_closeCamera {
	[_delegate cameraOverlayViewCloseCamera:self];
}

- (void)_hidePreview {
	_overlayImgView = [[UIImageView alloc] initWithFrame:self.bounds];
	_overlayImgView.image = [UIImage imageNamed:([PCAppDelegate isRetina5]) ? @"camerModeBackground-568h.jpg" : @"camerModeBackgroundiPhone.jpg"];
	[self addSubview:_overlayImgView];
	
	[_delegate cameraOverlayViewHidePreview:self];
}

@end
