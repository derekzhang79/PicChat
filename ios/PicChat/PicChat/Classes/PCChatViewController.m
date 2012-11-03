//
//  PCChatViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.31.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCChatViewController.h"
#import "PCHeaderView.h"

@interface PCChatViewController ()

@end

@implementation PCChatViewController

- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (id)initWithChatVO:(PCChatVO *)vo {
	if ((self = [self init])) {
		
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
	PCHeaderView *headerView = [[PCHeaderView alloc] initWithTitle:@"Chat"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}
@end
