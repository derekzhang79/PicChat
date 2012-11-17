//
//  PCCameraViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AnimatedGif.h"
#import "UIImage+fixOrientation.h"
#import "Mixpanel.h"

#import "PCAppDelegate.h"
#import "PCCameraViewController.h"
#import "PCCameraOverlayView.h"
#import "PCSubmitChatViewController.h"
#import "PCHistoryViewController.h"
#import "PCPeopleViewController.h"
#import "PCSettingsViewController.h"
#import "PCLoginViewController.h"
#import "PCFacebookCaller.h"

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"

@interface PCCameraViewController () <UINavigationControllerDelegate, ELCImagePickerControllerDelegate, PCCameraOverlayViewDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) PCCameraOverlayView *cameraOverlayView;
@property(nonatomic, strong) NSTimer *focusTimer;
@property(nonatomic, strong) NSTimer *photoTimer;
@property(nonatomic) int photoCounter;
@property(nonatomic) int chatID;
@property(nonatomic) int blockCounter;
@property(nonatomic) BOOL isFirstAppearance;
@property(nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSString *subjectName;

- (void)_showOverlay;
- (void)_presentCamera;
@end

@implementation PCCameraViewController

@synthesize cameraOverlayView = _cameraOverlayView;

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor blackColor];
		_blockCounter = 0;
		_chatID = 0;
		_isFirstAppearance = YES;
		_subjectName = @"";
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showCamera:) name:@"SHOW_CAMERA" object:nil];
	}
	
	return (self);
}

- (id)initWithChatID:(int)chatID {
	if ((self = [self init])) {
		_subjectName = @"";
		_chatID = chatID;
		_isFirstAppearance = YES;
	}
	
	return (self);
}

- (id)initWithChatID:(int)chatID withSubject:(NSString *)subject {
	if ((self = [self init])) {
		_chatID = chatID;
		_isFirstAppearance = YES;
		_subjectName = subject;
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	NSLog(@"loadView");
	
	//[self _presentCamera];
	
//	UIImageView *secondAnimation = [AnimatedGif getAnimationForGifAtUrl:[NSURL URLWithString:@"http://www.allweb.it/images/4_Humor/emoticon_3d/emoticon_3d_53.gif"]];
//	[self.view addSubview:secondAnimation];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	NSLog(@"viewDidLoad");
	
	//[self performSelector:@selector(_presentCamera) withObject:nil afterDelay:0.125];
	
//	FBLoginView *loginview = [[FBLoginView alloc] init];
//	loginview.frame = CGRectOffset(loginview.frame, 5, 5);
//	//loginview.delegate = self;
//	[self.view addSubview:loginview];
//	[loginview sizeToFit];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	NSLog(@"viewDidAppear");
	
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		[self performSelector:@selector(_presentCamera) withObject:nil afterDelay:0.125];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)_presentCamera {
	NSLog(@"_presentCamera[%d]", ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]));
	
	_photos = [NSMutableArray array];
	if ([_subjectName isEqual:@""])
		_subjectName = [PCAppDelegate rndDefaultSubject];
	
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
//		ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
//		ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
//		[albumController setParent:elcPicker];
//		[elcPicker setDelegate:self];
//		
//		PCAppDelegate *app = (PCAppDelegate *)[[UIApplication sharedApplication] delegate];
//		[self.navigationController pushViewController:elcPicker animated:NO];
//		[app.tabBarController presentViewController:elcPicker animated:NO completion:nil];
		
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
	NSLog(@"showOverlay");
	
	_cameraOverlayView = [[PCCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_cameraOverlayView.delegate = self;
	[_cameraOverlayView setSubjectName:_subjectName];
	
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

- (void)_takePhoto {
	_photoCounter++;
	
	[_cameraOverlayView updateCount:_photoCounter];
	
	if (_photoCounter >= 4) {
		[_photoTimer invalidate];
		_photoTimer = nil;
	
	} else
		[_imagePicker takePicture];
}

#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[_focusTimer invalidate];
	_focusTimer = nil;
	
	NSLog(@"imagePickerController:didFinishPickingMediaWithInfo:");
	
	[[Mixpanel sharedInstance] track:@"Take Photo"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	image = [image fixOrientation];
	
	[_photos addObject:image];
	
	if (_photoCounter == 3 || _imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
		[self dismissViewControllerAnimated:NO completion:^(void) {
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			
			_isFirstAppearance = YES;
			_subjectName = _cameraOverlayView.subjectName;
			
			if ([_subjectName isEqual:@""])
				_subjectName = [PCAppDelegate rndDefaultSubject];
			
			if ([_subjectName hasPrefix:@"#"])
				_subjectName = [_subjectName substringFromIndex:1];
			
			if ([PCAppDelegate chatID] == 0)
				[self.navigationController pushViewController:[[PCSubmitChatViewController alloc] initWithPhotos:_photos withSubject:_subjectName] animated:YES];
			
			else
				[self.navigationController pushViewController:[[PCSubmitChatViewController alloc] initWithPhotos:_photos withChatID:[PCAppDelegate chatID] withSubject:_subjectName] animated:YES];
		}];
	}
	
	//UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		_imagePicker.cameraOverlayView = nil;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.wantsFullScreenLayout = NO;
		_imagePicker.showsCameraControls = NO;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		
		[self _showOverlay];
		
	} else {
//		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
//		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
		
		[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
			[self.navigationController dismissViewControllerAnimated:NO completion:^(void) {
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCHistoryViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[[PCAppDelegate rootViewController] presentViewController:navigationController animated:NO completion:nil];
			}];
		}];
	}
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	if (error) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
																		message:@"Unable to save image to Photo Album."
																	  delegate:nil
														  cancelButtonTitle:@"OK"
														  otherButtonTitles:nil];
		[alert show];
	}
}


#pragma mark - ELCImagePickerController Delegates
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
	//	[picker dismissViewControllerAnimated:NO completion:nil];
	
	for (NSDictionary *dict in info) {
		UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
		[_photos addObject:[image fixOrientation]];
	}
	
	[self.navigationController pushViewController:[[PCSubmitChatViewController alloc] initWithPhotos:_photos] animated:YES];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
	[self dismissViewControllerAnimated:NO completion:^(void){
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[self.navigationController popToRootViewControllerAnimated:NO];
	}];
}


#pragma mark - CameraOverlay Delegates
- (void)cameraOverlayViewTakePicture:(PCCameraOverlayView *)cameraOverlayView {
	//[_imagePicker takePicture];
	
	_photoCounter = 0;
	_photoTimer = [NSTimer scheduledTimerWithTimeInterval:kPhotoTimelapseIncrement target:self selector:@selector(_takePhoto) userInfo:nil repeats:YES];
}

- (void)cameraOverlayViewChangeCamera:(PCCameraOverlayView *)cameraOverlayView {
	if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		
	else
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
}

- (void)cameraOverlayViewShowCameraRoll:(PCCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Camera Roll"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 nil]];
	
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
//	ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
//	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
//	[albumController setParent:elcPicker];
//	[elcPicker setDelegate:self];
//	
//	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
//		[self.navigationController presentViewController:elcPicker animated:NO completion:nil];
//	}];
	
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[ELCImagePickerController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self.navigationController presentViewController:navigationController animated:YES completion:nil];
	
	//[self.navigationController presentViewController:elcPicker animated:NO completion:nil];
}

- (void)cameraOverlayViewCloseCamera:(PCCameraOverlayView *)cameraOverlayView {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[self.navigationController dismissViewControllerAnimated:NO completion:nil];
	}];
}

- (void)cameraOverlayViewChangeFlash:(PCCameraOverlayView *)cameraOverlayView {
	if (_imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashModeOff)
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
	
	else if (_imagePicker.cameraFlashMode == UIImagePickerControllerCameraFlashModeOn)
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
}

- (void)cameraOverlayViewLeftTabTapped:(PCCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Chat List"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 nil]];
	
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[self.navigationController dismissViewControllerAnimated:NO completion:^(void) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCHistoryViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[[PCAppDelegate rootViewController] presentViewController:navigationController animated:NO completion:nil];
		}];
	}];
}

- (void)cameraOverlayViewRightTabTapped:(PCCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Invite Friends"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 nil]];
	
//	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
//		[self.navigationController dismissViewControllerAnimated:NO completion:^(void) {
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCPeopleViewController alloc] init]];
//			[navigationController setNavigationBarHidden:YES];
//			[[PCAppDelegate rootViewController] presentViewController:navigationController animated:NO completion:nil];
//		}];
//	}];
	
	if (FBSession.activeSession.state != 513) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCLoginViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
		
	} else {
		NSRange range;
		range.length = 50;
		range.location = _blockCounter * range.length;
		
		if (range.location + range.length > [[PCAppDelegate fbFriends] count])
			range.length = [[PCAppDelegate fbFriends] count] - range.location;
		
		if (range.location > [[PCAppDelegate fbFriends] count]) {
			range.location = 0;
			range.length = [[PCAppDelegate fbFriends] count];
		}
		
		NSLog(@"INVITING (%d-%d)/%d", range.location, range.location + range.length, [[PCAppDelegate fbFriends] count]);
		[PCFacebookCaller sendAppRequestBroadcastWithIDs:[[PCAppDelegate fbFriends] subarrayWithRange:range]];
		_blockCounter++;
	}
}

- (void)cameraOverlayViewShowOptions:(PCCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Options"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 nil]];
	
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		_isFirstAppearance = YES;
		[self.navigationController pushViewController:[[PCSettingsViewController alloc] init] animated:NO];
	}];
}

@end
