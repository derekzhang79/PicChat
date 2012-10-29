//
//  PCCameraOverlayView.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCCameraOverlayView.h"

@interface PCCameraOverlayView()
- (void)_takePicture;

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
	[_delegate pcCameraOverlayViewTakePicture:self];
}

@end
