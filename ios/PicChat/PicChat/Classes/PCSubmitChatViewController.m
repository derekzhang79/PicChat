//
//  PCSubmitChatViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 11.02.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

#import "UIImageView+WebCache.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "FBFriendPickerViewController.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"

#import "PCSubmitChatViewController.h"
#import "PCAppDelegate.h"
#import "PCHeaderView.h"
#import "PCChatVO.h"
#import "PCHistoryViewController.h"
#import "PCChatViewController.h"
#import "PCLoginViewController.h"
#import "PCFacebookCaller.h"

@interface PCSubmitChatViewController () <UITextFieldDelegate, FBFriendPickerDelegate>
@property (nonatomic, strong) UIImageView *photoImgView;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSTimer *photoTimer;
@property (nonatomic) int photoCounter;
@property(nonatomic, strong) NSString *fbID;
@property(nonatomic, strong) NSString *fbName;
@property(nonatomic, strong) NSString *filename;
@property(nonatomic, strong) NSString *subjectName;
@property(nonatomic, strong) UIImageView *recipientImgView;
@property(nonatomic) int chatID;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) UITextField *subjectTextField;
@property(nonatomic, strong) UIButton *editButton;
@end

@implementation PCSubmitChatViewController

- (id)init {
	if ((self = [super init])) {
		_photos = [NSArray array];
		_photoCounter = 0;
		_subjectName = @"";
	}
	
	return (self);
}


- (id)initWithPhotos:(NSArray *)photos {
	if ((self = [self init])) {
		_photoCounter = 0;
		_photos = photos;
		_chatID = 0;
		_fbID = @"";
	}
	
	return (self);
}

- (id)initWithPhotos:(NSArray *)photos withChatID:(int)chatID {
	if ((self = [self init])) {
		_photoCounter = 0;
		_photos = photos;
		_chatID = chatID;
		_fbID = @"";
	}
	
	return (self);
}

- (id)initWithPhotos:(NSArray *)photos withChatID:(int)chatID withSubject:(NSString *)subject {
	if ((self = [self init])) {
		_photoCounter = 0;
		_photos = photos;
		_chatID = chatID;
		_fbID = @"";
		_subjectName = subject;
	}
	
	return (self);
}

- (id)initWithPhotos:(NSArray *)photos withChatID:(int)chatID withSubject:(NSString *)subject withFBID:(NSString *)fbID withFBName:(NSString *)fbName {
	if ((self = [self init])) {
		_photoCounter = 0;
		_photos = photos;
		_chatID = chatID;
		_fbID = fbID;
		_subjectName = subject;
	}
	
	return (self);
}

- (id)initWithPhotos:(NSArray *)photos withSubject:(NSString *)subject {
	if ((self = [self init])) {
		_photoCounter = 0;
		_photos = photos;
		_chatID = 0;
		_subjectName = subject;
		_fbID = @"";
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
	PCHeaderView *headerView = [[PCHeaderView alloc] initWithTitle:@"Preview"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(3.0, 5.0, 64.0, 34.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
	
	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 54.0, 306.0, 306.0)];
	holderView.clipsToBounds = YES;
	[self.view addSubview:holderView];
	
	_photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 306.0, 408.0)];
	_photoImgView.image = [_photos objectAtIndex:0];
	[holderView addSubview:_photoImgView];
	
	if ([_photos count] > 1)
		_photoTimer = [NSTimer scheduledTimerWithTimeInterval:0.125 target:self selector:@selector(_nextPhoto) userInfo:nil repeats:YES];
	
	_recipientImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 55.0, 50.0, 50.0)];
	
	if (![_fbID isEqual:@""]) {
		//[_recipientImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", _fbID]] placeholderImage:nil];
        [_recipientImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", _fbID]] placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
            _recipientImgView.image = [PCAppDelegate cropImage:image toRect:CGRectMake(0.0, 0.0, 108.0, 108.0)];
        } failure:nil];
        
    }
	[self.view addSubview:_recipientImgView];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 110.0, 240.0, 20.0)];
	//[_subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[UIColor whiteColor]];
	[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_subjectTextField.font = [[PCAppDelegate helveticaNeueFontBold] fontWithSize:16];
	_subjectTextField.keyboardType = UIKeyboardTypeDefault;
	_subjectTextField.text = [NSString stringWithFormat:@"#%@", _subjectName];
	_subjectTextField.delegate = self;
	//[self.view addSubview:_subjectTextField];
	
	_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_editButton.frame = CGRectMake(265.0, 55.0, 34.0, 34.0);
	[_editButton setBackgroundImage:[UIImage imageNamed:@"xCloseButton_nonActive.png"] forState:UIControlStateNormal];
	[_editButton setBackgroundImage:[UIImage imageNamed:@"xCloseButton_Active.png"] forState:UIControlStateHighlighted];
	[_editButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
	//[self.view addSubview:_editButton];
	
	NSLog(@"CHAT ID:[%d][%@]", [PCAppDelegate chatID], _fbID);
	
	int offset = ([PCAppDelegate isRetina5]) ? 18.0 : -15.0;
	
	UIButton *friendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	friendButton.frame = CGRectMake(0.0, 351.0 + offset, 320.0, 64.0);
	[friendButton setBackgroundImage:[UIImage imageNamed:@"selectFacebookFriendButton_nonActive.png"] forState:UIControlStateNormal];
	[friendButton setBackgroundImage:[UIImage imageNamed:@"selectFacebookFriendButton_Active.png"] forState:UIControlStateHighlighted];
	[friendButton addTarget:self action:@selector(_goSelectFriend) forControlEvents:UIControlEventTouchUpInside];
	friendButton.hidden = ([PCAppDelegate chatID] != 0);
	[self.view addSubview:friendButton];
	
	UIButton *randomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	randomButton.frame = CGRectMake(0.0, 411.0 + offset, 320.0, 64.0);
	[randomButton setBackgroundImage:[UIImage imageNamed:@"selectRandomFriendButton_nonActive.png"] forState:UIControlStateNormal];
	[randomButton setBackgroundImage:[UIImage imageNamed:@"selectRandomFriendButton_Active.png"] forState:UIControlStateHighlighted];
	[randomButton addTarget:self action:@selector(_goRandomChat) forControlEvents:UIControlEventTouchUpInside];
	randomButton.hidden = ([PCAppDelegate chatID] != 0);
	[self.view addSubview:randomButton];
	
	if (FBSession.activeSession.state != 513) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCLoginViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
		
	}
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

- (void)_goEditSubject {
    _subjectTextField.text = @"#";
    [_subjectTextField becomeFirstResponder];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	_editButton.hidden = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	_editButton.hidden = NO;
	
	if ([textField.text length] == 0)
		textField.text = _subjectName;
	
	else
		_subjectName = textField.text;
}

- (void)_goRandomChat {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Submitting Chat…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	
	[self performSelector:@selector(_submitRandomChat) withObject:nil afterDelay:0.33];
}

- (void)_submitRandomChat {
	//NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
	
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[PCAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[PCAppDelegate s3Credentials] objectForKey:@"secret"]];
	[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"picchat-entries"]];
	
	_filename = [NSString stringWithFormat:@"%@_%@", [PCAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	
	@try {		
		NSLog(@"https://picchat-entries.s3.amazonaws.com/%@", self.filename);		
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
		
		if ([_subjectName hasPrefix:@"#"])
			_subjectName = [_subjectName substringFromIndex:1];
		
		AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[PCAppDelegate apiServerPath]]];
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
					 [NSString stringWithFormat:@"%d", 3], @"action",
					 [[PCAppDelegate infoForUser] objectForKey:@"id"], @"userID",
					 _subjectName, @"subject",
					 imgURLs, @"imgURLs",
					 nil];
			
		[httpClient postPath:kChatsAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
			NSLog(@"Response: %@", text);
			
			NSError *error = nil;
			NSDictionary *chatResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			PCChatVO *vo;
			
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				NSLog(@"RESULT: %@", chatResult);
				vo = [PCChatVO chatWithDictionary:chatResult];
			}
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			//[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
			[self.navigationController dismissViewControllerAnimated:NO completion:^(void) {
				PCHistoryViewController *historyViewController = [[PCHistoryViewController alloc] init];
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:historyViewController];
				[navigationController setNavigationBarHidden:YES];
				[[PCAppDelegate rootViewController] presentViewController:navigationController animated:NO completion:^(void){
					[historyViewController.navigationController pushViewController:[[PCChatViewController alloc] initWithChatVO:vo] animated:YES];
				}];
			}];
			
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
			 //[_recipientImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", _fbID]] placeholderImage:nil];
			 [_recipientImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", _fbID]] placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
				 _recipientImgView.image = [PCAppDelegate cropImage:image toRect:CGRectMake(0.0, 0.0, 108.0, 108.0)];
			 } failure:nil];
			 
			 //NSLog(@"FRIEND:[%@]", [friendPickerController.selection lastObject]);
			 
			 [self _goSubmitChat];
		 }
	 }];
}

- (void)_goSubmitChat {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Submitting Chat…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	
	[self performSelector:@selector(_submitChat) withObject:nil afterDelay:0.33];
}

- (void)_submitChat {
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
		
		
		
		if ([_subjectName hasPrefix:@"#"])
			_subjectName = [_subjectName substringFromIndex:1];
		
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
				
				if ([PCAppDelegate chatID] == 0) {
					[PCFacebookCaller postToTimeline:[PCChatEntryVO entryWithDictionary:chatResult]];
				} else {
					[PCFacebookCaller postToTimeline:[PCChatEntryVO entryWithDictionary:chatResult]];
				}
			}
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			

			//[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];			
			[self.navigationController dismissViewControllerAnimated:NO completion:^(void) {
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCHistoryViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[[PCAppDelegate rootViewController] presentViewController:navigationController animated:NO completion:nil];
			}];
			
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
