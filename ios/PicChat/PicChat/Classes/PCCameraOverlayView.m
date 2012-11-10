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
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 192.0)];
		[self addSubview:headerView];
		
		UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flashButton.frame = CGRectMake(10.0, 0.0, 94.0, 64.0);
		[flashButton setBackgroundImage:[UIImage imageNamed:@"effectsButton_nonActive.png"] forState:UIControlStateNormal];
		[flashButton setBackgroundImage:[UIImage imageNamed:@"effectsButton_Active.png"] forState:UIControlStateHighlighted];
		[flashButton addTarget:self action:@selector(_goFlashToggle) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:flashButton];
		
		UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		optionsButton.frame = CGRectMake(120.0, 0.0, 94.0, 64.0);
		[optionsButton setBackgroundImage:[UIImage imageNamed:@"optionsButton_nonActive.png"] forState:UIControlStateNormal];
		[optionsButton setBackgroundImage:[UIImage imageNamed:@"optionsButton_Active.png"] forState:UIControlStateHighlighted];
		[optionsButton addTarget:self action:@selector(_goOptions) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:optionsButton];
		
		UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		changeCameraButton.frame = CGRectMake(220.0, 0.0, 94.0, 64.0);
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipBoard_nonActive.png"] forState:UIControlStateNormal];
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipBoard_Active.png"] forState:UIControlStateHighlighted];
		[changeCameraButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:changeCameraButton];
		
		UIImageView *footerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, frame.size.height - 48.0, 320.0, 48.0)];
		footerImgView.image = [UIImage imageNamed:@"footerBG.png"];
		footerImgView.userInteractionEnabled = YES;
		[self addSubview:footerImgView];
		
		UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
		leftButton.frame = CGRectMake(0.0, 0.0, 64.0, 48.0);
		[leftButton setBackgroundImage:[UIImage imageNamed:@"leftIcon_nonActive.png"] forState:UIControlStateNormal];
		[leftButton setBackgroundImage:[UIImage imageNamed:@"leftIcon_Active.png"] forState:UIControlStateHighlighted];
		[leftButton addTarget:self action:@selector(_goLeft) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:leftButton];
		
		UIButton *midButton = [UIButton buttonWithType:UIButtonTypeCustom];
		midButton.frame = CGRectMake(64.0, 0.0, 191.0, 48.0);
		[midButton setBackgroundImage:[UIImage imageNamed:@"middleIcon_nonActive.png"] forState:UIControlStateNormal];
		[midButton setBackgroundImage:[UIImage imageNamed:@"middleIcon_Active.png"] forState:UIControlStateHighlighted];
		[midButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:midButton];
		
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rightButton.frame = CGRectMake(255.0, 0.0, 64.0, 48.0);
		[rightButton setBackgroundImage:[UIImage imageNamed:@"rightIcon_nonActive.png"] forState:UIControlStateNormal];
		[rightButton setBackgroundImage:[UIImage imageNamed:@"rightIcon_Active.png"] forState:UIControlStateHighlighted];
		[rightButton addTarget:self action:@selector(_goRight) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:rightButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goFlashToggle {
	[_delegate cameraOverlayViewChangeFlash:self];
}

- (void)_goOptions {
	[self _showCameraRoll];
}

- (void)_goFlipCamera {
	[self _changeCamera];
}

- (void)_goLeft {
	[_delegate cameraOverlayViewLeftTabTapped:self];
}

- (void)_goTakePhoto {
	[self _takePicture];
}

- (void)_goRight {
	[_delegate cameraOverlayViewRightTabTapped:self];
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
