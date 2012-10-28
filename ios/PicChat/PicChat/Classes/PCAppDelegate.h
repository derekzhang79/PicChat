//
//  PCAppDelegate.h
//  PicChat
//
//  Created by Matthew Holcombe on 10.27.12.
//  Copyright (c) 2012 Matthew Holcombe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
