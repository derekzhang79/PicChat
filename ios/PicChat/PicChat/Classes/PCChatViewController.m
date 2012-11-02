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

- (void)loadView {
	[super loadView];
	
	PCHeaderView *headerView = [[PCHeaderView alloc] initWithTitle:@"Chat"];
	[self.view addSubview:headerView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
