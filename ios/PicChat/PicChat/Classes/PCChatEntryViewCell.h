//
//  PCChatEntryViewCell.h
//  PicChat
//
//  Created by Matthew Holcombe on 11.08.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PCChatEntryVO.h"

@interface PCChatEntryViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

@property (nonatomic, strong) PCChatEntryVO *entryVO;
@end
