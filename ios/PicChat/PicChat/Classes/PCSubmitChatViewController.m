//
//  PCSubmitChatViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 11.02.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "FBFriendPickerViewController.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"

#import "PCSubmitChatViewController.h"
#import "PCAppDelegate.h"
#import "PCHeaderView.h"
#import "PCChatVO.h"

@interface PCSubmitChatViewController () <FBFriendPickerDelegate>
@property (nonatomic, strong) UIImageView *photoImgView;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSTimer *photoTimer;
@property (nonatomic) int photoCounter;
@property(nonatomic, strong) NSString *fbID;
@property(nonatomic, strong) NSString *fbName;
@property(nonatomic, strong) NSString *filename;
@property(nonatomic, strong) NSString *subjectName;
@property(nonatomic) int chatID;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation PCSubmitChatViewController

- (id)init {
	if ((self = [super init])) {
		_photos = [NSArray array];
		_photoCounter = 0;
		_subjectName = @"DERP";
	}
	
	return (self);
}


- (id)initWithPhotos:(NSArray *)photos {
	if ((self = [self init])) {
		_photos = photos;
		_chatID = 0;
	}
	
	return (self);
}

- (id)initWithPhotos:(NSArray *)photos withChatID:(int)chatID {
	if ((self = [self init])) {
		_photos = photos;
		_chatID = chatID;
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
	PCHeaderView *headerView = [[PCHeaderView alloc] initWithTitle:@"Select Person"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
	
	_photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 55.0, 300.0, 400.0)];
	_photoImgView.image = [_photos objectAtIndex:0];
	[self.view addSubview:_photoImgView];
	
	_photoTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(_nextPhoto) userInfo:nil repeats:YES];
	
	UIButton *friendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	friendButton.frame = CGRectMake(18.0, 338.0, 284.0, 49.0);
//	[friendButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
//	[friendButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[friendButton setBackgroundColor:[UIColor redColor]];
	[friendButton addTarget:self action:@selector(_goSelectFriend) forControlEvents:UIControlEventTouchUpInside];
	friendButton.hidden = ([PCAppDelegate chatID] != 0);
	[self.view addSubview:friendButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(18.0, 398.0, 284.0, 49.0);
//	[submitButton setBackgroundImage:[UIImage imageNamed:@"challengeRandomButton_nonActive.png"] forState:UIControlStateNormal];
//	[submitButton setBackgroundImage:[UIImage imageNamed:@"challengeRandomButton_Active.png"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmitChat) forControlEvents:UIControlEventTouchUpInside];
	[submitButton setBackgroundColor:[UIColor redColor]];
	[self.view addSubview:submitButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


- (void)_nextPhoto {
	_photoCounter++;
	_photoCounter = _photoCounter % [_photos count];
	
	_photoImgView.image = [_photos objectAtIndex:_photoCounter];
}

#pragma mark - Navigation
- (void)_goBack {
	[_photoTimer invalidate];
	_photoTimer = nil;
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goSelectFriend {
	FBFriendPickerViewController *friendPickerController = [[FBFriendPickerViewController alloc] init];
	friendPickerController.title = @"Pick Friends";
	friendPickerController.allowsMultipleSelection = NO;
	friendPickerController.delegate = self;
	friendPickerController.sortOrdering = FBFriendDisplayByLastName;
	friendPickerController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
																				  initWithTitle:@"Cancel!"
																				  style:UIBarButtonItemStyleBordered
																				  target:self
																				  action:@selector(cancelButtonWasPressed:)];
	
	friendPickerController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
																					initWithTitle:@"Done!"
																					style:UIBarButtonItemStyleBordered
																					target:self
																					action:@selector(doneButtonWasPressed:)];
	[friendPickerController loadData];
	
	// Use the modal wrapper method to display the picker.
	[friendPickerController presentModallyFromViewController:self animated:YES handler:
	 ^(FBViewController *sender, BOOL donePressed) {
		 if (!donePressed)
			 return;
		 
		 if (friendPickerController.selection.count == 0) {
			 [[[UIAlertView alloc] initWithTitle:@"No Friend Selected"
												  message:@"You need to pick a friend."
												 delegate:nil
									 cancelButtonTitle:@"OK"
									 otherButtonTitles:nil]
			  show];
			 
		 } else {
			 // submit
			 _fbID = [[friendPickerController.selection lastObject] objectForKey:@"id"];
			 _fbName = [[friendPickerController.selection lastObject] objectForKey:@"first_name"];
			 //NSLog(@"FRIEND:[%@]", [friendPickerController.selection lastObject]);
		 }
	 }];
}

- (void)_goSubmitChat {
	//NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[PCAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[PCAppDelegate s3Credentials] objectForKey:@"secret"]];
	[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"picchat-entries"]];
	
	_filename = [NSString stringWithFormat:@"%@_%@", [PCAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	
	@try {
//		UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 600.0, 800.0)];
//		canvasView.image = [HONAppDelegate cropImage:[PCAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kLargeW, kLargeH)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW, kLargeW)];
//		
//		UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
//		watermarkImgView.image = [UIImage imageNamed:@"612x612_overlay@2x.png"];
//		[canvasView addSubview:watermarkImgView];
//		
//		CGSize size = [canvasView bounds].size;
//		UIGraphicsBeginImageContext(size);
//		[[canvasView layer] renderInContext:UIGraphicsGetCurrentContext()];
//		UIImage *lImage = UIGraphicsGetImageFromCurrentImageContext();
//		UIGraphicsEndImageContext();
		
		NSLog(@"https://picchat-entries.s3.amazonaws.com/%@", self.filename);
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.labelText = @"Submitting Chat…";
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.graceTime = 2.0;
		_progressHUD.taskInProgress = YES;
		
		int photoIndex = 0;
		NSString *imgURLs = @"";
		for (UIImage *img in _photos) {
			UIImage *scaledImage = [PCAppDelegate scaleImage:img toSize:CGSizeMake(300 * 2.0, 400 * 2.0)];
			NSString *imgURL = [NSString stringWithFormat:@"%@_%d.jpg", self.filename, photoIndex++];
			imgURLs = [imgURLs stringByAppendingFormat:@"https://picchat-entries.s3.amazonaws.com/%@|", imgURL];
			
			S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:imgURL inBucket:@"picchat-entries"];
			por.contentType = @"image/jpeg";
			por.data = UIImageJPEGRepresentation(scaledImage, 0.5);
			[s3 putObject:por];
		}
		
		imgURLs = [imgURLs substringToIndex:[imgURLs length] - 1];
		NSLog(@"URLS:[%@]", imgURLs);
		
		AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[PCAppDelegate apiServerPath]]];
		NSDictionary *params;
		NSString *apiEndpt;
		
		NSLog(@"CHAT ID:[%d]", [PCAppDelegate chatID]);
		
		if ([PCAppDelegate chatID] == 0) {
			apiEndpt = kChatsAPI;
			params = [NSDictionary dictionaryWithObjectsAndKeys:
						 [NSString stringWithFormat:@"%d", 2], @"action",
						 [[PCAppDelegate infoForUser] objectForKey:@"id"], @"userID",
						 _fbID, @"fbID",
						 _fbName, @"fbName",
						 _subjectName, @"subject",
						 imgURLs, @"imgURLs",
						 nil];
		
		} else {
			apiEndpt = kChatEntriesAPI;
			params = [NSDictionary dictionaryWithObjectsAndKeys:
						 [NSString stringWithFormat:@"%d", 1], @"action",
						 [[PCAppDelegate infoForUser] objectForKey:@"id"], @"userID",
						 [NSString stringWithFormat:@"%d", [PCAppDelegate chatID]], @"chatID",
						 imgURLs, @"imgURLs",
						 nil];
		}
		
		[httpClient postPath:apiEndpt parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
			NSLog(@"Response: %@", text);
			
			NSError *error = nil;
			NSDictionary *chatResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSLog(@"RESULT: %@", chatResult);
			}
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			[self.navigationController dismissViewControllerAnimated:YES completion:nil];
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"%@", [error localizedDescription]);
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}];
		
	} @catch (AmazonClientException *exception) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}

@end
