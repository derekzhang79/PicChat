//
//  PCSettingsViewCell.h
//  PicChat
//
//  Created by Matthew Holcombe on 11.10.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCSettingsViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;

- (id)initAsTopCell;
- (id)initAsBottomCell;
- (id)initAsMidCell:(NSString *)caption;

- (void)didSelect;
@end
