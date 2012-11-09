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
@property (nonatomic) int imageCounter;
@property (nonatomic, strong) UIImageView *authorImgView;
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
		
		_authorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 54.0, 54.0)];
		[self addSubview:_authorImgView];
		
		_loadImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 200.0)];
		_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(70.0, 1.0, 150.0, 200.0)];
		[self addSubview:_imgView];
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setEntryVO:(PCChatEntryVO *)entryVO {
	_entryVO = entryVO;
	
	[_authorImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", _entryVO.authorFB]] placeholderImage:nil];
	
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
