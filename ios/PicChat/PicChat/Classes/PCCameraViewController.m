//
//  PCCameraViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "PCCameraViewController.h"

#import "PCCameraOverlayView.h"

@interface PCCameraViewController () <PCCameraOverlayViewDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) PCCameraOverlayView *cameraOverlayView;
@property(nonatomic, strong) NSTimer *focusTimer;

- (void)_showOverlay;
- (void)_presentCamera;
@end

@implementation PCCameraViewController

@synthesize cameraOverlayView = _cameraOverlayView;

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor greenColor];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showCamera:) name:@"SHOW_CAMERA" object:nil];
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self _presentCamera];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)_presentCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA" object:nil];
		
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		_imagePicker.delegate = self;
		_imagePicker.allowsEditing = NO;
		_imagePicker.cameraOverlayView = nil;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.wantsFullScreenLayout = NO;
		_imagePicker.showsCameraControls = NO;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:^(void) {
			[self performSelector:@selector(_showOverlay) withObject:nil afterDelay:0.5];
		}];
		
	} else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		_imagePicker.delegate = self;
		_imagePicker.allowsEditing = NO;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.wantsFullScreenLayout = NO;
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:nil];
	}
}

- (void)_showOverlay {
	_cameraOverlayView = [[PCCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_cameraOverlayView.delegate = self;
	
	_imagePicker.cameraOverlayView = _cameraOverlayView;
	_focusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(autofocusCamera) userInfo:nil repeats:YES];
}

- (void)autofocusCamera {
	NSArray *devices = [AVCaptureDevice devices];
	NSError *error;
	for (AVCaptureDevice *device in devices) {
		if ([device position] == AVCaptureDevicePositionBack) {
			[device lockForConfiguration:&error];
			if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            device.focusMode = AVCaptureFocusModeAutoFocus;
			}
			
			[device unlockForConfiguration];
		}
	}
}

#pragma mark - Notifications
- (void)_showCamera:(NSNotification *)notification {
	[self _presentCamera];
}

#pragma mark - CameraOverlay Delegates
- (void)cameraOverlayViewTakePicture:(PCCameraOverlayView *)cameraOverlayView {
	[_imagePicker takePicture];
}

- (void)cameraOverlayViewChangeCamera:(PCCameraOverlayView *)cameraOverlayView {
	if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		
	else
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
}

- (void)cameraOverlayViewShowCameraRoll:(PCCameraOverlayView *)cameraOverlayView {
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cameraOverlayViewCloseCamera:(PCCameraOverlayView *)cameraOverlayView {
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}];
}

@end
