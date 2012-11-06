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

#import "PCAppDelegate.h"
#import "PCCameraViewController.h"
#import "PCCameraOverlayView.h"
#import "PCSubmitChatViewController.h"

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"

@interface PCCameraViewController () <UINavigationControllerDelegate, ELCImagePickerControllerDelegate, PCCameraOverlayViewDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) PCCameraOverlayView *cameraOverlayView;
@property(nonatomic, strong) NSTimer *focusTimer;
@property(nonatomic, strong) NSTimer *photoTimer;
@property(nonatomic) int photoCounter;
@property(nonatomic, strong) NSMutableArray *photos;

- (void)_showOverlay;
- (void)_presentCamera;
@end

@implementation PCCameraViewController

@synthesize cameraOverlayView = _cameraOverlayView;

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor whiteColor];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showCamera:) name:@"SHOW_CAMERA" object:nil];
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
//	UIImageView *secondAnimation = [AnimatedGif getAnimationForGifAtUrl:[NSURL URLWithString:@"http://www.allweb.it/images/4_Humor/emoticon_3d/emoticon_3d_53.gif"]];
//	[self.view addSubview:secondAnimation];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self performSelector:@selector(_presentCamera) withObject:nil afterDelay:0.125];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self performSelector:@selector(_presentCamera) withObject:nil afterDelay:0.125];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)_presentCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA" object:nil];
		_photos = [NSMutableArray array];
		
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
		ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
		ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
		[albumController setParent:elcPicker];
		[elcPicker setDelegate:self];
		
		PCAppDelegate *app = (PCAppDelegate *)[[UIApplication sharedApplication] delegate];
//		[self.navigationController pushViewController:elcPicker animated:NO];
		
		//[app.tabBarController presentViewController:elcPicker animated:NO completion:nil];

		
//		_imagePicker = [[UIImagePickerController alloc] init];
//		_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//		_imagePicker.delegate = self;
//		_imagePicker.allowsEditing = NO;
//		_imagePicker.navigationBarHidden = YES;
//		_imagePicker.toolbarHidden = YES;
//		_imagePicker.wantsFullScreenLayout = NO;
//		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:nil];
	}
}

- (void)_showOverlay {
	NSLog(@"showOverlay");
	
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

- (void)_takePhoto {
	_photoCounter++;
	
	if (_photoCounter == 4) {
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
	
//	[[Mixpanel sharedInstance] track:@"Take Photo"
//								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
//												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	image = [image fixOrientation];
	
	[_photos addObject:image];
	
	if (_photoCounter == 3) {
		[self dismissViewControllerAnimated:NO completion:^(void) {
			[self.navigationController pushViewController:[[PCSubmitChatViewController alloc] initWithPhotos:_photos] animated:YES];
		}];
	}
	
	//UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	
//	if (image.size.width > image.size.height) {
//		float offset = image.size.height * (image.size.height / image.size.width);
//		image = [HONAppDelegate cropImage:image toRect:CGRectMake(offset * 0.5, 0.0, offset, image.size.height)];
//	}
//	
//	if (image.size.height / image.size.width == 1.5) {
//		float offset = image.size.height - (image.size.width * kPhotoRatio);
//		image = [HONAppDelegate cropImage:image toRect:CGRectMake(0.0, offset * 0.5, image.size.width, (image.size.width * kPhotoRatio))];
//	}
	
//	if (!self.needsChallenger) {
//		[_cameraOverlayView hidePreview];
//		
//		if ([self.subjectName length] == 0)
//			self.subjectName = [HONAppDelegate rndDefaultSubject];
//		
//		if ([self.subjectName hasPrefix:@"#"])
//			self.subjectName = [self.subjectName substringFromIndex:1];
//		
//		AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
//		
//		NSString *filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
//		NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", filename);
//		
//		@try {
//			UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
//			canvasView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:image toSize:CGSizeMake(kLargeW, kLargeH)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW, kLargeW)];
//			
//			UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
//			watermarkImgView.image = [UIImage imageNamed:@"612x612_overlay@2x.png"];
//			[canvasView addSubview:watermarkImgView];
//			
//			CGSize size = [canvasView bounds].size;
//			UIGraphicsBeginImageContext(size);
//			[[canvasView layer] renderInContext:UIGraphicsGetCurrentContext()];
//			UIImage *lImage = UIGraphicsGetImageFromCurrentImageContext();
//			UIGraphicsEndImageContext();
//			
//			UIImage *mImage = [HONAppDelegate scaleImage:image toSize:CGSizeMake(kMediumW * 2.0, kMediumH * 2.0)];
//			UIImage *t1Image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(kThumb1W * 2.0, kThumb1H * 2.0)];
//			
//			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//			_progressHUD.labelText = @"Submitting Challenge…";
//			_progressHUD.mode = MBProgressHUDModeIndeterminate;
//			_progressHUD.graceTime = 2.0;
//			_progressHUD.taskInProgress = YES;
//			
//			[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
//			S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t.jpg", filename] inBucket:@"hotornot-challenges"];
//			por1.contentType = @"image/jpeg";
//			por1.data = UIImageJPEGRepresentation(t1Image, 0.5);
//			[s3 putObject:por1];
//			
//			//			S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t2.jpg", filename] inBucket:@"hotornot-challenges"];
//			//			por2.contentType = @"image/jpeg";
//			//			por2.data = UIImageJPEGRepresentation(t2Image, 1.0);
//			//			[s3 putObject:por2];
//			
//			S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", filename] inBucket:@"hotornot-challenges"];
//			por3.contentType = @"image/jpeg";
//			por3.data = UIImageJPEGRepresentation(mImage, 0.5);
//			[s3 putObject:por3];
//			
//			S3PutObjectRequest *por4 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", filename] inBucket:@"hotornot-challenges"];
//			por4.contentType = @"image/jpeg";
//			por4.data = UIImageJPEGRepresentation(lImage, 0.5);
//			[s3 putObject:por4];
//			
//			
//			
//			ASIFormDataRequest *submitChallengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
//			[submitChallengeRequest setDelegate:self];
//			[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", self.submitAction] forKey:@"action"];
//			[submitChallengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
//			[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", filename] forKey:@"imgURL"];
//			
//			if (self.submitAction == 1)
//				[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
//			
//			else if (self.submitAction == 4) {
//				[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", self.challengeVO.challengeID] forKey:@"challengeID"];
//				
//			} else if (self.submitAction == 8) {
//				[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
//				[submitChallengeRequest setPostValue:self.fbID forKey:@"fbID"];
//				
//			} else if (self.submitAction == 9) {
//				[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
//				[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", self.challengerID] forKey:@"challengerID"];
//			}
//			
//			[submitChallengeRequest startAsynchronous];
//			
//		} @catch (AmazonClientException *exception) {
//			[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//		}
//		
//	} else {
//		[self.navigationController pushViewController:[[HONChallengerPickerViewController alloc] initWithImage:image subjectName:_subjectName] animated:YES];
//	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//		_imagePicker.cameraOverlayView = nil;
//		_imagePicker.navigationBarHidden = YES;
//		_imagePicker.toolbarHidden = YES;
//		_imagePicker.wantsFullScreenLayout = NO;
//		_imagePicker.showsCameraControls = NO;
//		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
//		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
//		
//		[self _showOverlay];
//		
//	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
//	}
	[self.navigationController popToRootViewControllerAnimated:NO];
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
	//_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
	[albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
	
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[self.navigationController presentViewController:elcPicker animated:NO completion:nil];
	}];
	
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[ELCImagePickerController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self.navigationController presentViewController:navigationController animated:YES completion:nil];
	
	//[self.navigationController presentViewController:elcPicker animated:NO completion:nil];
}

- (void)cameraOverlayViewCloseCamera:(PCCameraOverlayView *)cameraOverlayView {
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		//[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
		[self.navigationController popToRootViewControllerAnimated:NO];
	}];
}

@end
