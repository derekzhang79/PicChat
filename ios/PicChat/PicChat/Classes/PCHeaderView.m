//
//  PCHeaderView.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.29.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCHeaderView.h"


#import "PCAppDelegate.h"

@implementation PCHeaderView

- (id)initWithTitle:(NSString *)title {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)])) {
		UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:self.frame];
		[headerImgView setImage:[UIImage imageNamed:@"header.png"]];
		[self addSubview:headerImgView];
				
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, 320.0, 25.0)];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.font = [PCAppDelegate helveticaNeueFontBold];
		titleLabel.textColor = [UIColor colorWithRed:0.12549019607843 green:0.31764705882353 blue:0.44705882352941 alpha:1.0];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.33];
		titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		titleLabel.text = title;
		[self addSubview:titleLabel];
	}
	
	return (self);
}

@end
