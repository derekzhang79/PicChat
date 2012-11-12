//
//  PCAppDelegate.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Parse/Parse.h>

#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Mixpanel.h"
#import "Parse/Parse.h"
#import "Reachability.h"
#import "UAirship.h"
#import "UAPush.h"

#import "PCAppDelegate.h"

#import "PCTabBarController.h"
#import "PCHistoryViewController.h"
#import "PCCameraViewController.h"
#import "PCPeopleViewController.h"
#import "PCAppRootViewController.h"

NSString *const SCSessionStateChangedNotification = @"com.facebook.Scrumptious:SCSessionStateChangedNotification";

@interface PCAppDelegate() <UIAlertViewDelegate, UAPushNotificationDelegate>
@property (nonatomic, strong) UIAlertView *networkAlertView;
- (void)_registerUser;
@end

@implementation PCAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize tabBarController = _tabBarController;
@synthesize cameraViewController = _cameraViewController;


+ (NSString *)apiServerPath {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"server_api"]);
}

+ (NSDictionary *)s3Credentials {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"s3_creds"]);
}

+ (NSString *)facebookCanvasURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_url"]);
}

+ (NSString *)dailySubjectName {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"daily_subject"]);
}

+ (NSString *)rndDefaultSubject {
	NSArray *subjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_subjects"];
	return ([subjects objectAtIndex:(arc4random() % [subjects count])]);
}


+ (BOOL)isRetina5 {
	return ([UIScreen mainScreen].scale == 2.f && [UIScreen mainScreen].bounds.size.height == 568.0f);
}

+ (BOOL)hasNetwork {
	//Reachability *wifiReachability = [Reachability reachabilityForLocalWiFi];
	//[[Reachability reachabilityForLocalWiFi] startNotifier];
	
	//return ([wifiReachability currentReachabilityStatus] == kReachableViaWiFi);
	
	[[Reachability reachabilityForInternetConnection] startNotifier];
	NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
	
	return !(networkStatus == NotReachable);
}

+ (BOOL)canPingServers {
	NetworkStatus apiStatus = [[Reachability reachabilityWithHostName:[[[PCAppDelegate apiServerPath] componentsSeparatedByString: @"/"] objectAtIndex:2]] currentReachabilityStatus];
	NetworkStatus parseStatus = [[Reachability reachabilityWithHostName:@"api.parse.com"] currentReachabilityStatus];
	
	return (!(apiStatus == NotReachable) && !(parseStatus == NotReachable));
}

+ (BOOL)canPingAPIServer {
	NetworkStatus apiStatus = [[Reachability reachabilityWithHostName:[[[PCAppDelegate apiServerPath] componentsSeparatedByString: @"/"] objectAtIndex:2]] currentReachabilityStatus];
	
	return (!(apiStatus == NotReachable));
}

+ (BOOL)canPingParseServer {
	NetworkStatus parseStatus = [[Reachability reachabilityWithHostName:@"api.parse.com"] currentReachabilityStatus];
	
	return (!(parseStatus == NotReachable));
}

+ (NSArray *)fbPermissions {
	return ([NSArray arrayWithObjects:@"publish_actions", @"status_update", @"publish_stream", nil]);
}

+ (void)writeDeviceToken:(NSString *)token {
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)deviceToken {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"]);
}

+ (void)writeUserInfo:(NSDictionary *)userInfo {
	[[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"user_info"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)infoForUser {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"]);
}

+ (void)writeFBProfile:(NSDictionary *)profile {
	if (profile != nil)
		[[NSUserDefaults standardUserDefaults] setObject:profile forKey:@"fb_profile"];
	
	else
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fb_profile"];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)fbProfileForUser {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"fb_profile"]);
}

+ (void)setAllowsFBPosting:(BOOL)canPost {
	[[NSUserDefaults standardUserDefaults] setObject:(canPost) ? @"YES" : @"NO" forKey:@"fb_posting"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)allowsFBPosting {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fb_posting"] isEqualToString:@"YES"]);
}

+ (void)storeFBFriends:(NSArray *)friends {
	[[NSUserDefaults standardUserDefaults] setObject:friends forKey:@"fb_friends"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)fbFriends {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"fb_friends"]);
}

+ (void)assignChatID:(int)state {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:state] forKey:@"chat_id"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int)chatID {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"chat_id"] intValue]);
}


+ (UIViewController *)rootViewController {
	return ([[UIApplication sharedApplication] keyWindow].rootViewController);
}


+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
	
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (scaledImage);
}

+ (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor {
	CGSize size = CGSizeMake(image.size.width * factor, image.size.height * factor);
	
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
	
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (scaledImage);
}

+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect {
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
	
	UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return (croppedImage);
}

+ (UIFont *)helveticaNeueFontBold {
	return [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
}

+ (UIFont *)helveticaNeueFontMedium {
	return [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
}

+ (UIColor *)blueTxtColor {
	return ([UIColor colorWithRed:0.17647058823529 green:0.33333333333333 blue:0.6078431372549 alpha:1.0]);
}

+ (UIColor *)greyTxtColor {
	return ([UIColor colorWithWhite:0.482 alpha:1.0]);
}


- (BOOL)openSession {
	NSLog(@"openSession");
//	return ([FBSession openActiveSessionWithReadPermissions:[PCAppDelegate fbPermissions]
//															 allowLoginUI:NO
//													  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//														  NSLog(@"STATE:%d", state);
//														  [self sessionStateChanged:session state:state error:error];
//													  }]);
	
	return ([FBSession openActiveSessionWithPermissions:[PCAppDelegate fbPermissions]
														allowLoginUI:NO
												 completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
													 NSLog(@"STATE:%d", state);
													 [self sessionStateChanged:session state:state error:error];
												 }]);
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
	// FBSample logic
	// Any time the session is closed, we want to display the login controller (the user
	// cannot use the application unless they are logged in to Facebook). When the session
	// is opened successfully, hide the login controller and show the main UI.
	
	NSLog(@"sessionStateChanged:[%d]", state);
	
	switch (state) {
		case FBSessionStateOpen: {
			NSLog(@"--FBSessionStateOpen--");
			[self.loginViewController dismissViewControllerAnimated:YES completion:nil];
			
			//			if (self.loginViewController != nil) {
			//				UIViewController *topViewController = [self.tabBarController topViewController];
			//				[topViewController dismissModalViewControllerAnimated:YES];
			//				self.loginViewController = nil;
			//			}
			
			// FBSample logic
			// Pre-fetch and cache the friends for the friend picker as soon as possible to improve
			// responsiveness when the user tags their friends.
			FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
			[cacheDescriptor prefetchAndCacheForSession:session];
			
			NSMutableArray *friends = [NSMutableArray array];
			[FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
				for (NSDictionary *friend in [(NSDictionary *)result objectForKey:@"data"]) {
					[friends addObject: [friend objectForKey:@"id"]];
				}
				
				NSLog(@"RETRIEVED FRIENDS");
				[PCAppDelegate storeFBFriends:friends];
			}];
		}
			break;
		case FBSessionStateClosed:
			NSLog(@"--FBSessionStateClosed--");
			break;
			
		case FBSessionStateClosedLoginFailed: {
			NSLog(@"--FBSessionStateClosedLoginFailed--");
			// FBSample logic
			// Once the user has logged out, we want them to be looking at the root view.
			//			UIViewController *topViewController = [self.navController topViewController];
			//			UIViewController *modalViewController = [topViewController modalViewController];
			//			if (modalViewController != nil) {
			//				[topViewController dismissModalViewControllerAnimated:NO];
			//			}
			//			[self.navController popToRootViewControllerAnimated:NO];
			
			[FBSession.activeSession closeAndClearTokenInformation];
			
			// if the token goes invalid we want to switch right back to
			// the login view, however we do it with a slight delay in order to
			// account for a race between this and the login view dissappearing
			// a moment before
			
			self.loginViewController = [[PCLoginViewController alloc] init];
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.loginViewController];
			[navigationController setNavigationBarHidden:YES];
			[self.tabBarController presentViewController:navigationController animated:NO completion:nil];
			
			//			[self performSelector:@selector(showLoginView)
			//						  withObject:nil
			//						  afterDelay:0.5f];
		}
			break;
		default:
			break;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification
																		 object:session];
	
	if (error) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
																			 message:error.localizedDescription
																			delegate:nil
																cancelButtonTitle:@"OK"
																otherButtonTitles:nil];
		[alertView show];
	}
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	if ([PCAppDelegate hasNetwork] && [PCAppDelegate canPingParseServer]) {
		NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
		[takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
		[UAirship takeOff:takeOffOptions];
		[[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
		[UAPush shared].delegate = self;
		
		[Parse setApplicationId:@"Gi7eI4v6r9pEZmSQ0wchKKelOgg2PIG9pKE160uV" clientKey:@"Bv82pH4YB8EiXZG4V0E2KjEVtpLp4Xds25c5AkLP"];
		[PFUser enableAutomaticUser];
		
		PFACL *defaultACL = [PFACL ACL];
		
		// If you would like all objects to be private by default, remove this line.
		[defaultACL setPublicReadAccess:YES];
		[PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
		
		PFQuery *appIDQuery = [PFQuery queryWithClassName:@"AppIDs"];
		PFObject *appIDObject = [appIDQuery getObjectWithId:@"srHSbLC5Sf"];
		
		PFQuery *apiQuery = [PFQuery queryWithClassName:@"APIs"];
		PFObject *apiObject = [apiQuery getObjectWithId:@"l3MBvtsJQC"];
		
		PFQuery *s3Query = [PFQuery queryWithClassName:@"S3Credentials"];
		PFObject *s3Object = [s3Query getObjectWithId:@"zofEGq6sLT"];
		
		PFQuery *fbQuery = [PFQuery queryWithClassName:@"FacebookPaths"];
		PFObject *fbObject = [fbQuery getObjectWithId:@"E7C1lrIB25"];
		
		PFQuery *dailyQuery = [PFQuery queryWithClassName:@"DailyChallenges"];
		PFObject *dailyObject = [dailyQuery getObjectWithId:@"X0JSNV39lu"];
		
		PFQuery *subjectQuery = [PFQuery queryWithClassName:@"PicChatDefaultSubjects"];
		NSMutableArray *subjects = [NSMutableArray array];
		for (PFObject *obj in [subjectQuery findObjects])
			[subjects addObject:[obj objectForKey:@"title"]];
		
		[[NSUserDefaults standardUserDefaults] setObject:[appIDObject objectForKey:@"appstore_id"] forKey:@"appstore_id"];
		[[NSUserDefaults standardUserDefaults] setObject:[apiObject objectForKey:@"server_path"] forKey:@"server_api"];
		[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:[s3Object objectForKey:@"key"], @"key", [s3Object objectForKey:@"secret"], @"secret", nil] forKey:@"s3_creds"];
		[[NSUserDefaults standardUserDefaults] setObject:[fbObject objectForKey:@"canvas_url"] forKey:@"facebook_url"];
		[[NSUserDefaults standardUserDefaults] setObject:[dailyObject objectForKey:@"subject_name"] forKey:@"daily_subject"];
		[[NSUserDefaults standardUserDefaults] setObject:[subjects copy] forKey:@"default_subjects"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		
		[Mixpanel sharedInstanceWithToken:@"8e696526c2d9bb4800b40edc6b93aba6"];
		[[Mixpanel sharedInstance] track:@"App Boot"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		int boot_total = 0;
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"]) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
		
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Welcome to PicChat! A Facebook picture chat client for your iPhone or iPod Touch."
																				 message:@"Please note that we do NOT post any images to your Facebook wall without your permission to turn on timeline settings. The Timeline setting can be found in the Settings menu above."
																				delegate:nil
																	cancelButtonTitle:@"OK"
																	otherButtonTitles:nil];
			[alertView show];
		
		} else {
			boot_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue];
			boot_total++;
			
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
		}
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"])
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
		
		
		if (boot_total == 5) {
			UIAlertView *alert = [[UIAlertView alloc]
										 initWithTitle:@"Rate PicChat"
										 message:@"Why not rate PicChat in the app store!"
										 delegate:self
										 cancelButtonTitle:nil
										 otherButtonTitles:@"No Thanks", @"Ask Me Later", @"Visit App Store", nil];
			
			[alert show];
		}
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"fb_posting"])
			[PCAppDelegate setAllowsFBPosting:NO];
		
		[PCAppDelegate assignChatID:0];
		
		self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		self.window.backgroundColor = [UIColor whiteColor];
		

//		UIViewController *historyViewController, *appRootViewController, *peopleViewController;
//		historyViewController = [[PCHistoryViewController alloc] init];
//		appRootViewController = [[PCAppRootViewController alloc] init];
//		peopleViewController = [[PCPeopleViewController alloc] init];
//		
//		UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:historyViewController];
//		UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:appRootViewController];
//		UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:peopleViewController];
//		
//		[navController1 setNavigationBarHidden:YES];
//		[navController2 setNavigationBarHidden:YES];
//		[navController3 setNavigationBarHidden:YES];
//		
//		self.tabBarController = [[PCTabBarController alloc] init];
//		self.tabBarController.delegate = self;
//		self.tabBarController.viewControllers = [NSArray arrayWithObjects:navController1, navController2, navController3, nil];
		
		self.window.rootViewController = [[PCAppRootViewController alloc] init];
		[self.window makeKeyAndVisible];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCCameraViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self.window.rootViewController presentViewController:navigationController animated:NO completion:nil];
		
		if (![self openSession]) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCLoginViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self.window.rootViewController presentViewController:navigationController animated:NO completion:nil];
		}
	}
	
	return (YES);
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//	NSDate *alertTime = [[NSDate date] dateByAddingTimeInterval:10];
//	UIApplication *app = [UIApplication sharedApplication];
//	
//	UILocalNotification *notifyAlarm = [[UILocalNotification alloc] init];
//	if (notifyAlarm) {
//		notifyAlarm.fireDate = alertTime;
//		notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
//		notifyAlarm.repeatInterval = 0;
//		notifyAlarm.soundName = UILocalNotificationDefaultSoundName;
//		notifyAlarm.alertBody = @"Staff meeting in 30 minutes";
//		
//		[app scheduleLocalNotification:notifyAlarm];
//	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveContext];
	
	[UAirship land];
	[FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [FBSession.activeSession handleOpenURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[[UAPush shared] registerDeviceToken:deviceToken];
	
	NSString *deviceID = [[deviceToken description] substringFromIndex:1];
	deviceID = [deviceID substringToIndex:[deviceID length] - 1];
	deviceID = [deviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:[%@]", deviceID);
	
	[PCAppDelegate writeDeviceToken:deviceID];
	[self _registerUser];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
	
	NSString *deviceID = [NSString stringWithFormat:@"%064d", 0];
	NSLog(@"didFailToRegisterForRemoteNotificationsWithError:[%@]", deviceID);
	
	[PCAppDelegate writeDeviceToken:deviceID];
	[self _registerUser];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	UALOG(@"Received remote notification: %@", userInfo);
	
	// Get application state for iOS4.x+ devices, otherwise assume active
	UIApplicationState appState = UIApplicationStateActive;
	if ([application respondsToSelector:@selector(applicationState)]) {
		appState = application.applicationState;
	}
	
	[[UAPush shared] handleNotification:userInfo applicationState:appState];
	[[UAPush shared] resetBadge]; // zero badge after push received
	
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:([[userInfo objectForKey:@"type"] intValue] == 1) ? @"New Chat" : @"Added Chat"
//																		 message:[userInfo objectForKey:@"alert"]
//																		delegate:nil
//															cancelButtonTitle:@"OK"
//															otherButtonTitles:nil];
//	[alertView show];
	
	
	
	/*
	 int type_id = [[userInfo objectForKey:@"type"] intValue];
	 NSLog(@"TYPE: [%d]", type_id);
	 
	 switch (type_id) {
	 case 1:
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_REWARDS_LIST" object:nil];
	 break;
	 
	 case 2:
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_REWARDS_LIST" object:nil];
	 break;
	 
	 case 3:
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_DEVICES_LIST" object:nil];
	 break;
	 
	 case 4:
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"THANK_YOU_RECIEVED" object:nil];
	 break;
	 
	 }
	 
	 if (type_id == 2) {
	 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leaving diddit" message:@"Your iTunes gift card number has been copied" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:@"Visit iTunes", nil];
	 [alert show];
	 [alert release];
	 
	 NSString *redeemCode = [[DIAppDelegate md5:[NSString stringWithFormat:@"%d", arc4random()]] uppercaseString];
	 redeemCode = [redeemCode substringToIndex:[redeemCode length] - 12];
	 
	 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	 [pasteboard setValue:redeemCode forPasteboardType:@"public.utf8-plain-text"];
	 }
	 */
	
	
	
//	UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//	localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
//	localNotification.timeZone = [NSTimeZone defaultTimeZone];
//	localNotification.alertBody = [NSString stringWithFormat:@"%d", [[userInfo objectForKey:@"type"] intValue]];
//	localNotification.soundName = UILocalNotificationDefaultSoundName;
//	localNotification.applicationIconBadgeNumber = 0;
//	localNotification.repeatInterval = 0;
//	localNotification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
//	 
//	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
	 
}

- (void)displayNotificationAlert:(NSString *)alertMessage {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertMessage
																		 message:@""
																		delegate:nil
															cancelButtonTitle:@"OK"
															otherButtonTitles:nil];
	[alertView show];
}

- (void)_registerUser {
	//if (![[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[PCAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 1], @"action",
									[PCAppDelegate deviceToken], @"token",
									nil];
	
	[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSLog(@"USER: %@", userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null])
				[PCAppDelegate writeUserInfo:userResult];
		}
		
		//NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		//NSLog(@"Response: %@", text);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"%@", [error localizedDescription]);
	}];
	
	
	
//	NSURL *url = [NSURL URLWithString:@"http://httpbin.org/ip"];
//	NSURLRequest *request = [NSURLRequest requestWithURL:url];
//	
//	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//		NSLog(@"IP Address: %@", [JSON valueForKeyPath:@"origin"]);
//	} failure:nil];
//	
//	[operation start];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PicChat" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PicChat.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - TabBarController Delegates
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	//NSLog(@"shouldSelectViewController:[%@]", viewController);
	
	if (viewController == [[tabBarController viewControllers] objectAtIndex:1]) {
		UINavigationController *navigationController;
		
		if ([PCAppDelegate chatID] == 0)
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCCameraViewController alloc] init]];
		
		else
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[PCCameraViewController alloc] initWithChatID:[PCAppDelegate chatID]]];
		
		[navigationController setNavigationBarHidden:YES];
		[tabBarController presentViewController:navigationController animated:NO completion:nil];
		
//		[tabBarController.navigationController pushViewController:[[PCCameraViewController alloc] init] animated:NO];
		
		return (NO);
	
	} else
		return (YES);
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	//NSLog(@"didSelectViewController:[%@]", viewController);
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}


#pragma mark - AlertView delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (alertView == _networkAlertView)
		NSLog(@"EXIT APP");//exit(0);
	
	else {
		switch(buttonIndex) {
			case 0:
				break;
				
			case 1:
				[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				break;
				
			case 2:
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms://itunes.apple.com/us/app/id%@?mt=8", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]];
				break;
		}
	}
}

@end
