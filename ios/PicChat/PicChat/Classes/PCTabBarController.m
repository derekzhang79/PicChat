//
//  PCTabBarController.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCTabBarController.h"
#import "Facebook.h"
#import "Mixpanel.h"

#import "PCAppDelegate.h"

@interface PCTabBarController ()
@end

@implementation PCTabBarController

@synthesize btn1, btn2, btn3;


- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	[self hideTabBar];
	[self addCustomElements];
	[self showNewTabBar];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)hideTabBar {
	for(UIView *view in self.view.subviews) {
		if([view isKindOfClass:[UITabBar class]]) {
			view.hidden = YES;
			break;
		}
	}
}

- (void)hideNewTabBar {
	self.btn1.hidden = YES;
	self.btn2.hidden = YES;
	self.btn3.hidden = YES;
}

- (void)showNewTabBar {
	self.btn1.hidden = NO;
	self.btn2.hidden = NO;
	self.btn3.hidden = NO;
}

-(void)addCustomElements {
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 48.0, 320.0, 48.0)];
	bgImgView.image = [UIImage imageNamed:@"footerBG.png"];
	[self.view addSubview:bgImgView];
	
	UIImage *btnImage = [UIImage imageNamed:@"leftIcon_nonActive.png"];
	UIImage *btnImageActive = [UIImage imageNamed:@"leftIcon_Active.png"];
	UIImage *btnImageSelected = [UIImage imageNamed:@"leftIcon_nonActive.png"];
	
	self.btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn1.frame = CGRectMake(0.0, self.view.frame.size.height - 48.0, 64.0, 48.0);
	[btn1 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn1 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted];
	[btn1 setBackgroundImage:btnImageSelected forState:(UIControlStateSelected | UIControlStateDisabled)];
	[btn1 setTag:0];
	
	btnImage = [UIImage imageNamed:@"middleIcon_nonActive.png"];
	btnImageActive = [UIImage imageNamed:@"middleIcon_Active.png"];
	btnImageSelected = [UIImage imageNamed:@"middleIcon_nonActive.png"];
	self.btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn2.frame = CGRectMake(64.0, self.view.frame.size.height - 48.0, 191.0, 48.0);
	[btn2 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn2 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted];
	[btn2 setBackgroundImage:btnImageSelected forState:(UIControlStateSelected | UIControlStateDisabled)];
	[btn2 setTag:1];
	[btn2 setSelected:true];
	
	btnImage = [UIImage imageNamed:@"rightIcon_nonActive.png"];
	btnImageActive = [UIImage imageNamed:@"rightIcon_Active.png"];
	btnImageSelected = [UIImage imageNamed:@"rightIcon_nonActive.png"];
	self.btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn3.frame = CGRectMake(255.0, self.view.frame.size.height - 48.0, 64.0, 48.0);
	[btn3 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn3 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted];
	[btn3 setBackgroundImage:btnImageSelected forState:(UIControlStateSelected | UIControlStateDisabled)];
	[btn3 setTag:2];
		
	// Add my new buttons to the view
	[self.view addSubview:btn1];
	[self.view addSubview:btn2];
	[self.view addSubview:btn3];
	
	// Setup event handlers so that the buttonClicked method will respond to the touch up inside event.
	[btn1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn2 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn3 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClicked:(id)sender {
	int tagNum = [sender tag];
	[self selectTab:tagNum];
}

- (void)selectTab:(int)tabID {
	[self.delegate tabBarController:self shouldSelectViewController:[self.viewControllers objectAtIndex:tabID]];
	
	switch(tabID) {
		case 0:
//			[[Mixpanel sharedInstance] track:@"Tab - Challenge Wall"
//										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
//														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[btn1 setSelected:true];
			[btn2 setSelected:false];
			[btn3 setSelected:false];
			break;
			
		case 1:
//			[[Mixpanel sharedInstance] track:@"Tab - Voting"
//										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
//														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[btn1 setSelected:false];
			[btn2 setSelected:true];
			[btn3 setSelected:false];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_CAMERA" object:nil];
			break;
			
		case 2:
//			[[Mixpanel sharedInstance] track:@"Tab - Create Challenge"
//										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
//														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[btn1 setSelected:false];
			[btn2 setSelected:false];
			[btn3 setSelected:true];
			break;
	}
	
	if (tabID != 1)
		self.selectedIndex = tabID;
	
	[self.delegate tabBarController:self didSelectViewController:[self.viewControllers objectAtIndex:tabID]];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
