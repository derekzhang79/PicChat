//
//  PCSubmitChatViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 11.02.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCSubmitChatViewController.h"

#import "PCHeaderView.h"

@interface PCSubmitChatViewController ()
@property (nonatomic, strong) UIImageView *photoImgView;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSTimer *photoTimer;
@property (nonatomic) int photoCounter;
@end

@implementation PCSubmitChatViewController

- (id)init {
	if ((self = [super init])) {
		_photos = [NSArray array];
		_photoCounter = 0;
	}
	
	return (self);
}


- (id)initWithPhotos:(NSArray *)photos {
	if ((self = [self init])) {
		_photos = photos;
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
	
	_photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 55.0, 300.0, 450.0)];
	_photoImgView.image = [_photos objectAtIndex:0];
	[self.view addSubview:_photoImgView];
	
	_photoTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(_nextPhoto) userInfo:nil repeats:YES];
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

@end
