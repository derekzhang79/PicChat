//
//  PCPersonViewCell.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.29.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCPersonViewCell.h"

@interface PCPersonViewCell ()
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UIImageView *toggleImgView;
@property (nonatomic) BOOL isFamily;
@end

@implementation PCPersonViewCell

@synthesize personVO = _personVO;

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

- (id)initAsTopCell:(BOOL)isFamilyList {
	if ((self = [self init])) {
		_isFamily = isFamilyList;
		_bgImgView.image = [UIImage imageNamed:@"headerTableRow.png"];
		
		_toggleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(75.0, 20.0, 169.0, 44.0)];
		_toggleImgView.image = [UIImage imageNamed:@"toggleChats_new.png"];
		[self addSubview:_toggleImgView];
		
		UIButton *familyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		familyButton.frame = CGRectMake(76.0, 25.0, 84.0, 34.0);
		[familyButton addTarget:self action:@selector(_goFamily) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:familyButton];
		
		UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		friendsButton.frame = CGRectMake(161.0, 25.0, 84.0, 34.0);
		[friendsButton addTarget:self action:@selector(_goFriends) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:friendsButton];
	}
	
	return (self);
}

- (id)initAsBottomCell:(BOOL)isEnabled {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"footerTableRow_nonActive.png"];
		
		UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		loadMoreButton.frame = CGRectMake(100.0, -3.0, 120.0, 60.0);
		[loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_nonActive.png"] forState:UIControlStateNormal];
		[loadMoreButton setBackgroundImage:[UIImage imageNamed:@"loadMoreButton_Active.png"] forState:UIControlStateHighlighted];
		
		if (isEnabled)
			[loadMoreButton addTarget:self action:@selector(_goLoadMore) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:loadMoreButton];
	}
	
	return (self);
}

- (id)initAsChatCell {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"commonTableRow_nonActive.png"];
	}
	
	return (self);
}

- (void)setPersonVO:(PCPersonVO *)personVO {
	_personVO = personVO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)didSelect {
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)_resetBG {
}


#pragma mark - Navigation
- (void)_goFamily {
	_isFamily = YES;
	_toggleImgView.image = [UIImage imageNamed:@"toggleChats_new.png"];
}

- (void)_goFriends {
	_isFamily = NO;
	_toggleImgView.image = [UIImage imageNamed:@"toggleChats_all.png"];
}

@end
