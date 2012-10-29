//
//  PCCameraViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCCameraViewController.h"

#import "PCCameraOverlayView.h"

@interface PCCameraViewController ()
@property (nonatomic, strong) PCCameraOverlayView *cameraOverlayView;
@end

@implementation PCCameraViewController

@synthesize cameraOverlayView = _cameraOverlayView;

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor greenColor];
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
