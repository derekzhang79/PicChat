//
//  PCCameraOverlayView.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCCameraOverlayView.h"

#import "PCAppDelegate.h"

@interface PCCameraOverlayView() <UITextFieldDelegate>
@property (nonatomic, strong) UIImageView *overlayImgView;
@property(nonatomic, strong) UITextField *subjectTextField;
@property(nonatomic, strong) UIButton *editButton;
@property(nonatomic, strong) UILabel *countLabel;
- (void)_hidePreview;
@end

@implementation PCCameraOverlayView

@synthesize delegate = _delegate;
@synthesize subjectName = _subjectName;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 5.0, frame.size.width, 192.0)];
		[self addSubview:headerView];
		
		UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flashButton.frame = CGRectMake(7.0, 0.0, 84.0, 44.0);
		[flashButton setBackgroundImage:[UIImage imageNamed:@"cameraRollButton_nonActive.png"] forState:UIControlStateNormal];
		[flashButton setBackgroundImage:[UIImage imageNamed:@"cameraRollButton_Active.png"] forState:UIControlStateHighlighted];
		[flashButton addTarget:self action:@selector(_goFlashToggle) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:flashButton];
		
		UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		optionsButton.frame = CGRectMake(93.0, 0.0, 134.0, 44.0);
		[optionsButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_nonActive.png"] forState:UIControlStateNormal];
		[optionsButton setBackgroundImage:[UIImage imageNamed:@"settingsButton_Active.png"] forState:UIControlStateHighlighted];
		[optionsButton addTarget:self action:@selector(_goOptions) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:optionsButton];
		
		UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		changeCameraButton.frame = CGRectMake(230.0, 0.0, 84.0, 44.0);
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive.png"] forState:UIControlStateNormal];
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active.png"] forState:UIControlStateHighlighted];
		[changeCameraButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:changeCameraButton];
		
		_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 70.0, 240.0, 20.0)];
		//[_subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_subjectTextField setReturnKeyType:UIReturnKeyDone];
		[_subjectTextField setTextColor:[UIColor whiteColor]];
		[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_subjectTextField.font = [[PCAppDelegate helveticaNeueFontBold] fontWithSize:16];
		_subjectTextField.keyboardType = UIKeyboardTypeDefault;
		_subjectTextField.text = [NSString stringWithFormat:@"#%@", self.subjectName];
		_subjectTextField.delegate = self;
		[self addSubview:_subjectTextField];
		
		_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_editButton.frame = CGRectMake(275.0, 68.0, 34.0, 34.0);
		[_editButton setBackgroundImage:[UIImage imageNamed:@"xCloseButton_nonActive.png"] forState:UIControlStateNormal];
		[_editButton setBackgroundImage:[UIImage imageNamed:@"xCloseButton_Active.png"] forState:UIControlStateHighlighted];
		[_editButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_editButton];
		
		UIImageView *footerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, frame.size.height - 96.0, 320.0, 96.0)];
		footerImgView.image = [UIImage imageNamed:@"cameraAFooterBG.png"];
		footerImgView.userInteractionEnabled = YES;
		[self addSubview:footerImgView];
		
		UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
		leftButton.frame = CGRectMake(10.0, ([PCAppDelegate chatID] == 0) ? 17.0 : 24.0, 64.0, ([PCAppDelegate chatID] == 0) ? 64.0 : 49.0);
		[leftButton setBackgroundImage:[UIImage imageNamed:([PCAppDelegate chatID] == 0) ? @"chatButton_nonActive.png" : @"closeButton_nonActive.png"] forState:UIControlStateNormal];
		[leftButton setBackgroundImage:[UIImage imageNamed:([PCAppDelegate chatID] == 0) ? @"chatButton_Active.png" : @"closeButton_Active.png"] forState:UIControlStateHighlighted];
		[leftButton addTarget:self action:@selector(_goLeft) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:leftButton];
		
		UIButton *midButton = [UIButton buttonWithType:UIButtonTypeCustom];
		midButton.frame = CGRectMake(113.0, 3.0, 94.0, 94.0);
		[midButton setBackgroundImage:[UIImage imageNamed:@"cameraAPlayButton_nonActive.png"] forState:UIControlStateNormal];
		[midButton setBackgroundImage:[UIImage imageNamed:@"cameraAPlayButton_Active.png"] forState:UIControlStateHighlighted];
		[midButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:midButton];
		
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rightButton.frame = CGRectMake(215.0, 17.0, 94.0, 64.0);
		[rightButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_nonActive.png"] forState:UIControlStateNormal];
		[rightButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_Active.png"] forState:UIControlStateHighlighted];
		[rightButton addTarget:self action:@selector(_goRight) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:rightButton];
		
		_countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (self.frame.size.height * 0.5) - 36.0, 320.0, 72.0)];
		_countLabel.backgroundColor = [UIColor clearColor];
		_countLabel.font = [[PCAppDelegate helveticaNeueFontBold] fontWithSize:72.0];
		_countLabel.textColor = [UIColor whiteColor];
		_countLabel.textAlignment = NSTextAlignmentCenter;
		_countLabel.shadowColor = [UIColor blackColor];
		_countLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_countLabel.text = @"";
		[self addSubview:_countLabel];
	}
	
	return (self);
}

- (void)setSubjectName:(NSString *)subjectName {
	_subjectName = subjectName;
	_subjectTextField.text = [NSString stringWithFormat:@"#%@", _subjectName];
}

- (void)updateCount:(int)count {
	_countLabel.text = [NSString stringWithFormat:@"%d", count];
	
	_countLabel.alpha = 1.0;
	[UIView animateWithDuration:0.33 animations:^(void){
		_countLabel.alpha = 0.0;
	} completion:nil];
}


#pragma mark - Navigation
- (void)_goFlashToggle {
	[_delegate cameraOverlayViewShowCameraRoll:self];
	//[_delegate cameraOverlayViewChangeFlash:self];
}

- (void)_goOptions {
	[_delegate cameraOverlayViewShowOptions:self];
}

- (void)_goFlipCamera {
	[_delegate cameraOverlayViewChangeCamera:self];
}

- (void)_goLeft {
	
	if ([PCAppDelegate chatID] == 0)
		[_delegate cameraOverlayViewLeftTabTapped:self];
	
	else
		[_delegate cameraOverlayViewCloseCamera:self];
}

- (void)_goTakePhoto {
	[_delegate cameraOverlayViewTakePicture:self];
}

- (void)_goRight {
	[_delegate cameraOverlayViewRightTabTapped:self];
}

- (void)_goEditSubject {
    _subjectTextField.text = @"#";
    [_subjectTextField becomeFirstResponder];
}


#pragma mark - Delegate Calls
- (void)_hidePreview {
	_overlayImgView = [[UIImageView alloc] initWithFrame:self.bounds];
	_overlayImgView.image = [UIImage imageNamed:([PCAppDelegate isRetina5]) ? @"camerModeBackground-568h.jpg" : @"camerModeBackgroundiPhone.jpg"];
	[self addSubview:_overlayImgView];
	
	[_delegate cameraOverlayViewHidePreview:self];
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

@end
