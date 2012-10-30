//
//  PCHistoryViewCell.h
//  PicChat
//
//  Created by Matthew Holcombe on 10.29.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PCChatVO.h"

@interface PCHistoryViewCell : UITableViewCell

+ (NSString *)cellReuseIdentifier;

- (id)initAsTopCell:(BOOL)isNewList;
- (id)initAsBottomCell:(BOOL)isEnabled;
- (id)initAsChatCell;

- (void)didSelect;

@property (nonatomic, strong) PCChatVO *chatVO;

@end
