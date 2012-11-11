//
//  PCAppDelegate.h
//  PicChat
//
//  Created by Matthew Holcombe on 10.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "PCLoginViewController.h"
#import "PCCameraViewController.h"

extern NSString *const SCSessionStateChangedNotification;

@interface PCAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) PCLoginViewController *loginViewController;
@property (strong, nonatomic) PCCameraViewController *cameraViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (NSString *)apiServerPath;
+ (NSDictionary *)s3Credentials;
+ (NSString *)facebookCanvasURL;
+ (NSString *)dailySubjectName;
+ (NSString *)rndDefaultSubject;

- (BOOL)openSession;
+ (void)writeDeviceToken:(NSString *)token;
+ (NSString *)deviceToken;

+ (void)writeUserInfo:(NSDictionary *)userInfo;
+ (NSDictionary *)infoForUser;

+ (void)writeFBProfile:(NSDictionary *)userInfo;
+ (NSDictionary *)fbProfileForUser;

+ (void)setAllowsFBPosting:(BOOL)canPost;
+ (BOOL)allowsFBPosting;

+ (void)storeFBFriends:(NSArray *)friends;
+ (NSArray *)fbFriends;

+ (UIViewController *)rootViewController;

+ (void)assignChatID:(int)state;
+ (int)chatID;

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor;
+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect;

+ (NSArray *)fbPermissions;
//
+ (BOOL)isRetina5;
//+ (BOOL)hasNetwork;
//+ (BOOL)canPingServers;
//+ (BOOL)canPingAPIServer;
//+ (BOOL)canPingParseServer;

+ (UIFont *)helveticaNeueFontBold;
+ (UIFont *)helveticaNeueFontMedium;

+ (UIColor *)blueTxtColor;
+ (UIColor *)greyTxtColor;

#define kUsersAPI @"Users.php"
#define kChatsAPI @"Chats.php"
#define kChatEntriesAPI @"ChatEntries.php"
#define kFriendsAPI @"Friends.php"

#define kPhotoTimelapseIncrement 0.5

@end
