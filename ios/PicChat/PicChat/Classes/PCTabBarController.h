//
//  PCTabBarController.h
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCTabBarController : UITabBarController {
	UIButton *btn1;
	UIButton *btn2;
	UIButton *btn3;
}

@property (nonatomic, retain) UIButton *btn1;
@property (nonatomic, retain) UIButton *btn2;
@property (nonatomic, retain) UIButton *btn3;

- (void)hideTabBar;
- (void)addCustomElements;
- (void)selectTab:(int)tabID;

- (void)hideNewTabBar;
- (void)showNewTabBar;

@end
