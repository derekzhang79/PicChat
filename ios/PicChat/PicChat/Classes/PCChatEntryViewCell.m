//
//  PCChatEntryViewCell.m
//  PicChat
//
//  Created by Matthew Holcombe on 11.08.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "PCChatEntryViewCell.h"
#import "PCAppDelegate.h"
#import "UIImageView+WebCache.h"

@interface PCChatEntryViewCell()
@property (nonatomic, strong) NSTimer *imgTimer;
@property (nonatomic, strong) UIImageView *loadImgView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) UIImageView *imageHolderImgView;
@property (nonatomic) int imageCounter;
@property (nonatomic, strong) UIImageView *authorHolderImgView;
@property (nonatomic) BOOL isUser;
@end

@implementation PCChatEntryViewCell

@synthesize entryVO = _entryVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		_images = [NSMutableArray array];
		_imageCounter = 0;
		_isUser = YES;
		
		_authorHolderImgView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 7.0, 64.0, 64.0)];
		_authorHolderImgView.image = [UIImage imageNamed:@"avatarBackground.png"];
		[self addSubview:_authorHolderImgView];
		
		_imageHolderImgView = [[UIImageView alloc] initWithFrame:CGRectMake(75.0, 7.0, 240.0, 270.0)];
		_imageHolderImgView.image = [UIImage imageNamed:@"chatAnimationBackground.png"];
		[self addSubview:_imageHolderImgView];
		
		UIView *imgHolderView = [[UIView alloc] initWithFrame:CGRectMake(30.0, 30.0, 180.0, 210.0)];
		imgHolderView.clipsToBounds = YES;
		[_imageHolderImgView addSubview:imgHolderView];
		
		_loadImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 200.0)];
		_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 240.0)];
		[imgHolderView addSubview:_imgView];
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setEntryVO:(PCChatEntryVO *)entryVO {
	_entryVO = entryVO;
	
	_isUser = (entryVO.authorID == [[[PCAppDelegate infoForUser] objectForKey:@"id"] intValue]);
	_authorHolderImgView.frame = CGRectOffset(_authorHolderImgView.frame, _isUser * 242.0, 0.0);
	_imageHolderImgView.frame = CGRectOffset(_imageHolderImgView.frame, _isUser * -70.0, 0.0);
	
	UIImageView *authorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 44.0, 44.0)];
	[authorImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", _entryVO.authorFB]] placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
        authorImgView.image = [PCAppDelegate cropImage:image toRect:CGRectMake(0.0, 0.0, 108.0, 108.0)];
    } failure:nil];
	[_authorHolderImgView addSubview:authorImgView];
	
//	__weak id weakSelf = self;
//	
//	[_loadImgView setImageWithURL:[NSURL URLWithString:[_entryVO.images objectAtIndex:0]] placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
//		_imgView.image = image;
//		
//		[self.images addObject:image];
//		[weakSelf _loadImages];
//	} failure:nil];
	
	if ([_entryVO.images count] > 1)
		[self _loadImages];
	
	else {
		[_imgView setImageWithURL:[NSURL URLWithString:[_entryVO.images objectAtIndex:0]] placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
		} failure:nil];
	}
		
	//_imgTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(_nextImage) userInfo:nil repeats:YES];
}

- (void)_loadImages {
	NSLog(@"_loadImages (%d/%d)", [_images count], [_entryVO.images count]);
	__weak id weakSelf = self;
	
	if (++_imageCounter == [_entryVO.images count] - 1) {
		[self performSelector:@selector(_nextImage) withObject:nil afterDelay:0.33];
		//_imgTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(_nextImage) userInfo:nil repeats:YES];
	
	} else {
		[_loadImgView setImageWithURL:[NSURL URLWithString:[_entryVO.images objectAtIndex:[_images count]]] placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
			[self.images addObject:image];
			[weakSelf _loadImages];
		} failure:nil];
	}
}


- (void)_nextImage {
	_imageCounter++;
	_imageCounter = _imageCounter % [_entryVO.images count];
	
//	_imgView.image = [_images objectAtIndex:_imageCounter];
	
	__weak id weakSelf = self;
	[_imgView setImageWithURL:[NSURL URLWithString:[_entryVO.images objectAtIndex:_imageCounter]] placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
		[weakSelf performSelector:@selector(_nextImage) withObject:nil afterDelay:0.33];
	} failure:nil];
}

- (void)dealloc {
//	[_imgTimer invalidate];
//	_imgTimer = nil;
}


@end
