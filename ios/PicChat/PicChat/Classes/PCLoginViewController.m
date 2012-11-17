//
//  PCLoginViewController.m
//  PicChat
//
//  Created by Matthew Holcombe on 10.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

#import "PCAppDelegate.h"
#import "PCLoginViewController.h"

#import "Mixpanel.h"

@interface PCLoginViewController ()

@end

@implementation PCLoginViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
	int ind = (arc4random() % 4) + 1;
	
	[[Mixpanel sharedInstance] track:@"Login Screen"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d", ind], @"index", nil]];
	
	
	NSString *bgAsset = ([PCAppDelegate isRetina5]) ? @"firstUserExperience_Background-568h.png" : @"firstUserExperience_Background.png";
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([PCAppDelegate isRetina5]) ? 548.0 : 470.0)];
	bgImgView.image = [UIImage imageNamed:bgAsset];
	[self.view addSubview:bgImgView];
	
	UIImageView *footerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 68.0, 320.0, 68.0)];
	footerImgView.image = [UIImage imageNamed:@"firstUserExperience_footerBackground"];
	footerImgView.userInteractionEnabled = YES;
	[self.view addSubview:footerImgView];
	
	UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
	facebookButton.frame = CGRectMake(0.0, 3.0, 320.0, 64.0);
	[facebookButton setBackgroundImage:[UIImage imageNamed:@"loginFacebook_nonActive.png"] forState:UIControlStateNormal];
	[facebookButton setBackgroundImage:[UIImage imageNamed:@"loginFacebook_Active.png"] forState:UIControlStateHighlighted];
	[facebookButton addTarget:self action:@selector(_goFacebook) forControlEvents:UIControlEventTouchUpInside];
	[footerImgView addSubview:facebookButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_goDone)];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)_goDone {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation
- (void)_goFacebook {
	[[Mixpanel sharedInstance] track:@"Login Facebook Button"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[PCAppDelegate infoForUser] objectForKey:@"id"], [[PCAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[FBSession openActiveSessionWithPermissions:[PCAppDelegate fbPermissions] allowLoginUI:YES completionHandler:
	 ^(FBSession *session, FBSessionState state, NSError *error) {
		 NSLog(@"///////////// OPEN SESSION /////////////");
		 
		 if (FBSession.activeSession.isOpen) {
			 [[FBRequest requestForMe] startWithCompletionHandler:
			  ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
				  if (!error) {
					  [PCAppDelegate writeFBProfile:user];
					  
					  NSMutableArray *friends = [NSMutableArray array];
					  [FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
						  for (NSDictionary *friend in [(NSDictionary *)result objectForKey:@"data"]) {
							  [friends addObject: [friend objectForKey:@"id"]];
						  }
						  
						  NSLog(@"RETRIEVED FRIENDS");
						  [PCAppDelegate storeFBFriends:friends];
					  }];
					  
					  AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[PCAppDelegate apiServerPath]]];
					  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
													  [NSString stringWithFormat:@"%d", 2], @"action",
													  [[PCAppDelegate infoForUser] objectForKey:@"id"], @"userID",
													  [user objectForKey:@"first_name"], @"username",
													  [user objectForKey:@"id"], @"fbID", 
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
				  }
			  }];
		 }
		 
		 
		 switch (state) {
			 case FBSessionStateOpen: {
				 NSLog(@"--FBSessionStateOpen--");
				 FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
				 [cacheDescriptor prefetchAndCacheForSession:session];
				 
				 [self _goDone];
			 }
				 break;
			 case FBSessionStateClosed:
				 NSLog(@"--FBSessionStateClosed--");
				 break;
				 
			 case FBSessionStateClosedLoginFailed:
				 NSLog(@"--FBSessionStateClosedLoginFailed--");
				 break;
			 default:
				 break;
		 }
		 
		 //		 [[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification object:session];
		 
		 if (error) {
			 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
																				  message:error.localizedDescription
																				 delegate:nil
																	 cancelButtonTitle:@"OK"
																	 otherButtonTitles:nil];
			 [alertView show];
		 }
	 }];
}

@end
