//
//  PCTabsView.m
//  PicChat
//
//  Created by Matthew Holcombe on 11.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCTabsView.h"

@implementation PCTabsView

@synthesize btn1 = _btn1;
@synthesize btn2 = _btn2;
@synthesize btn3 = _btn3;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [[UIScreen mainScreen] bounds].size.height - 48.0, 320.0, 48.0)];
		bgImgView.image = [UIImage imageNamed:@"footerBG.png"];
		[self addSubview:bgImgView];
		
		_btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
		_btn1.frame = CGRectMake(0.0, [[UIScreen mainScreen] bounds].size.height - 48.0, 64.0, 48.0);
		[_btn1 setBackgroundImage:[UIImage imageNamed:@"leftIcon_nonActive.png"] forState:UIControlStateNormal];
		[_btn1 setBackgroundImage:[UIImage imageNamed:@"leftIcon_Active.png"] forState:UIControlStateHighlighted];
		[_btn1 setBackgroundImage:[UIImage imageNamed:@"leftIcon_nonActive.png"] forState:(UIControlStateSelected | UIControlStateDisabled)];
		[_btn1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[_btn1 setTag:0];
		[self addSubview:_btn1];
		
		_btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
		_btn2.frame = CGRectMake(64.0, [[UIScreen mainScreen] bounds].size.height - 48.0, 191.0, 48.0);
		[_btn2 setBackgroundImage:[UIImage imageNamed:@"middleIcon_nonActive.png"] forState:UIControlStateNormal];
		[_btn2 setBackgroundImage:[UIImage imageNamed:@"middleIcon_Active.png"] forState:UIControlStateHighlighted];
		[_btn2 setBackgroundImage:[UIImage imageNamed:@"middleIcon_nonActive.png"] forState:(UIControlStateSelected | UIControlStateDisabled)];
		[_btn2 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[_btn2 setTag:1];
		[self addSubview:_btn2];
		
		_btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
		_btn3.frame = CGRectMake(255.0, [[UIScreen mainScreen] bounds].size.height - 48.0, 64.0, 48.0);
		[_btn3 setBackgroundImage:[UIImage imageNamed:@"rightIcon_nonActive.png"] forState:UIControlStateNormal];
		[_btn3 setBackgroundImage:[UIImage imageNamed:@"rightIcon_Active.png"] forState:UIControlStateHighlighted];
		[_btn3 setBackgroundImage:[UIImage imageNamed:@"rightIcon_nonActive.png"] forState:(UIControlStateSelected | UIControlStateDisabled)];
		[_btn3 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[_btn3 setTag:2];
		[self addSubview:_btn3];
	}
	
	return (self);
}

- (void)buttonClicked:(id)sender {
	int tagNum = [sender tag];
}

@end
