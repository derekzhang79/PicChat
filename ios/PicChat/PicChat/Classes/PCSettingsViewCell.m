//
//  PCSettingsViewCell.m
//  PicChat
//
//  Created by Matthew Holcombe on 11.10.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCSettingsViewCell.h"
#import "PCAppDelegate.h"

@interface PCSettingsViewCell()
@property (nonatomic, strong) UIImageView *bgImgView;
@end

@implementation PCSettingsViewCell

@synthesize bgImgView = _bgImgView;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		[self addSubview:_bgImgView];
	}
	
	return (self);
}

- (id)initAsTopCell {
	if ((self = [self init])) {
		_bgImgView.frame = CGRectMake(0.0, 0.0, 320.0, 20.0);
		_bgImgView.image = [UIImage imageNamed:@"headerTableRow.png"];
	}
	
	return (self);
}

- (id)initAsBottomCell {
	if ((self = [self init])) {
		_bgImgView.frame = CGRectMake(0.0, 0.0, 320.0, 20.0);
		_bgImgView.image = [UIImage imageNamed:@"genericTableFooter.png"];
		
		UIButton *supportButton = [UIButton buttonWithType:UIButtonTypeCustom];
		supportButton.frame = CGRectMake(18.0, 8.0, 284.0, 39.0);
		[supportButton addTarget:self action:@selector(_goSupport) forControlEvents:UIControlEventTouchUpInside];
		[supportButton setBackgroundImage:[UIImage imageNamed:@"needHelp_nonActive.png"] forState:UIControlStateNormal];
		[supportButton setBackgroundImage:[UIImage imageNamed:@"needHelp_Active.png"] forState:UIControlStateHighlighted];
		[self addSubview:supportButton];
	}
	
	return (self);
}

- (id)initAsMidCell:(NSString *)caption {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"blankRowBackground_nonActive.png"];
		
		UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(26.0, 26.0, 250.0, 16.0)];
		indexLabel.font = [[PCAppDelegate helveticaNeueFontBold] fontWithSize:15];
		indexLabel.textColor = [PCAppDelegate blueTxtColor];
		indexLabel.backgroundColor = [UIColor clearColor];
		indexLabel.text = caption;
		[self addSubview:indexLabel];
	}
	
	return (self);
}

- (void)didSelect {
	_bgImgView.image = [UIImage imageNamed:@"blankRowBackground_Active.png"];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)_resetBG {
	_bgImgView.image = [UIImage imageNamed:@"blankRowBackground_nonActive.png"];
}

- (void)_goSupport {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUPPORT" object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
