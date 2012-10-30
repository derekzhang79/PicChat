//
//  PCPersonViewCell.h
//  PicChat
//
//  Created by Matthew Holcombe on 10.29.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PCPersonVO.h"

@interface PCPersonViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initAsTopCell:(BOOL)isFamilyList;
- (id)initAsBottomCell:(BOOL)isEnabled;
- (id)initAsChatCell;

- (void)didSelect;

@property (nonatomic, strong) PCPersonVO *personVO;
@end
